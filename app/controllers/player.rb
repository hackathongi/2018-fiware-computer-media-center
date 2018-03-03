# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class Player
  def initialize
    @files = Dir.glob '/home/oliver/Música/**/*.mp3'
    @rnd= Random.new
  end

  def play(what=nil)
    if what.present?
      audio_file= find(what)
    else
      audio_file= select_random_audio unless what
    end
    cmd= if audio_file.blank?
      %Q[/usr/bin/espeak "Can not play #{what}"]
    else
      %Q[/usr/bin/cvlc "#{audio_file}"]
    end
    Rails.logger.info "EXECUTING CMD: #{cmd}"
    %x[#{cmd}]
  end

  def find(what)
    @files.shuffle.find {|filename|
      filename.match(/#{what}/i)
    }
  end

  def select_random_audio
    idx= @rnd.rand(@files.size)
    @files[idx]
    #    select_dir_or_mp3(@music_path)
  end

  def select_dir_or_mp3(path)
    d= Dir[path]
    puts "d: #{d.entries}"
    idx= @rnd.rand(d.size)
    selection= d.entries[idx]
    puts "selection: #{selection}"
    if File.directory?(selection)
      select_dir_or_mp3(selection)
    elsif File.extname(selection) != '.mp3'
      puts "Not an MP3: #{selection}"
      #      selection= select_dir(path)
    end
    selection
  end
end
