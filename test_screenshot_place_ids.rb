# frozen_string_literal: true

#
# bundle install --path vendor/bundle
# npm install playwright することが必要
#
# maps/place_ids.csv にある url のスクリーンショットを maps/*.png として保存する。
# url が空だったり、url が不正だと、*-botfound.png として blank イメージを保存する。
#
# open maps/*.png でスクリーンショット群を確認できる。
#
# 注意：
# 　　実行の先頭部分で fm -f maps/*.png 指定している。
#

require 'csv'
require 'playwright'

require 'pp'
require 'pry'
require 'pry-byebug'

csv_file_path = './maps/place_ids.csv'

system('rm -f ./maps/*.png')

Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    page = browser.new_page

    CSV.read(csv_file_path, 'r:BOM|UTF-8', headers: true).each do |row|
      rec = row.to_h
      out_file_path = format('./maps/%<rec_id>04d-%<name>s',
                             rec_id: rec['rec_id'], name: rec['name'].tr(' 　', '_'))
      pp out_file_path

      if rec['url'] == ''
        system("cp -f maps/blank_png #{out_file_path}-notfound.png")
      else
        page.goto(rec['url'])
        # 場所のイメージがあるか否かで url の妥当性を判定している。
        # selectpr path は変動することがあるかもしれない。
        image = page.query_selector('#pane > div > div > div > div > div > div > button > img')
        if image
          page.screenshot(path: out_file_path + '.png')
        else
          system("cp -f maps/blank_png #{out_file_path}-notfound.png")
        end
      end
    end
  end
end
