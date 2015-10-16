#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'  

doc = Nokogiri::HTML(File.open('./spells.txt'))
doc.css('a').each { |a|
  puts a.text
}

