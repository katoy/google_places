# frozen_string_literal: true

require 'dotenv'
require 'google_places'
require 'csv'

# [ビル名、郵便番号, [緯度、軽度]] <-> place_id
class GooglePlaceIdBuilding
  GOOGLE_PLACE_ID_LANG = 'ja'

  BOM = "\uFEFF"
  CSV_FILE_PATH = './tmp/place_ids_building.csv'
  CSV_HEADER = %i[
    rec_id check postal_code name latitude longitude place_id url memo enable
  ].freeze

  attr_reader :csv_rows

  def initialize
    Dotenv.load
    @client = GooglePlaces::Client.new ENV['API_KEY']
    @csv_rows = nil
  end

  # place_id から hash で :name, : ppstal_code, :location [緯度,経度] などを返す。
  # 不正な place_id なら、 { name: nil, posta_code: nil, location: [] } を返す。
  def info_place_id(place_id)
    x = @client.spot(place_id, language: GOOGLE_PLACE_ID_LANG)
    {
      name: x[:name],
      postal_code: x[:postal_code],
      location: [x[:lat], x[:lng]]
    }
  rescue StandardError => e
    p e.message
    puts e.backtrace
    { name: nil, posta_code: nil, location: [] }
  end

  # place_id が指す場所の name, phone が 引数の name, postal_code と一致するかを調べる。
  def correct_place_id?(place_id, _name, postal_code)
    info = info_place_id(place_id)
    postal_code == info[:postal_code]
  end

  # name, postal_code から place_id を求める。
  # 一致するものすべてを Array で返す。({ :place_id, :name, :postal_code, location } の array)
  # 一致するものがなければ [] を返す。
  def search_place_ids(idx, name, postal_code, location)
    ans = []

    x = @client.spots(*location, name: name, language: GOOGLE_PLACE_ID_LANG)
    p "#--- #{idx}. #{name}, #{postal_code}"
    x.each do |elem|
      place_id = elem['place_id']
      z = @client.spot(place_id, language: GOOGLE_PLACE_ID_LANG)
      z_name = z['name']
      z_postal_code = z['postal_code']&.tr('-', '')
      if z_postal_code == postal_code
        ans << { place_id: place_id, name: z_name, postal_code: z_postal_code }
      end
    end
    ans
  rescue StandardError => e
    puts e.message
    puts e.backtrace
    []
  end

  # ヘッダー行: 'rec_id', 'postal_code', name', 'place_id', 'url', 'memo', 'enable', データ行 rows の csv を作る。
  def init_csv(data, file_path = CSV_FILE_PATH)
    @csv_rows = write_csv(data, file_path)
    csv_rows_to_array
  end

  # csv の place_id 列を更新する。(name, phone 列で検索して)
  # place_id 値に変化があれば、memo に 古い place_id 値を転記する。
  # 変化がなければ、 memo は nil にする。
  # place_id が見つからなければ place_id 列は nil にする。
  # 複数候補があって特定できないときは、place_id は変化させず、memo に複数ヒットしている旨を記載する。
  def update_csv(file_path = CSV_FILE_PATH)
    data = read_csv(file_path)
    data = data.map.with_index { |rec, idx| update_record(idx, rec) }
    write_csv(data, file_path)
  end

  # csv の URL が指す場所の name, postal_code が name 列、postal_code 列の値に一致するかを check 列に書き込む
  def check_csv(file_path = CSV_FILE_PATH)
    data = read_csv(file_path)
    data = data.map.with_index { |rec, idx| check_record(idx, rec) }
    write_csv(data, file_path)
  end

  def read_csv(file_path = CSV_FILE_PATH)
    @csv_rows = CSV.read(file_path, 'r:BOM|UTF-8', headers: true)
    csv_rows_to_array
  end

  def write_csv(data, file_path = CSV_FILE_PATH)
    File.open(file_path, 'w') do |file|
      file.print(BOM) # bom を先頭に追加

      file.puts(CSV_HEADER.map(&:to_s).to_csv(force_quotes: true))
      data.each do |d|
        line = d.keys.map { |key| d[key] }
        file.puts(line.to_csv(force_quotes: true))
      end
    end
  end

  private

  def csv_rows_to_array
    @csv_rows.map(&:to_h).map { |x| x.transform_keys(&:to_sym) }
  end

  def update_record(idx, rec)
    location = [rec[:latitude], rec[:longitude]]
    place_ids = search_place_ids(idx, rec[:name], rec[:postal_code], location)
    if place_ids.empty?
      rec[:memo] =
        if rec[:place_id]
          "not found (before: #{rec[:place_id]})"
        else
          'not found'
        end
      rec[:place_id] = nil
    elsif place_ids.size == 1
      rec[:memo] =
        (rec[:place_id] if rec[:place_id] != place_ids[0][:placd_icd])
      rec[:place_id] = place_ids[0][:place_id]
    else
      matchs = place_ids.select do |x|
        rec[:name] == x[:name] && rec[:postal_code] == x[:postal_code]
      end
      if matchs.size == 1
        rec[:memo] =
          (rec[:place_id] if rec[:place_id] != matchs[0][:placd_icd])
        rec[:place_id] = matchs[0][:place_id]
      else
        rec[:memo] = place_ids.map { |x| "#{x[:place_id]} '#{x[:name]}'" }
                              .join(' | ')
      end
    end

    rec[:check] = nil
    if rec[:place_id]
      rec[:url] =
        "https://www.google.com/maps/place/?q=place_id:#{rec[:place_id]}"
    end
    rec
  end

  def check_record(idx, rec)
    place_id = rec[:place_id]
    rec[:check] =
      if place_id.to_s == ''
        nil
      else
        info = info_place_id(rec[:place_id])
        p "#{idx}, #{info[:name]} : #{rec[:name]}, #{rec[:postal_code]}, #{info[:postal_code]}"
        # (rec[:name] == info[:name]) && (rec[:postal_code] == info[:postal_code])
        (rec[:postal_code] == info[:postal_code]&.tr('-', ''))
      end
    rec
  end
end
