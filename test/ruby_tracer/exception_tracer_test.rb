require_relative "../test_helper"

module Tracer
  class ExceptionTracerTest < Test::Unit::TestCase
    include ActivationTests

    private

    def build_tracer
      ExceptionTracer.new
    end
  end
end
