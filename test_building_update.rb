# frozen_string_literal: true

require './google_place_id_building'
require 'pp'
require 'pry'
require 'pry-byebug'

client = GooglePlaceIdBuilding.new

client.update_csv
rows = client.read_csv
pp rows.map(&:values)
