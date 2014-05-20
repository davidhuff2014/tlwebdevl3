# encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

get '/' do
  redirect '/new_game'
end

get '/new_game' do
  erb :'users/new_game'
end

# get '/home'  do
#   'Welcome Home to Ruby, again!'
# end

# get '/form' do
#   erb :form
# end

post '/game' do
  params['username'] # fdoes not display if puts is used afterward
  session[:name] = params[:username]
  session['dealer_score'] = 400
  session['player_score'] = 0
  session['player_cards'] = []
  session['dealer_cards'] = []
  erb :game
  # text =  session[:name]
  # puts text
end

# get '/inline' do
#   'Hi from the action!'
# end

# get '/template' do
#   erb :mytemplate
# end

# get '/nested_template' do
#   erb :'users/profile'
# end

# get '/nothere' do
#   redirect '/inline'
# end
