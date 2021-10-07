
require 'dotenv'
require 'google_places'
require 'pry'

# ./.env ファイルに API_KEY=xxxxx で KEY を記載する
# $ bundle install --path vendor/bundle
# $ bundle exec ruby sample.rb

Dotenv.load
client = GooglePlaces::Client.new ENV['API_KEY']

# location = [34.7055051, 135.4983028]
# location = [35.626531,  139.724399]
# location = [35.626562,  139.724450]
location = [35.6251822197085, 139.7230501197085]
### 少しぐらい緯度・軽度がずれていてもヒットする。
# x = client.spots(*location, formatted_phone_number: "03-5798-2511")
x = client.spots(*location, name: "ビッグエコー五反田東口駅前店", language: 'ja')
x.each {|e| puts e.vicinity }
puts "place_id: #{x[0]['place_id']}, nanem: x[0]['name']"

### 少しぐらい名前が不完全でもヒットする
x = client.spots_by_query('エコー五反田東口駅前店', language: 'ja')
x.each {|e| puts e.vicinity }
puts "place_id: #{x[0]['place_id']}, name: #{x[0]['name']}"

### place_id で検索する
x = client.spot('ChIJ77xIjPmKGGAREiUUOMgnzCI', language: 'ja')
# pp x
puts "place_id: #{x['place_id']}, name: #{x['name']}, phone: #{x['formatted_phone_number']}"
