# coding: utf-8
require 'logger'

module Logdup
  class LogDuplication
    attr_reader :device, :logs, :async_output, :buffer_size

    def initialize(device, options = {})
      @device = device
      @async_output = options[:async_output] || false
      @buffer_size = options[:buffer_size]
      @logs = []
      @thread_id = Thread.current.object_id
    end

    def <<(message)
      if @thread_id == Thread.current.object_id
        put_first_log_if_size_over
        logs << message
      end
    end

    def output
      @async_output ? output_async : output_sync
    end

    private

    def logdev
      @logdev ||= Logger::LogDevice.new(device)
    end

    def output_sync
      logs.each { |log| logdev.write(log) }
      logdev.close
    end

    def output_async
      Thread.new { output_sync }
    end

    def put_first_log_if_size_over
      if buffer_size && logs.size >= buffer_size
        logdev.write(logs.shift)
      end
    end
  end
end
