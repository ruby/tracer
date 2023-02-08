require_relative "../test_helper"

module Tracer
  class ObjectTracerTest < TestCase
    include ActivationTests

    private

    def build_tracer
      stub_object = Object.new
      ObjectTracer.new(stub_object.object_id, stub_object.to_s, output: @output)
    end
  end
end
