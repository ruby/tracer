require_relative "../test_helper"

module Tracer
  class LineTracerTest < Test::Unit::TestCase
    include ActivationTests

    private

    def build_tracer
      LineTracer.new
    end
  end
end
