# frozen_string_literal: true

require 'dotenv'
require 'google_places'
require 'pry'

# ./.env ファイルに API_KEY=xxxxx で KEY を記載する
# $ bundle install --path vendor/bundle
# $ bundle exec ruby sample2.rb

# place_id 検索
#   https://developers.google.com/maps/documentation/places/web-service/place-id
# place_id 確認
#

## "渋谷" "ホテル" などを名前に含むものを幾つか列挙.
## 以下のページなどをつかって place_id, 電話番号、緯度経度などをみつけて設定した。
## https://developers.google.com/maps/documentation/javascript/examples/places-placeid-finder
## https://developers.google.com/maps/documentation/javascript/examples/geocoding-place-id
## https://www.google.co.jp/maps/?hl=ja
# $ https://maps.googleapis.com/maps/api/place/textsearch/json?query=アパホテル 渋谷道玄坂上&key=xxxxxx

# client.spots_by_query('東急ステイ渋谷', language: 'ja') だと 3 件ヒットする。
# "0: 東急ステイ渋谷,            03-3477-1091, ChIJlfLAC1WLGGARaSL_4dreaAQ"
# "1: 東急ステイ 渋谷新南口,     03-5466-0109, ChIJU0rXoVuLGGARun6MkO0mM2Q"
# "2: 東急ステイ渋谷 新南口別館, 03-5466-0109, ChIJVVWhwFuLGGAR7ez01kvM6pA"
#
# この 3 をきちんと区別して、
# place_id から引いた [名前、電話番号] が一致するかを判定する。
# 名前中の SPACE 有無の揺れも吸収して判定する。

def normalize_name(name)
  name.tr(' 　', '')
end

HOTEL_DATA = [
  { name: '渋谷エクセルホテル東急', phone: '03-5457-0109',
    location: [35.6586111, 139.6997222], place_id: 'ChIJTzNfw1eLGGARagCmVhCOmP4' },
  { name: '東急ステイ渋谷', phone: '03-3477-1091',
    location: [35.6555194, 139.6935628], place_id: 'ChIJlfLAC1WLGGARaSL_4dreaAQ' },
  { name: '東急ステイ 渋谷新南口', phone: '03-5466-0109',
    location: [35.6555194, 139.6935628], place_id: 'ChIJU0rXoVuLGGARun6MkO0mM2Q' },
  { name: '東急ステイ渋谷 新南口別館', phone: '03-5466-0109',
    location: [35.6555194, 139.6935628], place_id: 'ChIJVVWhwFuLGGAR7ez01kvM6pA' },
  { name: 'The Millennials Shibuya (ザ・ミレニアルズ 渋谷) デザイナーズホテル 渋谷駅', phone: '050-3164-0748',
    location: [35.6621944, 139.6997456], place_id: 'ChIJceXj8aiMGGAR0uO6fPWvo9Y' },

  # 名前の揺れ
  { name: '東急ステイ渋谷新南口別館', phone: '03-5466-0109',
    location: [35.6555194, 139.6935628], place_id: 'ChIJVVWhwFuLGGAR7ez01kvM6pA' },
  # 間違った place_id
  { name: '東急ステイ渋谷新南口別館', phone: '03-5466-0109',
    location: [35.6555194, 139.6935628], place_id: 'ChIJlfLAC1WLGGARaSL_4dreaAQ' }
].freeze

Dotenv.load
client = GooglePlaces::Client.new ENV['API_KEY']

HOTEL_DATA.map.with_index do |e, idx|
  z = client.spot(e[:place_id], language: 'ja')
  name = z['name']
  phone = z['formatted_phone_number']
  if normalize_name(name) == normalize_name(e[:name]) && phone == e[:phone]
    puts "#{idx}: OK,    #{e[:name]}"
  else
    puts "#{idx}: ERROR, ['#{e[:name]}', #{e[:phone]}] != ['#{name}', #{phone}]"
  end
end
