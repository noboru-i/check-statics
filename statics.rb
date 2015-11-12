#!/usr/bin/env ruby

require 'rexml/document'

def group_by_source(file_path)
  doc = REXML::Document.new(open(file_path))

  sources = doc.elements.collect('checkstyle/file/error') do |error|
    error.attribute('source')
  end

  sources = sources.each_with_object(Hash.new(0)) do|e, h|
    h[e.to_s] += 1
    h
  end

  sources.sort_by { |_, v| v }.reverse
end

def parse_eslint
  sources = group_by_source('eslint.xml')

  sources.each do |elm|
    puts format("%5d\t%s", elm[1], elm[0])
  end
end

def parse_best_practices
  doc = REXML::Document.new(open('eslint.xml'))
end

# execute
parse_eslint
