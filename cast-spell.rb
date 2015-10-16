#!/usr/bin/env ruby

require 'wordnik'
require 'yaml'
require 'tilt'

Wordnik.configure do |config|
  config.api_key = 'ea70a61690a8b6d00417242c4bf2496222a195c602710ae28'
  #config.logger = Logger.new('/dev/null')
end
 
spells = File.read("spells.txt")
modifiers = ["Epic", "Greater", "Greater Planar", "Lesser", "Minor", "Planar"]

if ! File.exist?("words.yml")
  @cache = {
  }
else
  @cache = YAML::load(File.read("words.yml"))
end 

def file_to_array(f)
  x = []
  File.read(f).each_line { |l|
    x << l.chomp
  }
  x
end

@spells = file_to_array("spells.txt")
def random_spell
  @spells.sample
end


def load_words(type)
  Wordnik.words.get_random_words(:limit => 100,
                                 :min_corpus_count => 5,
                                 :include_part_of_speech => type,
                                 :exclude_part_of_speech => "noun-plural,proper-noun").collect { |x| x["word"] }
end

def word
  @cache[:word] ||= []
  @cache[:word] = @cache[:word] + Wordnik.words.get_random_words(:limit => 100).collect { |x| x["word"] }
  @cache[:word].sample  
end


def noun
  @cache[:noun] ||= []
  @cache[:noun] = @cache[:noun] + load_words('noun')
  @cache[:noun].sample.singularize
end

def nouns
  noun.pluralize
end

def verb
  @cache[:verb] ||= []
  @cache[:verb] = @cache[:verb] + load_words('verb')
  @cache[:verb].sample
end

def adjective
  @cache[:adjective] ||= []
  @cache[:adjective] = @cache[:adjective] + load_words('adjective')
  @cache[:adjective].sample
end

def adverb
  @cache[:adverb] ||= []
  @cache[:adverb] = @cache[:adverb] + load_words('adverb')
  @cache[:adverb].sample
end

def load_colors
  x = []
  File.read("colors.txt").each_line { |l|
    x << l.chomp
  }
  x
end

def load_body_parts
  x = []
  File.read("body_parts.txt").each_line { |l|
    x << l.chomp
  }
  x
end

def load_animals
  x = []
  File.read("animals.txt").each_line { |l|
    x << l.chomp
  }
  x
end


def color
  @colors ||= load_colors
  @colors.sample
end

def animal
  @animals ||= load_animals
  @animals.sample
end

def body_part
  @body_parts ||= load_body_parts
  @body_parts.sample
end

def ing
  @cache[:ing] ||= []
  @cache[:ing] = @cache[:verb].select { |w| w =~ /ing$/ }
  @cache[:ing].sample
end

def roman
  ["I","II","III","IV","V","VI","VII"]
end

require 'tilt/string'
def render(str)
  puts "-- #{str}"
  t = Tilt::StringTemplate.new { str }
  t.render(self).split.map(&:capitalize).join(' ')
end

x = render(random_spell)
if rand(10) > 7
  x = "#{modifiers.sample} #{x}"
end
puts x

File.open('words.yml', 'w') {|f| f.write(@cache.to_yaml) }
