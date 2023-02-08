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

  class ObjectTracerIntegrationTest < IntegrationTestCase
    def test_object_tracer_traces_exceptions
      file = write_file("foo.rb", <<~RUBY)
        obj = Object.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        ObjectTracer.new(obj.object_id, obj.inspect, colorize: false).start

        bar(obj)
      RUBY

      out, err, status = execute_file(file)

      assert_empty(err)
      lines = out.strip.split("\n")
      assert_equal(2, lines.size)
      assert_match(
        %r{#depth:4  #<Object:.*> is used as a parameter obj of Object#bar at .*/foo\.rb:7},
        lines.first
      )
      assert_match(
        %r{#depth:3  #<Object:.*> receives \.foo at .*/foo\.rb:3},
        lines.last
      )
    end
  end
end
