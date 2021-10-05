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

client.spots の返り値の例 (この要素の配列)

```ruby
{
  "geometry"=>{
    "location"=>{"lat"=>34.6937249, "lng"=>135.5022535},
    "viewport"=>{
      "northeast"=>{"lat"=>34.76875897533456, "lng"=>135.5991691752138},
      "southwest"=>{"lat"=>34.58643723929236, 
      "lng"=>135.3729054617143
      }
    }
  }, 
  "icon"=>"https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png",
  "icon_background_color"=>"#7B9EB0",
  "icon_mask_base_uri"=>"https://maps.gstatic.com/mapfiles/place_api/icons/v2/generic_pinlet", 
  "name"=>"Osaka", 
  "photos"=>[
    {
      "height"=>530,
      "html_attributions"=>[
        "<a href=\"https://maps.google.com/maps/contrib/103812912990273720643\">Danya</a>"
      ], "photo_reference"=>"Aap_uEARQlZAyO5nhuFQyDbX9Vzbcf_JvzQfJi2VYBT6Y0c4sGxst857u13z7L0INHhobMH_soE2gvldfJzg1jtkxK9roNDcSTECECGLpRxt8HKdtLMA4-Ms8vnJu--WH7c-YlEj0F0dRz7vXpCYAGzarD-WzIcLh2aAch5ghcUP0VVn5xkI", "width"=>800
    }
  ],
  "place_id"=>"ChIJ4eIGNFXmAGAR5y9q5G7BW8U", "reference"=>"ChIJ4eIGNFXmAGAR5y9q5G7BW8U", 
  "scope"=>"GOOGLE", 
  "types"=>["locality", "political"], 
  "vicinity"=>"Osaka"
},
@reference="ChIJ4eIGNFXmAGAR5y9q5G7BW8U", 
@place_id="ChIJ4eIGNFXmAGAR5y9q5G7BW8U", 
@vicinity="Osaka", 
@lat=34.6937249, 
@lng=135.5022535, 
@viewport={
  "northeast"=>{
    "lat"=>34.76875897533456,
    "lng"=>135.5991691752138
  }, 
  "southwest"=>{"lat"=>34.58643723929236, "lng"=>135.3729054617143}
}, 
@name="Osaka", 
@icon="https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png", 
@types=["locality", "political"], 
@id=nil,
@formatted_phone_number=nil, @international_phone_number=nil, 
@formatted_address=nil, 
@address_components=nil, 
@street_number=nil, 
@street=nil, 
@city=nil, 
@region=nil, 
@postal_code=nil, 
@country=nil,
@rating=nil,
@price_level=nil,
@opening_hours=nil,
@url=nil,
@cid=0,
@website=nil,
@zagat_reviewed=nil,
@zagat_selected=nil, 
@aspects=[],
@review_summary=nil, 
@photos=[
  #<GooglePlaces::Photo:0x00007fb7781d3328 @width=800,
  @height=530, @photo_reference="Aap_uEARQlZAyO5nhuFQyDbX9Vzbcf_JvzQfJi2VYBT6Y0c4sGxst857u13z7L0INHhobMH_soE2gvldfJzg1jtkxK9roNDcSTECECGLpRxt8HKdtLMA4-Ms8vnJu--WH7c-YlEj0F0dRz7vXpCYAGzarD-WzIcLh2aAch5ghcUP0VVn5xkI",
  @html_attributions=[
    "<a href=\"https://maps.google.com/maps/contrib/103812912990273720643\">Danya</a>"
  ],
  @api_key="AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxx">
],
@reviews=[],
@nextpagetoken=nil,
@events=[],
@utc_offset=nil,
@permanently_closed=nil
```
