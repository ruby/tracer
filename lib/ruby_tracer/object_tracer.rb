# frozen_string_literal: true

require_relative "base"

class ObjectTracer < Tracer::Base
  def initialize obj_id, obj_inspect, **kw
    @obj_id = obj_id
    @obj_inspect = obj_inspect
    super(**kw)
  end

  def key
    [@type, @obj_id, @pattern, @into].freeze
  end

  def description
    "for #{@obj_inspect} #{super}"
  end

  def colorized_obj_inspect
    colorize_magenta(@obj_inspect)
  end

  def setup_tp
    TracePoint.new(:a_call){|tp|
      next if skip?(tp)

      if M_OBJECT_ID.bind_call(tp.self) == @obj_id
        klass = tp.defined_class
        method = tp.method_id
        method_info =
          if klass.singleton_class?
            if tp.self.is_a?(Class)
              ".#{method} (#{klass}.#{method})"
            else
              ".#{method}"
            end
          else
            "##{method} (#{klass}##{method})"
          end

        out tp, " #{colorized_obj_inspect} receives #{colorize_blue(method_info)}"
      elsif !tp.parameters.empty?
        b = tp.binding
        method_info = colorize_blue(minfo(tp))

        tp.parameters.each{|type, name|
          next unless name

          colorized_name = colorize_cyan(name)

          case type
          when :req, :opt, :key, :keyreq
            if b.local_variable_get(name).object_id == @obj_id
              out tp, " #{colorized_obj_inspect} is used as a parameter #{colorized_name} of #{method_info}"
            end
          when :rest
            next if name == :"*"

            ary = b.local_variable_get(name)
            ary.each{|e|
              if e.object_id == @obj_id
                out tp, " #{colorized_obj_inspect} is used as a parameter in #{colorized_name} of #{method_info}"
              end
            }
          when :keyrest
            next if name == :'**'
            h = b.local_variable_get(name)
            h.each{|k, e|
              if e.object_id == @obj_id
                out tp, " #{colorized_obj_inspect} is used as a parameter in #{colorized_name} of #{method_info}"
              end
            }
          end
        }
      end
    }
  end
end
