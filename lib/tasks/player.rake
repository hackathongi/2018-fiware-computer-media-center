namespace :player do

  # bin/rails fiware:subscribe[computer,computer,search]
  # bin/rails fiware:subscribe[computer,computer,play]
  #
  task :play => :environment do |task, args|
    Player.new.play
  end

end