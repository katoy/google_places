# frozen_string_literal: true

require './google_place_id'
require 'pp'
require 'pry'
require 'pry-byebug'

client = GooglePlaceId.new

puts '#--- update_csv'
client.check_csv2
rows = client.read_csv
pp rows.map(&:values)
