# frozen_string_literal: true

require 'dotenv'
require 'google_places'
require 'csv'
require 'pry'

class GoolgePlaceID
  @client = GooglePlaces::Client.new ENV['API_KEY']

  # place_id から hash で :name, :phone, :location [緯度,経度] などを返す
  def info_place(place_id)
    # TODO:
  end

  # place_id が指す場所の name, phone が 引数に name, phone と一致するかを調べる
  def self.correct_place_id?(place_id, name, phone)
    # TODO:
  end

  # name, phone から place_id を求める。
  # 一致するものすべてを Array で返す。
  # 一致するものがなければ [] を返す。
  def self.search_place_ids(name, phone)
    # TODO:
  end

  # ヘッダー行: 'name', 'phone', 'place_code', 'memo', データ行 rows の csv を作る
  def self.init_csv(rows)
    # TODO:
  end

  # csv の place_id 列を更新する。(name, phone 列で検索して)
  # place_id 値に変化があれば、memo に 古い place_id 値を転機する。
  # 変化がなければ、 memo は nil にする。
  # place_id が見つからなければ place_id 列は nil にする。
  # 複数候補があって特定できないときは、place_id は変化させず、memo に複数ヒットしている旨を記載する
  def self.update_csv
    # TODO:
  end
end
