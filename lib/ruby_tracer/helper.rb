require "ruby_tracer"

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
end

Object.include(Tracer::Helper)
