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
    def test_line_tracer_traces_exceptions
      file = write_file("foo.rb", <<~RUBY)
        LineTracer.new(colorize: false).start

        a = 1
        b = 2
      RUBY

      out, err, status = execute_file(file)

      assert_empty(err)
      lines = out.strip.split("\n")
      assert_equal(2, lines.size)
      assert_match(/#depth:1  at .*foo.rb:3/, lines[0])
      assert_match(/#depth:1  at .*foo.rb:4/, lines[1])
    end
  end
end
