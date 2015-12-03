#!/usr/bin/env ruby

host = 'https://circleci.com/api/v1/'

require 'yaml'
config = YAML.load_file('setting.yml')

require 'open-uri'
require 'uri'
require 'json'

puts 'get latest repo'
res = open("#{host}project/#{config['user']}/#{config['repo']}?circle-token=#{config['token']}")
p res.status[0]
exit if res.status[0] != '200'

result = JSON.parse(res.read)

latest_build = result.find do |elm|
  elm['branch'] == config['branch'] && elm['status'] == 'success'
end

build_num = latest_build['build_num']

puts 'get artifact list'
res = open("#{host}project/#{config['user']}/#{config['repo']}/#{build_num}/artifacts?circle-token=#{config['token']}")
p res.status[0]
exit if res.status[0] != '200'

result = JSON.parse(res.read)

artifact_names = [
  'brakeman.json',
  'eslint.xml',
  'rails_best_practices_output.xml',
  'reek.xml',
  'rubocop.xml',
  'scsslint.xml'
]
result.each do |elm|
  found = artifact_names.find do |name|
    elm['path'].include? name
  end
  next if found.nil?

  url = elm['url']
  puts "download from #{url}"
  file_name = File.basename(url)
  open(file_name, 'wb') do |output|
    open("#{url}?circle-token=#{config['token']}") do |data|
      output.write(data.read)
    end
  end
end
