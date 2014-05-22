# encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

helpers do
  def calc_total(cards)
    arr = cards.map { |e| e[1] }

    total = 0
    arr.each do |value|
      if value == 'A'
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end

    arr.select { |e| e == 'A' }.count.times do
      total -= 10 if total > 21
    end
    session[:total] = total
  end
end

get '/' do
  if session[:player_name]
    session[:player_name] = ''    # take out after testing

    # redirect '/bet'             # add back after testign
    session[:player_kitty] = 500  # take out after testing
    session[:player_score] = 0
    session[:dealer_score] = 0
    session[:player_cards] = []
    session[:dealer_cards] = []
    session[:player_hits] = false
    redirect '/new_player'        # change redirect after testing
  else
    session[:player_score] = 0
    session[:dealer_score] = 0
    session[:player_kitty] = 500
    session[:player_cards] = []
    session[:dealer_cards] = []
    session[:player_hits] = false
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
  if session[:player_score] == 0
    suits = %w(H D C S)
    values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
    session[:deck] = suits.product(values).shuffle!
    # session[:player_cards] = []
    # session[:dealer_cards] = []
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop

    calc_total(session[:player_cards])
    session[:player_score] = session[:total]
    calc_total(session[:dealer_cards])
    session[:dealer_score] = session[:total]

    session[:player_hits] = false
  end

  if session[:player_hits] == true
    session[:player_cards] << session[:deck].pop
    calc_total(session[:player_cards])
    session[:player_score] = session[:total]
  end

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

post '/game/player/hit' do
  session[:player_hits] = true
  redirect '/game'
  # session[:player_score] == 21  ? session[:end_message] = 'You have won!'         : ''
  # session[:player_kitty] == 0   ? session[:end_message] = 'You are out of money'  : ''
  # session[:player_kitty] >= 500 ? session[:end_message] = 'Quitting so soon?'     : ''

  # redirect '/game_over'
end

get '/game_over' do
  erb :game_over
end

post '/game/player/stay' do
  redirect '/game'
end
