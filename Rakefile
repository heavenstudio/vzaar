require 'rake'
require 'jeweler'

$LOAD_PATH.unshift('lib')

begin
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "vzaar"
    gemspec.summary = "A gem to be able to use vzaar.com's api with ruby."
    gemspec.description = "A gem to be able to use vzaar.com's api with ruby"
    gemspec.email = "stefano@tailorbirds.com.br"
    gemspec.homepage = "http://github.com/tailorbirds/vzaar"
    gemspec.authors = ["Mariusz Lusiak", "Stefano Diem Benatti"]
    
    gemspec.add_dependency 'oauth', '0.3.6'
    gemspec.add_dependency 'httpclient'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end