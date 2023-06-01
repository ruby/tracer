# frozen_string_literal: true

require_relative "base"

class IvarTracer < Tracer::Base
  def initialize(target, var_name, **kw)
    @target = target
    @var_name = var_name
    @original_value = M_INSTANCE_VARIABLE_GET.bind_call(target, var_name)
    super(**kw)
  end

  def key
    [@type, @target, @var_name, @pattern, @into].freeze
  end

  def description
    "for #{@var_name} of #{@target} #{super}"
  end

  def setup_tp
    TracePoint.new(:a_return) do |tp|
      next if skip?(tp)

      if tp.self == @target &&
           value = M_INSTANCE_VARIABLE_GET.bind_call(@target, @var_name)
        if tp.event == :c_return
          location = nil
        else
          location = caller_locations(2, 1).first.to_s
          next if location.match?(DIR) || location.match?(/<internal:/)
        end

        depth = caller.size
        call_identifier_str = (tp.defined_class ? minfo(tp) : "block")
        call_identifier_str = colorize_blue(call_identifier_str)
        depth += 1 if tp.event == :c_return
        value = safe_inspect(value)

        if value != @original_value
          out tp,
              "#{call_identifier_str} sets #{colorize_cyan(@var_name)} = #{colorize_magenta(value)}",
              depth: depth - 2 - @depth_offset,
              location: location
        end
      end
    end
  end
end
