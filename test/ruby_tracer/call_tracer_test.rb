require_relative "../test_helper"

module Tracer
  class CallTracerTest < TestCase
    include ActivationTests

    private

    def build_tracer
      CallTracer.new(output: @output)
    end
  end

  class CallTracerIntegrationTest < IntegrationTestCase
    def test_object_tracer_traces_exceptions
      file = write_file("foo.rb", <<~RUBY)
        obj = Object.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        CallTracer.new(colorize: false).start

        bar(obj)
      RUBY

      out, err, status = execute_file(file)

      assert_empty(err)
      lines = out.strip.split("\n")
      assert_equal(5, lines.size)
      assert_match(%r{#depth:2 >  Object#bar at .*/foo\.rb:7}, lines[1])
      assert_match(%r{#depth:3 >   #<Object:.*>\.foo at .*/foo\.rb:3}, lines[2])
      assert_match(
        %r{#depth:3 <   #<Object:.*>\.foo #=> 100 at .*/foo\.rb:5},
        lines[3]
      )
      assert_match(%r{#depth:2 <  Object#bar #=> 100 at .*/foo\.rb:9}, lines[4])
    end
  end
end
