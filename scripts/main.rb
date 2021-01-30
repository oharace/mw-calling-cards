require 'rmagick'

class Main
  class << self
    def extract(dir)
      # system("ffmpeg -y -i #{dir}/#{dir}.webm -vf palettegen #{dir}/palette.png")
      # system("ffmpeg -y -i #{dir}/#{dir}.webm -i #{dir}/palette.png -filter_complex paletteuse -r 10 #{dir}/#{dir}_extracted.gif")
      system("ffmpeg -i #{dir}/#{dir}.webm #{dir}/#{dir}_extracted.gif")

      images = Magick::ImageList.new("#{dir}/#{dir}_extracted.gif")

      puts "images: #{images.count}"

      images.each_with_index do |image, index|
        num =
          if index + 1 < 10
            "00#{index + 1}"
          elsif index + 1 > 99
            index + 1
          else
            "0#{index + 1}"
          end


        image.write("#{dir}/extracted_images/#{num}.png")
      end
    end

    def combine
      titles = []

      File.open('calling_card_titles_and_sources.txt').each do |line|
        split = line.split('@@@')

        next if split[1].include?('.png')

        titles << split[0]
      end

      iteration = 1

      titles.each do |title|
        puts "Combining #{iteration}/#{titles.count}"
        system 'mkdir', '-p', "calling_cards/#{title}/combined_images"
        dir = "calling_cards/#{title}"

        num_images = Dir[File.join("#{dir}/extracted_images", '**', '*')].count { |file| File.file?(file) }
        num_images = (num_images - (num_images % 4)) / 4

        counter = 1

        starts = []
        (num_images / 2).times do |n|
          starts << (8 * n + 1)
          starts << (8 * n + 3)
        end

        if num_images > 4
          starts.each do |n|
            final_image = Magick::ImageList.new

            first_row = Magick::ImageList.new
            second_row = Magick::ImageList.new

            # 1, 2, 5, 6
            # 3, 4, 7, 8
            # 9, 10, 13, 14
            # 11, 12, 15, 16

            num = n

            if num < 10
              first_row.push(Magick::Image.read("#{dir}/extracted_images/00#{num}.png").first)
            elsif num > 99
              first_row.push(Magick::Image.read("#{dir}/extracted_images/#{num}.png").first)
            else
              first_row.push(Magick::Image.read("#{dir}/extracted_images/0#{num}.png").first)
            end

            num = n + 1

            if num < 10
              first_row.push(Magick::Image.read("#{dir}/extracted_images/00#{num}.png").first)
            elsif num > 99
              first_row.push(Magick::Image.read("#{dir}/extracted_images/#{num}.png").first)
            else
              first_row.push(Magick::Image.read("#{dir}/extracted_images/0#{num}.png").first)
            end

            final_image.push(first_row.append(false))

            num = n + 4

            if num < 10
              second_row.push(Magick::Image.read("#{dir}/extracted_images/00#{num}.png").first)
            elsif num > 99
              second_row.push(Magick::Image.read("#{dir}/extracted_images/#{num}.png").first)
            else
              second_row.push(Magick::Image.read("#{dir}/extracted_images/0#{num}.png").first)
            end

            num = n + 5

            if num < 10
              second_row.push(Magick::Image.read("#{dir}/extracted_images/00#{num}.png").first)
            elsif num > 99
              second_row.push(Magick::Image.read("#{dir}/extracted_images/#{num}.png").first)
            else
              second_row.push(Magick::Image.read("#{dir}/extracted_images/0#{num}.png").first)
            end

            final_image.push(second_row.append(false))

            if counter < 10
              final_image.append(true).write("#{dir}/combined_images/final_00#{counter}.png")
            elsif counter > 99
              final_image.append(true).write("#{dir}/combined_images/final_#{counter}.png")
            else
              final_image.append(true).write("#{dir}/combined_images/final_0#{counter}.png")
            end

            counter += 1
          end
        else
          final_image = Magick::ImageList.new

          first_row = Magick::ImageList.new
          second_row = Magick::ImageList.new

          first_row.push(Magick::Image.read("#{dir}/extracted_images/001.png").first)
          first_row.push(Magick::Image.read("#{dir}/extracted_images/002.png").first)
          second_row.push(Magick::Image.read("#{dir}/extracted_images/003.png").first)
          second_row.push(Magick::Image.read("#{dir}/extracted_images/004.png").first)

          final_image.push(first_row.append(false))
          final_image.push(second_row.append(false))

          final_image.append(true).write("#{dir}/combined_images/final_001.png")
        end

        iteration += 1
      end
    end

    def create_gif
      titles = []

      File.open('calling_card_titles_and_sources.txt').each do |line|
        split = line.split('@@@')

        next if split[1].include?('.png')

        titles << split[0]
      end

      iteration = 1

      titles.each do |title|
        puts "Creating GIF #{iteration}/#{titles.count}"

        dir = "calling_cards/#{title}"
        num_images = Dir[File.join("#{dir}/combined_images", '**', '*')].count { |file| File.file?(file) }

        if num_images > 1
          gif = Magick::ImageList.new

          num_images.times do |n|
            if n+1 < 10
              gif << Magick::Image.read("#{dir}/combined_images/final_00#{n+1}.png").first
            elsif n+1 > 99
              gif << Magick::Image.read("#{dir}/combined_images/final_#{n+1}.png").first
            else
              gif << Magick::Image.read("#{dir}/combined_images/final_0#{n+1}.png").first
            end
          end

          # (1..(num_images - 1)).to_a.reverse.each do |n|
          #   if n < 10
          #     gif << Magick::Image.read("#{dir}/combined_images/final_00#{n}.png").first
          #   elsif n > 99
          #     gif << Magick::Image.read("#{dir}/combined_images/final_#{n}.png").first
          #   else
          #     gif << Magick::Image.read("#{dir}/combined_images/final_0#{n}.png").first
          #   end
          # end

          gif.write("#{dir}/#{title.downcase.gsub(' ', '-')}.gif")
        end

        iteration += 1
      end
    end
  end
end

Main.create_gif
