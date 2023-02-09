require_relative "../test_helper"

module Tracer
  class LineTracerTest < TestCase
    include ActivationTests

    private

    def build_tracer
      LineTracer.new(output: @output)
    end
  end

  class LineTracerIntegrationTest < IntegrationTestCase
    def test_line_tracer_traces_line_executions
      file = write_file("foo.rb", <<~RUBY)
        LineTracer.new.start

        a = 1
        b = 2
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces([/#depth:1  at .*foo.rb:3/, /#depth:1  at .*foo.rb:4/], out)
    end
  end
end
