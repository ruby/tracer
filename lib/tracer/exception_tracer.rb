# frozen_string_literal: true

require_relative "base"

class ExceptionTracer < Tracer::Base
  def setup_tp
    if RUBY_VERSION >= "3.3.0"
      TracePoint.new(:raise, :rescue) do |tp|
        next if skip?(tp)

        exc = tp.raised_exception

        action = tp.event == :raise ? "raised" : "rescued"

        out tp,
            " #{colorize_magenta(exc.inspect)} #{action}",
            depth: caller.size - (1 + @depth_offset)
      rescue Exception => e
        p e
      end
    else
      TracePoint.new(:raise) do |tp|
        next if skip?(tp)

        exc = tp.raised_exception

        out tp,
            " #{colorize_magenta(exc.inspect)} raised",
            depth: caller.size - (1 + @depth_offset)
      rescue Exception => e
        p e
      end
    end
  end

  def skip_with_pattern?(tp)
    super && !tp.raised_exception.inspect.match?(@pattern)
  end
end
