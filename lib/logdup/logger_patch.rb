# coding: utf-8
require 'logger'
require 'logdup/log_duplication'

class Logger
  alias_method :__format_message__, :format_message

  def dup_to(device, &block)
    duplications << Logdup::LogDuplication.new(device)
    yield(block)
    duplications.pop.output
  end

  private

  def format_message(severity, datetime, progname, msg)
    message = __format_message__(severity, datetime, progname, msg)
    duplications.each do |duplication|
      duplication << message
    end
    message
  end

  def duplications
    @duplications ||= []
  end
end
