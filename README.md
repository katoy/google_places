# places API の利用例

## See

- <https://www.mizucoffee.com/archives/1369>
RubyでGoogle Maps Places APIを使おう

## サンプル

```console
 ./.env ファイルを作成して API_KEY=xxxxx で KEY を記載する

$ bundle install --path vendor/bundle
$ bundle exec ruby sample.rb
place_id: ChIJ4eIGNFXmAGAR5y9q5G7BW8U
```

ruby コード (sample.rb からの抜粋)

```ruby
Dotenv.load
client = GooglePlaces::Client.new ENV['API_KEY']

location = [34.7055051, 135.4983028]
x = client.spots(*location)
puts "place_id: #{x[0]['place_id']}"
```
