# frozen_string_literal: true

require 'dotenv'
require 'google_places'
require 'pry'

DATA = [
  { name: '新東京ビル', postal_code: '1000005', location: [35.677537, 139.762668] },
  { name: 'サンシャイン６０', postal_code: '1700013', location: [35.729399, 139.718143] }

].freeze

Dotenv.load
client = GooglePlaces::Client.new ENV['API_KEY']

DATA.each do |d|
  infos = client.spots(*d[:location], name: d[:name], language: 'ja')
  infos.each do |x|
    place_id = x.place_id
    z = client.spot(place_id, language: 'ja')
    if z.postal_code.tr('-', '') == d[:postal_code]
      p "#{z.name}, [#{z.postal_code}]"
    end
  end
end
