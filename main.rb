# encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true
get '/home'  do
  'Welcome Home to Ruby, again!'
end

get '/form' do
  erb :form
end

post '/myaction' do
  params['username']
end

get '/inline' do
  'Hi frmo the action'
end

get '/template' do
  erb :mytemplate
end

get '/nested_template' do
  erb :'users/profile'
end

get '/nothere' do
  redirect '/inline'
end
