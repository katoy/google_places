
require 'dotenv'
require 'google_places'
require 'pry'

# ./.env ファイルに API_KEY=xxxxx で KEY を記載する
# $ bundle install --path vendor/bundle
# $ bundle exec ruby sample.rb

Dotenv.load
client = GooglePlaces::Client.new ENV['API_KEY']

location = [34.7055051, 135.4983028]
x = client.spots(*location)
puts "place_id: #{x[0]['place_id']}"
