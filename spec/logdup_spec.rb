# coding: utf-8
require 'spec_helper'

def log_dir
  File.expand_path('../log', __FILE__)
end

def log_file(file_name)
  "#{log_dir}/#{file_name}.log"
end

def syms
  %w(debug info warn error fatal)
end

def include_message?(lines, message)
  lines.any? { |line| line.include?(message) }
end

describe Logger do
  before(:all) do
    log_files = Dir.entries(log_dir).select { |e| e.end_with?(".log") }
    log_files.each { |log_file| File.delete("#{log_dir}/#{log_file}") }
  end
  describe "#dup_to" do
    context "on single using" do
      before(:all) do
        logger = Logger.new(log_file("base-on-single"))
        syms.each do |sym|
          logger.send(sym, "#{sym}-01")
        end
        logger.dup_to(log_file("single")) do
          syms.each do |sym|
            logger.send(sym, "#{sym}-02")
          end
        end
        syms.each do |sym|
          logger.send(sym, "#{sym}-03")
        end
      end
      it "logged all in base-on-single.log" do
        lines = File.readlines(log_file("base-on-single"))
        syms.each do |sym|
          1.upto(3) do |i|
            expect(include_message?(lines, "#{sym}-0#{i}")).to be_truthy
          end
        end
      end
      it "logged partially in single.log" do
        lines = File.readlines(log_file("single"))
        syms.each do |sym|
          expect(include_message?(lines, "#{sym}-01")).to be_falsy
          expect(include_message?(lines, "#{sym}-02")).to be_truthy
          expect(include_message?(lines, "#{sym}-03")).to be_falsy
        end
      end
    end
    context "on nested using" do
      before(:all) do
        logger = Logger.new(log_file("base-on-nested"))
        syms.each do |sym|
          logger.send(sym, "#{sym}-01")
        end
        logger.dup_to(log_file("nested-outer")) do
          syms.each do |sym|
            logger.send(sym, "#{sym}-02")
          end
          logger.dup_to(log_file("nested-inner")) do
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
      it "logged all in base-on-nested.log" do
        lines = File.readlines(log_file("base-on-nested"))
        syms.each do |sym|
          1.upto(5) do |i|
            expect(include_message?(lines, "#{sym}-0#{i}")).to be_truthy
          end
        end
      end
      it "logged partially in nested-outer.log" do
        lines = File.readlines(log_file("nested-outer"))
        syms.each do |sym|
          expect(include_message?(lines, "#{sym}-01")).to be_falsy
          expect(include_message?(lines, "#{sym}-02")).to be_truthy
          expect(include_message?(lines, "#{sym}-03")).to be_truthy
          expect(include_message?(lines, "#{sym}-04")).to be_truthy
          expect(include_message?(lines, "#{sym}-05")).to be_falsy
        end
      end
      it "logged partially in nested-inner.log" do
        lines = File.readlines(log_file("nested-inner"))
        syms.each do |sym|
          expect(include_message?(lines, "#{sym}-01")).to be_falsy
          expect(include_message?(lines, "#{sym}-02")).to be_falsy
          expect(include_message?(lines, "#{sym}-03")).to be_truthy
          expect(include_message?(lines, "#{sym}-04")).to be_falsy
          expect(include_message?(lines, "#{sym}-05")).to be_falsy
        end
      end
    end
    context "on using in other thread" do
      before(:all) do
        logger = Logger.new(log_file("base-on-thread"))
        logger.info("info-01")
        t1 = Thread.new do
          logger.info("info-02")
        end
        logger.dup_to(log_file("thread")) do
          logger.info("info-03")
          t2 = Thread.new do
            logger.info("info-04")
          end
          t2.join
        end
        logger.info("info-05")
        t1.join
      end
      it "logged all in base-on-thread.log" do
        lines = File.readlines(log_file("base-on-thread"))
        1.upto(5) do |i|
          expect(include_message?(lines, "info-0#{i}")).to be_truthy
        end
      end
      it "logged at same thread in thread.log" do
        lines = File.readlines(log_file("thread"))
        syms.each do |sym|
          expect(include_message?(lines, "info-01")).to be_falsy
          expect(include_message?(lines, "info-02")).to be_falsy
          expect(include_message?(lines, "info-03")).to be_truthy
          expect(include_message?(lines, "info-04")).to be_falsy
          expect(include_message?(lines, "info-05")).to be_falsy
        end
      end
    end
    context "with buffer_size option" do
      it "output log if size is over buffer" do
        logger = Logger.new(log_file("base-on-buffer"))
        logger.dup_to(log_file("buffer"), buffer_size: 2) do
          logger.info("info-01")
          logger.info("info-02")
          expect(File.exists?(log_file("buffer"))).to be_falsy
          logger.info("info-03")
          expect(File.exists?(log_file("buffer"))).to be_truthy
          lines = File.readlines(log_file("buffer"))
          expect(include_message?(lines, "info-01")).to be_truthy
          expect(include_message?(lines, "info-02")).to be_falsy
          expect(include_message?(lines, "info-03")).to be_falsy
        end
        lines = File.readlines(log_file("buffer"))
        expect(include_message?(lines, "info-01")).to be_truthy
        expect(include_message?(lines, "info-02")).to be_truthy
        expect(include_message?(lines, "info-03")).to be_truthy
      end
    end
  end
end

