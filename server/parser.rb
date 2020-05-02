require 'json'

countries_file = File.read('all_countries.json')
countries_array = JSON.parse(countries_file, symbolize_names: true)

FLAGS = {}

countries_array.each do |country|
    country_code = country[:alpha2Code].downcase

    FLAGS[country_code.to_sym] = {
        :name => country[:name],
        :image_url => "https://www.countryflags.io/" + country_code + "/flat/64.png"
    }
end

formatted_countries_file = File.write('formatted_countries_file.json', FLAGS.to_json)