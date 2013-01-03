require 'rubygems'
require 'bundler'
Bundler.require

# if you are using thin, you can take fully advantage of EventMachine by requiring cached_router.rb
require './cached_router.rb'

# otherwise, please requiring the ordinary router.rb
#require './router.rb'

run Sinatra::Application