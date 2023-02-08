require_relative "../test_helper"

module Tracer
  class CallTracerTest < Test::Unit::TestCase
    include ActivationTests

    private

    def build_tracer
      CallTracer.new
    end
  end
end
