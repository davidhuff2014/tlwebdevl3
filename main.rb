# encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

get '/' do
  if session[:player_name]
    session[:player_name] = ''  #take out after testing
    redirect '/new_player'
    # redirect '/bet'           # add back after testign
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/game' do
  suits = %w(H D C S)
  values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  session[:deck] = suits.product(values).shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  erb :game
end

get '/bet' do
  session[:player_kitty] = 500
  erb :bet
end

post '/bet' do
  session[:bet_amount] = params[:bet_amount]
  redirect '/game'
end
