require 'net/http'
require 'nokogiri'
require 'securerandom'

def parse_website(url)
  uri = URI(url)
  html_content = Net::HTTP.get(uri)
  
  Nokogiri::HTML(html_content)
end


def get_data(res, user_id)
  doc = parse_website("https://seytaek.com/seasons/active/#{user_id}")

  doc.css('.maps > .map').each { |map|
    data_name = map.attr("data-name")
    map_modal = doc.css('.mapModal.map-' + data_name)

    map_name = map_modal.css('.mapName').text
    map_time_personal = map_modal.css('.mapPersonalTime').text
    map_time_author = map_modal.css('.mapAuthorTime').text
    map_time_gold = map_modal.css('.mapGoldTime').text
    map_time_silver = map_modal.css('.mapSilverTime').text
    map_time_bronze = map_modal.css('.mapBronzeTime').text

    res[map_name] = res[map_name] || {}
    res[map_name][:times] = res[map_name][:times] || {}
    res[map_name][:times][:personal] = res[map_name][:times][:personal] || {}
    res[map_name][:times][:medal] = res[map_name][:times][:medal] || {}

    res[map_name][:times][:author] = map_time_author.strip
    res[map_name][:times][:gold] = map_time_gold.strip
    res[map_name][:times][:silver] = map_time_silver.strip
    res[map_name][:times][:bronze] = map_time_bronze.strip
    res[map_name][:times][:personal][user_id] = map_time_personal.strip

    if map.attr("class").include?("author")
      res[map_name][:times][:medal][user_id] = "author"
    elsif map.attr("class").include?("gold")
      res[map_name][:times][:medal][user_id] = "gold"
    elsif map.attr("class").include?("silver")
      res[map_name][:times][:medal][user_id] = "silver"
    elsif map.attr("class").include?("bronze")
      res[map_name][:times][:medal][user_id] = "bronze"
    else
      res[map_name][:times][:medal][user_id] = "none"
    end
  }
end

user_id_to_name = {
  "0f3cb58e-d8e9-4f83-85ab-af7cad01cbb2": "TheBaniaq",
  "b7ac2724-b9f4-4649-82d6-fe85d0d68c67": "maveron58",
}

res = {}

user_id_to_name.keys.each { |user_id| get_data(res, user_id) }


html_part = """
<table class=\"table table-striped table-hover\">
<thead>
<th>Map name</th>
<th>Author</th>
<th>Gold</th>
<th>Silver</th>
<th>Bronze</th>
"""

user_id_to_name.keys.each { |user_id| html_part += "<th>" + user_id_to_name[user_id] + "</th>\n" }

html_part += "</thead>\n<tbody>\n"

res.keys.sort.each { |map_id|
  html_part += "<tr>"
  html_part += "<td>" + map_id + "</td>\n"
  html_part += "<td>" + res[map_id][:times][:author] + "</td>\n"
  html_part += "<td>" + res[map_id][:times][:gold] + "</td>\n"
  html_part += "<td>" + res[map_id][:times][:silver] + "</td>\n"
  html_part += "<td>" + res[map_id][:times][:bronze] + "</td>\n"

  user_id_to_name.keys.each { |user_id| html_part += "<td>" + res[map_id][:times][:personal][user_id] + " (" + res[map_id][:times][:medal][user_id] + ")</td>\n" }
  html_part += "</tr>"
}

random_hex = SecureRandom.hex(32)

html_part += "</tbody>\n</table>\n"

puts """
<!doctype html>
<html lang=\"en\">
  <head>
    <meta charset=\"utf-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
    <title>Ranking</title>
    <link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-SgOJa3DmI69IUzQ2PVdRZhwQ+dy64/BUtbMJw1MZ8t5HZApcHrRKUc4W0kG879m7\" crossorigin=\"anonymous\">
    <script src=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js\" integrity=\"sha384-k6d4wzSIapyDyv1kpU366/PK5hCdSbCRGRCMv+eplOQJWyd1fbcAu9OCUj5zNLiq\" crossorigin=\"anonymous\"></script>
  </head>
  <body>
    <!-- #{random_hex} -->
    <h1>Ranking</h1>
"""
puts html_part
puts """
  </body>
</html>
"""