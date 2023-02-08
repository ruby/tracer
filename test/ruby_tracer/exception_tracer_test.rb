require_relative "../test_helper"

module Tracer
  class ExceptionTracerTest < TestCase
    include ActivationTests

    private

    def build_tracer
      ExceptionTracer.new(output: @output)
    end
  end
end
