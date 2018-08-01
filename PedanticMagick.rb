#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'
require 'wordnik'
require 'yaml'
require 'tilt'
require 'namey'
require 'possessive'
require 'linguistics'


Wordnik.configure do |w|
  w.api_key = bot.config[:wordnik_key]
  w.logger = Logger.new('/dev/null')
end

spells = File.read("spells.txt")

@cache = {}

@spooky = %w(Spoopy Spooky Scary Eldritch Terrifying Eerie Frightening Macabre Horrifying Macabre Disturbing Alarming)

def file_to_array(f)
  x = []
  File.read(f).each_line { |l|
    x << l.chomp
  }
  x
end

def random_spell
  file_to_array("spells.txt").sample
end

def random_item
  file_to_array("items.txt").sample
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


def load_colors
  x = []
  File.read("colors.txt").each_line { |l|
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

def _ing
  Linguistics.use( :en )
  verb

  v = @cache[:verb].sample
  v.en.infinitive.en.present_participle
end

def tion
  noun
  x = @cache[:noun].select { |w| w =~ /tion$/ || w =~ /sion$/ || w =~ /cion$/ }.sample
  raise StandardError.new("no tion's") if x.strip.blank?
  x
end

def ism
  noun
  x = @cache[:noun].select { |w| w =~ /ism$/}.sample
  raise StandardError.new("no ism's") if x.strip.blank?
  x
end

def ness
  noun
  x = @cache[:noun].select { |w| w =~ /ity$/ || w =~ /ness$/}.sample
  raise StandardError.new("no ness's") if x.strip.blank?
  x
end

def ing
  t = 0
  x = _ing
  while t < 10 && x == "ing"
    x = _ing
    t = t + 1
  end

  raise StandardError.new("no ing") if x == "ing" || x.strip.blank?
  x
end

def roman
  ["I","II","III","IV","V","VI","VII"].sample
end

def ity
  ness
  # noun
  # x = @cache[:noun].select { |w| w =~ /ity$/ || w =~ /ness$/ }.sample
  # raise StandardError.new("no ity's") if x.nil?

  # # _ity or _iness really
end


require 'tilt/string'
def render(str)
  t = Tilt::StringTemplate.new { str }
  t.render(self).split.map(&:capitalize).join(' ')
end

def cast_spell
  x = render(random_spell)

  if rand(100) > 85
    generator = Namey::Generator.new
    name = generator.generate(with_surname: false, min_freq:10, max_freq:100)
    x = "#{name.possessive} #{x}"
  end

  x
end

def magick_item
  render(random_item)
end

ok_to_tweet = false
while ok_to_tweet == false do
  output = if rand(100) > 50
             magick_item
           else
             cast_spell
           end

  ok_to_tweet = bad_words.select { |w|
    output.downcase.include?(w)
  }.empty?
end

if ok_to_tweet
#  if rand(100) > 50 
#    output = [@spooky.sample, output].join(" ")
#  end

  tweet output

  File.open('words.yml', 'w') {|f| f.write(@cache.to_yaml) }
end
