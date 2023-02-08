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
    ensure
      File.unlink(file)
    end
  end

  module ActivationTests
    def test_exception_tracer_can_be_started_and_stopped
      tracer = build_tracer
      tracer.start
      assert_equal(true, tracer.started?)
      assert_equal(false, tracer.stopped?)
      tracer.stop
      assert_equal(false, tracer.started?)
      assert_equal(true, tracer.stopped?)
    end
  end
end
