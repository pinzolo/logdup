# coding: utf-8
require 'logger'

module Logdup
  class LogDuplication
    attr_reader :device, :logs

    def initialize(device)
      @device = device
      @logs = []
      @thread_id = Thread.current.object_id
    end

    def <<(message)
      @logs << message if @thread_id == Thread.current.object_id
    end

    def output
      logdev = Logger::LogDevice.new(device)
      logs.each do |log|
        logdev.write(log)
      end
    end
  end
end
