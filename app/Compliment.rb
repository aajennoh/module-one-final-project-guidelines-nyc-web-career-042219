require_relative '../config/environment'
require 'rest-client'
require 'json'
require 'pry'
require_relative '../app/leslie_adjectives.rb'
require_relative '../app/leslie_animals.rb'
require_relative '../app/leslie_end_statements.rb'


class Compliment < ActiveRecord::Base
  has_many :user_compliments
  has_many :users, through: :user_compliments

  def self.get_chuck
    result = []
    response_string = RestClient.get("http://api.icndb.com/jokes/")
    response_hash = JSON.parse(response_string)
    response_hash['value'].each do |joke_hash|
      joke_hash.select do |key, value|
        if key == "joke"
          if !batch_include(value, ["him", "he", "his", "he's", "woodchuck", "dick", "chucktanium.", "chucked.", "testicles", "condom", "penis"])
            result << value
          end
        end
      end
    end
    result
  end


  def self.batch_include(joke, bad_values)
    bad_word = false
    bad_values.select do |bad_value|
      if joke.downcase.include?(bad_value)
        bad_word = true
      end
    end
    bad_word
  end


  def self.customize_chuck(first_name, last_name)
    new_chuck = self.get_chuck.sample.split (' ')
    done_chuck = new_chuck.map do |word|
      if word == "Chuck"
        word = first_name
      elsif word == "Chuck."
        word = "#{first_name}."
      elsif word == "Norris"
        word = last_name
      elsif word == "Norris."
        word = "#{last_name}."
      elsif word == "Norris,"
        word = "#{last_name},"
      elsif word == "Norris,\""
        word = "#{last_name},\""
      elsif word == "Norris'" && last_name.last == 's'
        word = "#{last_name}'"
      elsif word == "Norris'" && last_name.last != 's'
        word = "#{last_name}'s"
      elsif word == "Norris's" && last_name.last == 's'
        word = "#{last_name}'"
      elsif word == "Norris's" && last_name.last != 's'
        word = "#{last_name}'s"
      elsif word == "Norris-related" || word == "norris-related"
        word = "#{last_name}-related"
      else
        word = word
      end
    end
    done_chuck.join(' ')
  end




  def self.get_leslie(first_name, last_name)
    adjective = LeslieAdjective.adjective
    animal = LeslieAnimal.animal
    ending = LeslieEnding.ending
    "Oh #{first_name} #{last_name}, you #{adjective} #{animal}, #{ending}"
  end

  def self.get_compliment(compliment_content)
    find_or_create_by(compliment_content)
  end
end
