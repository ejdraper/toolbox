raise "SPRINKLE_HOST env variable not set!" if ENV.nil? || ENV["SPRINKLE_HOST"].nil?
set :user, "root"
role :app, ENV["SPRINKLE_HOST"], :primary => true