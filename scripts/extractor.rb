require 'json'
require 'nokogiri'
require 'open-uri'

class Extractor
  SITE = 'https://cod.tracker.gg/warzone/db/loot?c=5&page='
  PAGES = 93

  class << self
    def find_new_calling_cards
      file = File.read('calling_cards.json')
      json = JSON.parse(file)

      existing_card_directories = json.map { |h| h['directory'] }
      new_card_directories = []
      new_cards = []

      (1..PAGES).each do |page_number|
        puts "Page number: #{page_number}"

        doc = Nokogiri::HTML(open("#{SITE}#{page_number}"))

        rows = doc.css('.content table tbody tr')

        rows.each do |row|
          video = row.css('video source')
          image = row.css('img.item-icon__image')
          title = row.css('.item-details a').text.strip
          type = video.empty? ? 'png' : 'webm'

          formatted_title_for_directory = title.gsub(' ', '_').gsub(/\W/, '').downcase
          directory = formatted_title_for_directory

          dir_counter = 1

          # while existing_card_directories.include?(directory)
          #   dir_counter += 1
          #   directory = "#{formatted_title_for_directory}_#{dir_counter}"
          # end

          while new_card_directories.include?(directory)
            dir_counter += 1
            directory = "#{formatted_title_for_directory}_#{dir_counter}"
          end

          new_card_directories << directory

          new_cards << {
            directory: directory,
            title: title,
            type: type,
            url: video.empty? ? image.first['src'] : video.first['src']
          }
        end
      end

      diff = new_card_directories - existing_card_directories
      new_cards.select! { |c| diff.include?(c[:directory]) }

      puts "------------ FINISHED ------------"
      puts "Number of new cards: #{new_cards.count}"
      puts "New Cards:"
      new_cards.each { |nc| puts nc[:directory] }

      new_cards
    end

    def download_media
      file = File.read('calling_cards.json')
      existing_cards = JSON.parse(file)
      new_cards = find_new_calling_cards

      counter = 1
      new_cards.each do |new_card|
        puts "Downloading #{counter}/#{new_cards.count}"

        path = "../public/calling_cards/#{new_card[:directory]}"

        system 'mkdir', '-p', path

        # Download the media
        open("#{path}/#{new_card[:directory].gsub('_', '-')}.#{new_card[:type]}", 'wb') do |file|
          file << open(new_card[:url]).read
        end

        existing_cards << new_card

        counter += 1
      end

      # Update JSON file
      existing_cards.sort_by! { |h| (h[:directory] || h['directory']) }
      File.open('calling_cards.json', 'w') { |file| file.write(existing_cards.to_json) }

      puts "------------ FINISHED DOWNLOADING ------------"

      puts new_cards.count
    end

    def extract_images_from_webm
      file = File.read('calling_cards.json')
      cards = JSON.parse(file)

      directories = cards.select { |c| c['type'] == 'webm' }.map { |c| c['directory'] }
      counter = 1
      extracted = 0

      directories.each do |directory|
        puts "Extracting #{counter}/#{directories.count}"
        counter += 1

        next if File.directory?("../public/calling_cards/#{directory}/extracted_images")

        system 'mkdir', '-p', "../public/calling_cards/#{directory}/extracted_images"
        system 'mkdir', '-p', "../public/calling_cards/#{directory}/combined_images"
        system "ffmpeg", '-i', "../public/calling_cards/#{directory}/#{directory.gsub('_', '-')}.webm", "../public/calling_cards/#{directory}/extracted_images/%03d.png"

        extracted += 1
      end

      puts "------------ FINISHED EXTRACTING ------------"
      puts "Extracted #{extracted} directories"
    end
  end
end

Extractor.download_media
