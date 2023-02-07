# frozen_string_literal: true

require_relative "base"

class LineTracer < Tracer::Base
  def setup_tp
    TracePoint.new(:line){|tp|
      next if skip?(tp)
      # pp tp.object_id, caller(0)
      out tp
    }
  end
end
