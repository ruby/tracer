# frozen_string_literal: true

require "test-unit"
require "stringio"
require "open3"
require "tempfile"
require "tmpdir"

require_relative "lib/envutil"

require "ruby_tracer"

module Tracer
  class TestCase < Test::Unit::TestCase
    def setup
      @output = StringIO.new
    end
  end

  class IntegrationTestCase < Test::Unit::TestCase
    LIB = File.expand_path("../lib", __dir__)

    def setup
      @dir = Dir.mktmpdir
    end

    def teardown
      FileUtils.remove_entry @dir
    end

    def assert_traces(expected_lines, out)
      lines = out.strip.split("\n")
      assert_equal(
        expected_lines.count,
        lines.size,
        "Expected #{expected_lines.count} lines, got #{lines.size}:\n#{lines.join("\n")}"
      )

      expected_lines.each_with_index do |expected_line, index|
        assert_match(expected_line, lines[index])
      end
    end

    private

    def write_file(name, content)
      file = File.open(File.join(@dir, name), "w")
      file.write(content)
      file.close
      file
    end

    def execute_file(file)
      cmd = [EnvUtil.rubybin, "-I", LIB, "-rruby_tracer", file.to_path]

      stdout, stderr, status = Open3.capture3(*cmd, chdir: @dir)

      assert_equal(0, status, stderr)

      [stdout, stderr]
    ensure
      File.unlink(file)
    end
  end

  module ActivationTests
    def test_tracer_can_be_started_and_stopped
      tracer = build_tracer
      tracer.start
      assert_equal(true, tracer.started?)
      assert_equal(false, tracer.stopped?)
      tracer.stop
      assert_equal(false, tracer.started?)
      assert_equal(true, tracer.stopped?)
    end

    def test_supports_block_format
      in_block_state = nil
      tracer = build_tracer

      assert_equal(false, tracer.started?)

      result =
        tracer.start do
          in_block_state = tracer.started?
          "foo"
        end

      assert_equal(true, in_block_state)
      assert_equal(false, tracer.started?)
      assert_equal("foo", result)
    end
  end
end
