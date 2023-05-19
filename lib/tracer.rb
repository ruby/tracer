# frozen_string_literal: true

require_relative "tracer/version"
require_relative "tracer/line_tracer"
require_relative "tracer/call_tracer"
require_relative "tracer/exception_tracer"
require_relative "tracer/object_tracer"

module Tracer
  module Helper
    DEPTH_OFFSET = 3

    def trace_exception(&block)
      tracer = ExceptionTracer.new(depth_offset: DEPTH_OFFSET)
      tracer.start(&block)
    end

    def trace_call(&block)
      tracer = CallTracer.new(depth_offset: DEPTH_OFFSET)
      tracer.start(&block)
    end

    def trace(target, &block)
      tracer = ObjectTracer.new(target, depth_offset: DEPTH_OFFSET)
      tracer.start(&block)
    end
  end

  extend Helper
end

require_relative "tracer/irb"
