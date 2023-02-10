require "irb/cmd/nop"
require "irb"

module Tracer
  def self.register_irb_commands
    ec = IRB::ExtendCommandBundle.instance_variable_get(:@EXTEND_COMMANDS)

    [
      [:trace, :Trace, nil, [:trace, IRB::ExtendCommandBundle::OVERRIDE_ALL]],
      [
        :trace_call,
        :TraceCall,
        nil,
        [:trace_call, IRB::ExtendCommandBundle::OVERRIDE_ALL]
      ],
      [
        :trace_exception,
        :TraceException,
        nil,
        [:trace_exception, IRB::ExtendCommandBundle::OVERRIDE_ALL]
      ]
    ].each do |ecconfig|
      ec.push(ecconfig)
      IRB::ExtendCommandBundle.def_extend_command(*ecconfig)
    end
  end
end

module IRB
  module ExtendCommand
    class TraceCommand < Nop
      class << self
        def transform_args(args)
          # Return a string literal as is for backward compatibility
          if args.empty? || string_literal?(args)
            args
          else # Otherwise, consider the input as a String for convenience
            args.strip.dump
          end
        end
      end
    end

    class Trace < TraceCommand
      category "Tracing"
      description "Trace the target object (or self) in the given expression. Usage: `trace [target,] <expression>`"

      def execute(*args)
        args = args.first.split(/,/, 2)

        case args.size
        when 1
          target = irb_context.workspace.main
          expression = args.first
        when 2
          target = eval(args.first, irb_context.workspace.binding)
          expression = args.last
        else
          raise ArgumentError,
                "wrong number of arguments (given #{args.size}, expected 1..2)"
        end

        b = irb_context.workspace.binding
        Tracer.trace(target) { eval(expression, b) }
      end
    end

    class TraceCall < TraceCommand
      category "Tracing"
      description "Trace method calls in the given expression. Usage: `trace_call <expression>`"

      def execute(expression)
        b = irb_context.workspace.binding
        Tracer.trace_call { eval(expression, b) }
      end
    end

    class TraceException < TraceCommand
      category "Tracing"
      description "Trace exceptions in the given expression. Usage: `trace_exception <expression>`"

      def execute(expression)
        b = irb_context.workspace.binding
        Tracer.trace_exception { eval(expression, b) }
      end
    end
  end
end

Tracer.register_irb_commands
