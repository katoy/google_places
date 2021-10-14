# frozen_string_literal: true

require './google_place_id'
require 'pp'
require 'pry'
require 'pry-byebug'

DATA = [
  {
    name: '東急ステイ渋谷', phone: '03-3477-1091', location: [35.6555194, 139.6935628],
    place_id: 'ChIJlfLAC1WLGGARaSL_4dreaAQ'
  },
  {
    name: '東急ステイ 渋谷新南口', phone: '03-5466-0109', location: [35.6555194, 139.6935628],
    place_id: 'ChIJU0rXoVuLGGARun6MkO0mM2Q'
  },
  {
    name: '東急ステイ渋谷 新南口別館', phone: '03-5466-0109', location: [35.6555194, 139.6935628],
    place_id: 'ChIJVVWhwFuLGGAR7ez01kvM6pA'
  },
  # 曖昧な名前
  {
    name: '東急ステイ渋谷 新南', phone: '03-5466-0109', location: [35.6555194, 139.6935628],
    place_id: 'ChIJVVWhwFuLGGAR7ez01kvM6pA'
  },
  # 名前の揺れ
  {
    name: '東急ステイ渋谷新南口別館', phone: '03-5466-0109', location: [35.6555194, 139.6935628],
    place_id: 'ChIJVVWhwFuLGGAR7ez01kvM6pA'
  },
  # 間違った phone
  {
    name: '東急ステイ渋谷新南口別館', phone: '03-1111-1111', location: [35.6555194, 139.6935628],
    place_id: nil
  }
].freeze

client = GooglePlaceId.new

puts '#--- check_csv'
system('cp ^f ./test/test.csv ./test/place_ids.csv')
client.check_csv('./test/place_ids.csv')
rows = client.read_csv('./test/place_ids.csv')
pp rows.map(&:values)

puts '#--- init_csv(rows)'
client.init_csv([])
rows = client.read_csv
pp rows.map(&:values)

puts '#--- write_csv'
rows =
  DATA.map.with_index do |elem, idx|
    {
      rec_id: idx + 1, check: nil,
      name: elem[:name], phone: elem[:phone], place_id: nil, memo: nil,
      enable: true
    }
  end
client.write_csv(rows)
rows = client.read_csv
pp rows.map(&:values)

rows = client.read_csv
pp rows.map(&:values)

puts '#--- update_csv'
client.update_csv
rows = client.read_csv
pp rows.map(&:values)

puts '#--- info_place_id'
info = client.info_place_id(DATA[0][:place_id])
pp info
puts(
  DATA[0][:name] == info[:name] &&
  DATA[0][:phone] == info[:phone] &&
  DATA[0][:location] == info[:location]
)

puts '#--- correct_place_id?(place_id, name, phone)'
puts client.correct_place_id?(DATA[0][:place_id], DATA[0][:name], DATA[0][:phone])

puts '#--- search_place_ids(name, phone)'
DATA.each_with_index do |e, idx|
  ret = client.search_place_ids(e[:name], e[:phone])
  puts("#{idx}, #{e[:name]}, #{e[:phone]}, '#{e[:place_id]}'")
  place_ids = ret.map { |x| x[:place_id] }
  if place_ids == [e[:place_id]].compact
    puts('OK')
  else
    pp ret
  end
end

puts '#--- init_csv(rows)'

puts '#--- update_csv'
