require 'json'

system 'rm ../public/*.html'

titles = []
counter = 0

file = File.read('calling_cards.json')
calling_cards = JSON.parse(file)

base_html = '
  <!DOCTYPE html>
  <html lang="en">
  <meta charset="UTF-8">
  <title>Page Title</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootswatch/4.4.1/slate/bootstrap.min.css">
  <body><div class="container" style="max-width: 1920px;">'

index_html = '' + base_html

calling_cards.each do |calling_card|
  dir = "calling_cards/#{calling_card['directory']}"

  if counter % 3 == 0
    index_html << '<div class="row">'
  end

  index_html << "<div class='col-sm-4' style='padding-left: 25px; padding-right: 25px; margin-bottom: 50px; text-align: center;'><h4><a href='../public/#{calling_card['directory']}.html'>#{calling_card['title']}</a></h4>"
  # Gif Exists
  if File.exists?("../public/#{dir}/#{calling_card['directory'].downcase.gsub('_', '-')}.gif")
    index_html << "<img style='width: 400px' src=\"#{dir}/#{calling_card['directory'].downcase.gsub('_', '-')}.gif\"></img>"
  elsif File.exists?("../public/#{dir}/combined_images/final_001.png") # Combined Image Exists
    index_html << "<img style='width: 400px' src=\"#{dir}/combined_images/final_001.png\"></img>"
  else # Original Image Exists
    index_html << "<img style='width: 400px' src=\"#{dir}/#{calling_card['directory'].downcase.gsub('_', '-')}.png\"></img>"
  end

  index_html << '</div>'

  if counter % 3 == 2 # TODO: This does not work if there are not enough to fill the entire row (its not reached)
    index_html << '</div>'
  end

  counter += 1
end

index_html << '</div></body></html>'

File.open('../public/index.html', 'w') { |f| f.write(index_html) }

# Each individual page
calling_cards.each do |calling_card|
  calling_card_html = '' + base_html + "<div style='text-align: center;'><h1>#{calling_card['title']}</h1></div>"

  if calling_card['type'] == 'webm'
    num_images = Dir[File.join("../public/calling_cards/#{calling_card['directory']}/combined_images", '**', '*')].count { |file| File.file?(file) }

    calling_card_html << '<div class="row" style="text-align: center;">'

    num_images.times do |n|
      calling_card_html << "<div class='col-sm-12' style='padding-left: 25px; padding-right: 25px; margin-bottom: 50px; text-align: center;'>"

      num =
        if n < 9
          "00#{n + 1}"
        elsif n > 98
          "#{n + 1}"
        else
          "0#{n + 1}"
        end

      calling_card_html << "<img src=\"calling_cards/#{calling_card['directory']}/combined_images/final_#{num}.png\" />"

      calling_card_html << "</div>"
    end
  else # image
    calling_card_html << "<div class='row' style='text-align: center;'><div class='col-sm-4' style='padding-left: 25px; padding-right: 25px; margin-bottom: 50px; text-align: center;'><img src=\"../public/calling_cards/#{calling_card['directory']}/#{calling_card['title'].downcase.gsub(' ', '-')}.png\" /></div></div>"
  end

  File.open("../public/#{calling_card['directory']}.html", 'w') { |f| f.write(calling_card_html) }
end
