# frozen_string_literal: true

require_relative "base"

class ExceptionTracer < Tracer::Base
  def setup_tp
    TracePoint.new(:raise) do |tp|
      next if skip?(tp)

      exc = tp.raised_exception

      out tp,
          " #{colorize_magenta(exc.inspect)}",
          depth: caller.size - (1 + @depth_offset)
    rescue Exception => e
      p e
    end
  end

  def skip_with_pattern?(tp)
    super && !tp.raised_exception.inspect.match?(@pattern)
  end
end
