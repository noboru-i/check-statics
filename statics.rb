#!/usr/bin/env ruby

require 'rexml/document'

def group_by_source(file_path)
  return nil unless File.exist?(file_path)
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

def print_sources(title, sources)
  puts title
  sources.each do |elm|
    puts format("%5d\t%s", elm[1], elm[0])
  end
  puts
end

# execute
checkstyles = {
  'eslint' => 'eslint.xml',
  'scsslint' => 'scsslint.xml',
  'rails best practices' => 'rails_best_practices_output.xml',
  'reek' => 'reek.xml',
  'rubocop' => 'rubocop.xml'
}

checkstyles.each do |title, file_name|
  sources = group_by_source(file_name)
  next if sources.nil?
  print_sources(title, sources)
end

def group_by_file_name(file_path)
  return nil unless File.exist?(file_path)
  doc = REXML::Document.new(open(file_path))

  sources = {}
  doc.elements.each('checkstyle/file') do |file|
    sources[file.attribute('name').to_s] = file.elements.size
  end
  sources.select! do |_, v|
    v != 0
  end
  sources.sort_by { |_, v| v }.reverse
end

checkstyles.each do |title, file_name|
  sources = group_by_file_name(file_name)
  next if sources.nil?
  print_sources(title, sources)
end
