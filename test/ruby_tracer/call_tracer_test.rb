require_relative "../test_helper"

module Tracer
  class CallTracerTest < TestCase
    include ActivationTests

    private

    def build_tracer
      CallTracer.new(output: @output)
    end
  end
end
