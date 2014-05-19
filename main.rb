# encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true
get '/home'  do
  'Welcome Home to Ruby, again and again, Dave!'
end
