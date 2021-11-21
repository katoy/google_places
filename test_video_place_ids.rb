# frozen_string_literal: true

#
# bundle install --path vendor/bundle
# npm install playwright することが必要
#

require 'csv'
require 'playwright'
require 'tmpdir'

require 'pp'
require 'pry'
require 'pry-byebug'

csv_file_path = './maps/place_ids.csv'

Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    Dir.mktmpdir do |tmp|
      page = nil
      browser.new_context(
        record_video_dir: tmp,
        record_video_size: { 'width': 640 / 2, 'height': 480 / 2 }
      ) do |context|
        page = context.new_page

        CSV.read(csv_file_path, 'r:BOM|UTF-8', headers: true).each do |row|
          rec = row.to_h
          page.goto(rec['url']) if rec['url'] != ''
        end
      end
      page.video.save_as('videos/video.webm')
    end
  end
end
