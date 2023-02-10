# frozen_string_literal: true

require_relative "ruby_tracer/version"
require_relative "ruby_tracer/line_tracer"
require_relative "ruby_tracer/call_tracer"
require_relative "ruby_tracer/exception_tracer"
require_relative "ruby_tracer/object_tracer"

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

require_relative "ruby_tracer/irb"
