# coding: utf-8
require 'spec_helper'

def log_dir
  File.expand_path('../log', __FILE__)
end

def base_log(num)
  "#{log_dir}/base-#{num}.log"
end

def single_log
  "#{log_dir}/single.log"
end

def nested_log(num)
  "#{log_dir}/nested-#{num}.log"
end

def thread_log
  "#{log_dir}/thread.log"
end

def include_log?(file, log)
  File.readlines(file).any? { |line| line.include?(log) }
end

def delete_log(file_name)
  File.delete("#{log_dir}/#{file_name}.log") if File.exists?("#{log_dir}/#{file_name}.log")
end

def syms
  %w(debug info warn error fatal)
end

describe Logger do
  before(:all) do
    log_files = Dir.entries(log_dir).select { |e| e.end_with?(".log") }
    log_files.each { |log_file| File.delete("#{log_dir}/#{log_file}") }
  end
  describe "#dup_to" do
    context "on single using" do
      before(:all) do
        logger = Logger.new(base_log(1))
        syms.each do |sym|
          logger.send(sym, "#{sym}-01")
        end
        logger.dup_to(single_log) do
          syms.each do |sym|
            logger.send(sym, "#{sym}-02")
          end
        end
        syms.each do |sym|
          logger.send(sym, "#{sym}-03")
        end
      end
      it "logged all in base.log" do
        lines = File.readlines(base_log(1))
        syms.each do |sym|
          1.upto(3) do |i|
            expect(lines.any? { |line| line.include?("#{sym}-0#{i}") }).to be_true
          end
        end
      end
      it "logged partially in single.log" do
        lines = File.readlines(single_log)
        syms.each do |sym|
          expect(lines.any? { |line| line.include?("#{sym}-01") }).to be_false
          expect(lines.any? { |line| line.include?("#{sym}-02") }).to be_true
          expect(lines.any? { |line| line.include?("#{sym}-03") }).to be_false
        end
      end
    end
    context "on nested using" do
      before(:all) do
        logger = Logger.new(base_log(2))
        syms.each do |sym|
          logger.send(sym, "#{sym}-01")
        end
        logger.dup_to(nested_log(1)) do
          syms.each do |sym|
            logger.send(sym, "#{sym}-02")
          end
          logger.dup_to(nested_log(2)) do
            syms.each do |sym|
              logger.send(sym, "#{sym}-03")
            end
          end
          syms.each do |sym|
            logger.send(sym, "#{sym}-04")
          end
        end
        syms.each do |sym|
          logger.send(sym, "#{sym}-05")
        end
      end
      it "logged all in base.log" do
        lines = File.readlines(base_log(2))
        syms.each do |sym|
          1.upto(5) do |i|
            expect(lines.any? { |line| line.include?("#{sym}-0#{i}") }).to be_true
          end
        end
      end
      it "logged partially in nested-1.log" do
        lines = File.readlines(nested_log(1))
        syms.each do |sym|
          expect(lines.any? { |line| line.include?("#{sym}-01") }).to be_false
          expect(lines.any? { |line| line.include?("#{sym}-02") }).to be_true
          expect(lines.any? { |line| line.include?("#{sym}-03") }).to be_true
          expect(lines.any? { |line| line.include?("#{sym}-04") }).to be_true
          expect(lines.any? { |line| line.include?("#{sym}-05") }).to be_false
        end
      end
      it "logged partially in nested-2.log" do
        lines = File.readlines(nested_log(2))
        syms.each do |sym|
          expect(lines.any? { |line| line.include?("#{sym}-01") }).to be_false
          expect(lines.any? { |line| line.include?("#{sym}-02") }).to be_false
          expect(lines.any? { |line| line.include?("#{sym}-03") }).to be_true
          expect(lines.any? { |line| line.include?("#{sym}-04") }).to be_false
          expect(lines.any? { |line| line.include?("#{sym}-05") }).to be_false
        end
      end
    end
    context "on using in other thread" do
      before(:all) do
        logger = Logger.new(base_log(3))
        logger.info("info-01")
        Thread.new do
          logger.info("info-02")
        end
        logger.dup_to(thread_log) do
          logger.info("info-03")
          Thread.new do
            logger.info("info-04")
          end
        end
        logger.info("info-05")
      end
      it "logged all in base.log" do
        lines = File.readlines(base_log(2))
        1.upto(5) do |i|
          expect(lines.any? { |line| line.include?("info-0#{i}") }).to be_true
        end
      end
      it "logged at same thread in thread.log" do
        lines = File.readlines(thread_log)
        syms.each do |sym|
          expect(lines.any? { |line| line.include?("info-01") }).to be_false
          expect(lines.any? { |line| line.include?("info-02") }).to be_false
          expect(lines.any? { |line| line.include?("info-03") }).to be_true
          expect(lines.any? { |line| line.include?("info-04") }).to be_false
          expect(lines.any? { |line| line.include?("info-05") }).to be_false
        end
      end
    end
  end
end

