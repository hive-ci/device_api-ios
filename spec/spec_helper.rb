# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

ProcessStatusStub    = Struct.new(:exitstatus)
STATUS_ZERO          = ProcessStatusStub.new(0)
STATUS_ONE           = ProcessStatusStub.new(1)
STATUS_TWO_FIVE_FIVE = ProcessStatusStub.new(255)

class String
  def unindent
    gsub(/^\s+/, '')
  end
end
