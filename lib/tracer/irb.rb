require "irb/cmd/nop"
require "irb"

if Gem::Version.new(IRB::VERSION) < Gem::Version.new("1.6.0")
  warn <<~MSG
    Your version of IRB is too old so Tracer cannot register its commands.
    Please upgrade IRB by adding `gem "irb", "~> 1.6.0"` to your Gemfile.
  MSG

  return
end

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
        if args.empty?
          puts "Please provide the expression to trace. Usage: `trace [target,] <expression>`"
          return
        end

        args = args.first.split(/,/, 2)

        case args.size
        when 1
          target = irb_context.workspace.main
          expression = args.first
        when 2
          target = eval(args.first, irb_context.workspace.binding)
          expression = args.last
        else
          puts "Please provide the expression to trace. Usage: `trace [target,] <expression>`"
          return
        end

        unless expression
          puts "Please provide the expression to trace. Usage: `trace [target,] <expression>`"
          return
        end

        b = irb_context.workspace.binding
        Tracer.trace(target) { eval(expression, b) }
      end
    end

    class TraceCall < TraceCommand
      category "Tracing"
      description "Trace method calls in the given expression. Usage: `trace_call <expression>`"

      def execute(*args)
        expression = args.first

        unless expression
          puts "Please provide the expression to trace. Usage: `trace_call <expression>`"
          return
        end

        b = irb_context.workspace.binding
        Tracer.trace_call { eval(expression, b) }
      end
    end

    class TraceException < TraceCommand
      category "Tracing"
      description "Trace exceptions in the given expression. Usage: `trace_exception <expression>`"

      def execute(*args)
        expression = args.first

        unless expression
          puts "Please provide the expression to trace. Usage: `trace_exception <expression>`"
          return
        end

        b = irb_context.workspace.binding
        Tracer.trace_exception { eval(expression, b) }
      end
    end
  end
end

Tracer.register_irb_commands
