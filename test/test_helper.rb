# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby_tracer"

require "test-unit"

module Tracer
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
