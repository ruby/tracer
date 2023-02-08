require_relative "../test_helper"

module Tracer
  class LineTracerTest < TestCase
    include ActivationTests

    private

    def build_tracer
      LineTracer.new(output: @output)
    end
  end
end
