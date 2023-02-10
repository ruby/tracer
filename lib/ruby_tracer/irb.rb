require "irb/cmd/nop"
require "irb"

module IRB
  module ExtendCommand
    class Trace < Nop
      category "Tracing"
      description "Trace the target object in the given expression. `trace [target,] expression`"

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

        Tracer.trace(target) { eval(expression, irb_context.workspace.binding) }
      end
    end
  end
end

ec = IRB::ExtendCommandBundle.instance_variable_get(:@EXTEND_COMMANDS)

[
  [:trace, :Trace, nil, [:trace, IRB::ExtendCommandBundle::OVERRIDE_ALL]]
].each do |ecconfig|
  ec.push(ecconfig)
  IRB::ExtendCommandBundle.def_extend_command(*ecconfig)
end
