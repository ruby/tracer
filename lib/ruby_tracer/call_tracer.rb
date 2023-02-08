# frozen_string_literal: true

require_relative "base"

class CallTracer < Tracer::Base
  def setup_tp
    TracePoint.new(:a_call, :a_return) do |tp|
      next if skip?(tp)

      depth = caller.size

      call_identifier_str = (tp.defined_class ? minfo(tp) : "block")

      call_identifier_str = colorize_blue(call_identifier_str)

      case tp.event
      when :call, :c_call, :b_call
        depth += 1 if tp.event == :c_call
        sp = " " * depth
        out tp, ">#{sp}#{call_identifier_str}", depth
      when :return, :c_return, :b_return
        depth += 1 if tp.event == :c_return
        sp = " " * depth
        return_str = colorize_magenta(safe_inspect(tp.return_value))
        out tp, "<#{sp}#{call_identifier_str} #=> #{return_str}", depth
      end
    end
  end

  def skip_with_pattern?(tp)
    super && !tp.method_id&.match?(@pattern)
  end
end
