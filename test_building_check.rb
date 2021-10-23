# frozen_string_literal: true

require './google_place_id_building'
require 'pp'
require 'pry'
require 'pry-byebug'

client = GooglePlaceIdBuilding.new

puts '#--- update_csv'
client.check_csv
rows = client.read_csv
pp rows.map(&:values)
