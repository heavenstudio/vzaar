require 'vzaar'

login = ''
application_token = ''
server_name = 'vzaar.com'

if (1..3).include? ARGV.size
  login = ARGV[0]
  application_token = ARGV[1] if ARGV.size > 1
  server_name = ARGV[2] if ARGV.size > 2
else
  puts "Usage 1: ruby demo.rb some_vzaar_login"
  puts "Usage 2: ruby demo.rb your_vzaar_login your_vzaar_application_token"
  puts "Usage 3: ruby demo.rb your_vzaar_login your_vzaar_application_token server_name" 
  exit
end

vzaar = Vzaar::Base.new :login => login, :application_token => application_token,
  :server => server_name

if application_token.length > 0
  puts 'Testing whoami call.'
  puts "Whoami: #{vzaar.whoami}"
end

puts "Public videos by #{login}:"
vzaar.video_list(login).each do |video|
  puts video.title
end

if application_token.length > 0
  puts "All videos (public and private) by #{login}:"
  vzaar.video_list(login, true).each do |video|
    puts video.title
  end
end
