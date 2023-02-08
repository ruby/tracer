require_relative "../test_helper"

module Tracer
  class ObjectTracerTest < Test::Unit::TestCase
    include ActivationTests

    private

    def build_tracer
      stub_object = Object.new
      ObjectTracer.new(stub_object.object_id, stub_object.to_s)
    end
  end
end
