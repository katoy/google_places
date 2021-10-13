# frozen_string_literal: true

require 'dotenv'
require 'google_places'
require 'csv'

class GooglePlaceId
  GOOGLE_PLACE_ID_LANG = 'ja'

  BOM = "\uFEFF"
  CSV_FILE_PATH = './tmp/place_ids.csv'
  CSV_HEADER = %i[rec_id check name phone place_id url memo].freeze

  attr_reader :csv_rows

  def initialize
    Dotenv.load
    @client = GooglePlaces::Client.new ENV['API_KEY']
    @csv_rows = nil
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

  # ヘッダー行: 'rec_id, name', 'phone', 'place_code', 'memo', データ行 rows の csv を作る。
  def init_csv(data, file_path = CSV_FILE_PATH)
    @csv_rows = write_csv(data, file_path)
    csv_rows_to_array
  end

  # csv の place_id 列を更新する。(name, phone 列で検索して)
  # place_id 値に変化があれば、memo に 古い place_id 値を転機する。
  # 変化がなければ、 memo は nil にする。
  # place_id が見つからなければ place_id 列は nil にする。
  # 複数候補があって特定できないときは、place_id は変化させず、memo に複数ヒットしている旨を記載する。
  def update_csv(file_path = CSV_FILE_PATH)
    data = read_csv(file_path)
    data = data.map { |rec| update_record(rec) }
    write_csv(data, file_path)
  end

  # csv の URL が指す場所の name, phone が name 列、phone 列の値に一致するかを check 列に書き込む
  def check_csv(file_path = CSV_FILE_PATH)
    data = read_csv(file_path)
    data = data.map { |rec| check_record(rec) }
    write_csv(data, file_path)
  end

  # csv の URL が指す場所の name, phone が name 列、phone 列の値に一致するかを check 列に書き込む
  # place_id から引いた name, phone を memo 列に書き出す
  def check_csv2(file_path = CSV_FILE_PATH)
    data = read_csv(file_path)
    data = data.map { |rec| check_record2(rec) }
    write_csv(data, file_path)
  end

  def read_csv(file_path = CSV_FILE_PATH)
    @csv_rows = CSV.read(file_path, 'r:BOM|UTF-8', headers: true)
    csv_rows_to_array
  end

  def write_csv(data, file_path = CSV_FILE_PATH)
    File.open(file_path, 'w') do |file|
      file.print(BOM) # bomを先頭に追加

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

  def update_record(rec)
    place_ids = search_place_ids(rec[:name], rec[:phone])
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
      matchs = place_ids.select { |x| rec[:name] == x[:name] && rec[:phone] == x[:phone] }
      if matchs.size == 1
        rec[:memo] =
          (rec[:place_id] if rec[:place_id] != matchs[0][:placd_icd])
        rec[:place_id] = matchs[0][:place_id]
      else
        rec[:memo] = place_ids.map { |x| "#{x[:place_id]} '#{x[:name]}'" }.join(' | ')
      end
    end

    rec[:check] = nil
    if rec[:place_id]
      rec[:url] = "https://www.google.com/maps/place/?q=place_id:#{rec[:place_id]}"
    end
    rec
  end

  def check_record(rec)
    place_id = rec[:place_id]
    rec[:check] =
      if place_id.to_s == ''
        nil
      else
        info = info_place_id(rec[:place_id])
        p "#{info[:name]} : #{rec[:name]}, #{rec[:phone]}, #{info[:phone]}"
        # (rec[:name] == info[:name]) && (rec[:phone] == info[:phone])
        (rec[:phone] == info[:phone])
      end
    rec
  end

  def check_record2(rec)
    place_id = rec[:place_id]
    rec[:check] =
      if place_id.to_s == ''
        nil
      else
        info = info_place_id(rec[:place_id])
        p "#{info[:name]} : #{rec[:name]}, #{rec[:phone]}, #{info[:phone]}"
        rec[:memo] = "'#{info[:name]}', '#{info[:phone]}']"
        # (rec[:name] == info[:name]) && (rec[:phone] == info[:phone])
        (rec[:phone] == info[:phone])
      end
    rec
  end
end
