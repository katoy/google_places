# frozen_string_literal: true

require 'dotenv'
require 'google_places'
require 'csv'
require 'pry'

class GooglePlaceId
  GOOGLE_PLACE_ID_LANG = 'ja'

  def initialize
    Dotenv.load
    @client = GooglePlaces::Client.new ENV['API_KEY']
  end

  # place_id から hash で :name, :phone, :location [緯度,経度] などを返す。
  # 不正な place_id なら、 { name: nil, phone: nil, location: [] } を返す。
  def info_place_id(place_id)
    x = @client.spot(place_id, language: GOOGLE_PLACE_ID_LANG)
    { name: x[:name], phone: x[:formatted_phone_number], location: [x[:lat], x[:lng]] }
  rescue StandardError => e
    p e.message
    puts e.backtrace
    { name: nil, phone: nil, location: [] }
  end

  # place_id が指す場所の name, phone が 引数の name, phone と一致するかを調べる。
  def correct_place_id?(place_id, name, phone)
    info = info_place_id(place_id)
    name == info[:name] && phone == info[:phone]
  end

  # name, phone から place_id を求める。
  # 一致するものすべてを Array で返す。({ place_id, :name, :phone } の array)
  # 一致するものがなければ [] を返す。
  def search_place_ids(name, phone)
    ans = []

    x = @client.spots_by_query(name, language: GOOGLE_PLACE_ID_LANG)
    p "#--- #{name}, #{phone}"
    x.each do |elem|
      place_id = elem['place_id']
      z = @client.spot(place_id, language: GOOGLE_PLACE_ID_LANG)
      z_name = z['name']
      z_phone = z['formatted_phone_number']
      if z_phone == phone
        ans << { place_id: place_id, name: z_name, phone: z_phone }
      end
    end
    ans
  rescue StandardError => e
    puts e.message
    puts e.backtrace
    []
  end

  # ヘッダー行: 'name', 'phone', 'place_code', 'memo', データ行 rows の csv を作る。
  def init_csv(rows)
    # TODO:
  end

  # csv の place_id 列を更新する。(name, phone 列で検索して)
  # place_id 値に変化があれば、memo に 古い place_id 値を転機する。
  # 変化がなければ、 memo は nil にする。
  # place_id が見つからなければ place_id 列は nil にする。
  # 複数候補があって特定できないときは、place_id は変化させず、memo に複数ヒットしている旨を記載する。
  def update_csv
    # TODO:
  end
end
