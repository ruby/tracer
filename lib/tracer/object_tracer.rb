# frozen_string_literal: true

require_relative "base"

class ObjectTracer < Tracer::Base
  attr_reader :target_id, :target_label

  def initialize(target = nil, target_id: nil, target_label: nil, **kw)
    unless target || target_id
      raise ArgumentError, "target or target_id is required"
    end

    @target_id = target_id || M_OBJECT_ID.bind_call(target)
    @target_label =
      (target ? safe_inspect(target) : target_label || "<unlabelled>")
    super(**kw)
  end

  def key
    [@type, @target_id, @pattern, @into].freeze
  end

  def description
    "for #{@target_label} #{super}"
  end

  def colorized_target_label
    colorize_magenta(@target_label)
  end

  PRIMITIVE_METHOD_SOURCES = [Module, Class, Object, Kernel]

  def setup_tp
    TracePoint.new(:a_call) do |tp|
      next if skip?(tp)

      if M_OBJECT_ID.bind_call(tp.self) == @target_id
        if PRIMITIVE_METHOD_SOURCES.any? { |klass| klass == tp.defined_class }
          next
        end

        internal_depth = 2
        klass = tp.defined_class
        method = tp.method_id
        method_info =
          method_info =
            if klass
              if klass.singleton_class?
                if M_IS_A.bind_call(tp.self, Class)
                  ".#{method} (#{klass}.#{method})"
                else
                  ".#{method}"
                end
              else
                "##{method} (#{klass}##{method})"
              end
            else
              if method
                "##{method} (<unknown>##{method})"
              else
                "<eval or exec with &block>"
              end
            end

        out tp,
            " #{colorized_target_label} receives #{colorize_blue(method_info)}",
            location: caller_locations(internal_depth, 1).first,
            depth: caller.size - internal_depth - @depth_offset
      elsif !tp.parameters.empty?
        b = tp.binding
        method_info = colorize_blue(minfo(tp))

        tp.parameters.each do |type, name|
          next unless name

          colorized_name = colorize_cyan(name)

          case type
          when :req, :opt, :key, :keyreq
            if M_OBJECT_ID.bind_call(b.local_variable_get(name)) == @target_id
              internal_depth = 4
              out tp,
                  " #{colorized_target_label} is used as a parameter #{colorized_name} of #{method_info}",
                  location: caller_locations(internal_depth, 1).first,
                  depth: caller.size - internal_depth - @depth_offset
            end
          when :rest
            next if name == :"*"

            internal_depth = 6
            ary = b.local_variable_get(name)
            ary.each do |e|
              if M_OBJECT_ID.bind_call(e) == @target_id
                out tp,
                    " #{colorized_target_label} is used as a parameter in #{colorized_name} of #{method_info}",
                    location: caller_locations(internal_depth, 1).first,
                    depth: caller.size - internal_depth - @depth_offset
              end
            end
          when :keyrest
            next if name == :"**"
            internal_depth = 6
            h = b.local_variable_get(name)
            h.each do |k, e|
              if M_OBJECT_ID.bind_call(e) == @target_id
                out tp,
                    " #{colorized_target_label} is used as a parameter in #{colorized_name} of #{method_info}",
                    location: caller_locations(internal_depth, 1).first,
                    depth: caller.size - internal_depth - @depth_offset
              end
            end
          end
        end
      end
    end
  end
end
