
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
#$ https://maps.googleapis.com/maps/api/place/textsearch/json?query=アパホテル 渋谷道玄坂上&key=xxxxxx

HOTEL_DATA = [
  { name: '渋谷エクセルホテル東急', phone: '03-5457-0109',
    location: [35.6586111, 139.6997222], place_id: 'ChIJTzNfw1eLGGARagCmVhCOmP4',
  },
  { name: '東急ステイ渋谷', phone: '03-3477-1091',
    location: [35.6555194, 139.6935628], place_id: 'ChIJlfLAC1WLGGARaSL_4dreaAQ',
  },
  { name: 'The Millennials Shibuya (ザ・ミレニアルズ 渋谷) デザイナーズホテル 渋谷', phone: '050-3164-0748',
    location: [35.6621944, 139.6997456], place_id: 'ChIJceXj8aiMGGAR0uO6fPWvo9Y',
  },
  { name: '渋谷東急REIホテル', phone: '03-3498-0109',
    location: [35.6602231, 139.7019877], place_id: 'ChIJXfQKCFiLGGARTKbWjWk1usw',
  },
  { name: 'アパホテル 渋谷道玄坂上', phone: '03-6416-7111',
    location: [35.6562037, 139.6948706], place_id: 'ChIJaaJ8wFWLGGARVuLoeIa_Tp0',
  },
  { name: 'ホテル渋谷存在しない', phone: '03-1111-1111',
    location: [35.6562037, 139.6948706], place_id: nil,
  },
]

Dotenv.load
client = GooglePlaces::Client.new ENV['API_KEY']
# x = client.spots_by_query('渋谷エクセルホテル東急', language: 'ja') 
# p x

puts '# ----- 名前と電話番号から google place API をつかって place_id を求める'
place_ids =
  HOTEL_DATA.map do |e|
    begin
      ans = nil

      name = e[:name]
      x = client.spots_by_query(name, language: 'ja')
      if x.size == 1
        ans = x[0]['place_id']
        puts "#{name}, #{x[0]['name']}" if x.size == 1
      end

      puts '# --- no multiple' if x.size == 0
      if x.size > 1
        items  = []
        puts "# ---- hit multiple #{name}"
        items  = []
        x.each do |e1|
          place_id = e1['place_id']
          z = client.spot(place_id, language: 'ja')
          if z['formatted_phone_number'] == e[:phone]
            items << [e1, z]
          end
        end
        puts '# ------ no match phone' if items.size == 0
        if items.size == 1
          ans = items[0][1]['place_id']
          puts "A    #{name}, #{items[0][1]['formatted_phone_number']}"
        end
        if items.size > 1
          ans = items[0][1]['place_id']
          puts "B    #{name}, #{items[0][1]['formatted_phone_number']}" 
        end
      end
      ans
    rescue => e
      puts e.message
      puts e.backtrace
      nil
    end
  end

puts
puts '# ----- みつけた place_id と事前に設定していた place_id が一致するかを調べる'
HOTEL_DATA.each_with_index do |e, idx|
  if e[:place_id] != place_ids[idx]
    puts "ERROR #{e[:name]}" 
  else
    puts "OK    #{e[:name]}" 
  end
end
