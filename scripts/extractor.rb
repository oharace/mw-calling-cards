require 'json'
require 'nokogiri'
require 'open-uri'

class Extractor
  SITE = 'https://cod.tracker.gg/warzone/db/loot?c=5&page='

  class << self
    def extract_videos
      video_source_file = File.new('calling_card_titles_and_sources.txt', 'w')

      (1..90).each do |page_number|
        puts "Page number: #{page_number}"

        doc = Nokogiri::HTML(open("#{SITE}#{page_number}"))

        rows = doc.css('tr')

        rows.each do |row|
          video = row.css('video source')

          next if video.empty?

          title = row.css('.item-details a').text

          dir = "calling_cards/#{title}"
          dir_counter = 1

          while File.directory?(dir)
            dir_counter += 1
            dir = "calling_cards/#{title} #{dir_counter}"
          end

          system 'mkdir', '-p', dir

          if dir_counter > 1
            video_source_file.puts "#{title} #{dir_counter}@@@#{video.first['src']}"
          else
            video_source_file.puts "#{title}@@@#{video.first['src']}"
          end
        end
      end

      video_source_file.close
    end

    def extract_images
      video_source_file = File.open('calling_card_titles_and_sources.txt', 'a')

      (1..90).each do |page_number|
        puts "Page number: #{page_number}"

        doc = Nokogiri::HTML(open("#{SITE}#{page_number}"))

        rows = doc.css('tr')

        rows.each do |row|
          image = row.css('img.item-icon__image')

          next if image.empty?

          title = row.css('.item-details a').text

          dir = "calling_cards/#{title}"
          dir_counter = 1

          while File.directory?(dir)
            dir_counter += 1
            dir = "calling_cards/#{title} #{dir_counter}"
          end

          system 'mkdir', '-p', dir

          if dir_counter > 1
            video_source_file.write "#{title} #{dir_counter}@@@#{image.first['src']}"
          else
            video_source_file.write "#{title}@@@#{image.first['src']}"
          end
        end
      end

      video_source_file.close
    end

    def find_missing
      (1..90).each do |page_number|
        puts "Page number: #{page_number}"

        doc = Nokogiri::HTML(open("#{SITE}#{page_number}"))

        rows = doc.css('.content tbody tr')

        found = false

        rows.each do |row|
          video = row.css('video source')
          image = row.css('img.item-icon__image')

          if video.empty? && image.empty?
            puts "FOUND"

            puts row

            found = true
          end

          break if found
        end
      end
    end

    def find_missing_directories
      missing = []
      lines = 0

      File.open('calling_card_titles_and_sources.txt').each do |line|
        lines += 1
        split = line.split('@@@')

        missing << split[0] unless File.directory?("calling_cards/#{split[0]}")  
      end

      puts "lines: #{lines}"
      puts missing.count
      puts missing
    end

    def download
      puts 'Downloading videos'
      puts

      calling_cards = []

      File.open('calling_card_titles_and_sources.txt').each do |line|
        split = line.split('@@@')

        calling_cards << {
          title: split[0],
          url: split[1]
        }
      end

      # Download the videos
      counter = 1
      calling_cards.each do |calling_card|
        puts "Downloading #{counter}/#{calling_cards.count}"

        open("calling_cards/#{calling_card[:title]}/#{calling_card[:title].downcase.gsub(' ', '-')}.webm", 'wb') do |file|
          file << open(calling_card[:url]).read
        end

        counter += 1
      end
    end

    def fix_image_downloads
      calling_cards = []

      File.open('calling_card_titles_and_sources.txt').each do |line|
        split = line.split('@@@')

        next if split[1].include?('.webm')

        calling_cards << {
          title: split[0],
          url: split[1]
        }
      end

      calling_cards.each do |calling_card|
        File.delete("calling_cards/#{calling_card[:title]}/#{calling_card[:title].downcase.gsub(' ', '-')}.webm")

        open("calling_cards/#{calling_card[:title]}/#{calling_card[:title].downcase.gsub(' ', '-')}.png", 'wb') do |file|
          file << open(calling_card[:url]).read
        end
      end
    end

    def extract_images_from_webm
      titles = []
      counter = 1

      File.open('calling_card_titles_and_sources.txt').each do |line|
        split = line.split('@@@')

        next if split[1].include?('.png')

        titles << split[0]
      end

      titles.each do |title|
        puts "Extracting #{counter}/#{titles.count}"

        system 'mkdir', '-p', "calling_cards/#{title}/extracted_images"
        system "ffmpeg", '-i', "calling_cards/#{title}/#{title.downcase.gsub(' ', '-')}.webm", "calling_cards/#{title}/extracted_images/%03d.png"

        counter += 1
      end
    end

    def create_json_file
      calling_cards = []

      File.open('calling_card_titles_and_sources.txt').each do |line|
        split = line.split('@@@')

        h = {}

        h[:directory] = split[0].downcase.gsub(' ', '_').gsub(/\W/, '')

        h[:title] = split[0]

        if split[1].include?('.png')
          h[:type] = 'png'
        else
          h[:type] = 'webm'
        end
        
        h[:url] = split[1]

        calling_cards << h
      end

      calling_cards.sort_by! { |hsh| hsh[:title] }

      json = calling_cards.to_json

      File.open('calling_cards.json', 'w') { |file| file.write(json) }
    end

    def fix_directory_names
      Dir.chdir('calling_cards')
      dirs = Dir.glob('*').select { |f| File.directory? f }

      dirs.each do |dir|
        new_name = dir.downcase.gsub(' ', '_').gsub(/\W/, '')

        system 'mv', "#{dir}/", "#{new_name}/"
      end
    end

    def compare_json_to_dirs
      expected_dirs = []

      file = File.read('calling_cards.json')
      json = JSON.parse(file)

      expected_dirs = json.map { |h| h['directory'] }.sort

      Dir.chdir('calling_cards')
      actual_dirs = Dir.glob('*').select { |f| File.directory? f }.sort

      expected_dirs.each_with_index do |exdir, i|
        if exdir != actual_dirs[i]
          puts "Difference! #{exdir}, #{actual_dirs[i]}"
        end
      end

      puts "count: #{expected_dirs.count}"
      puts "count: #{actual_dirs.count}"
    end
  end
end

Extractor.compare_json_to_dirs
