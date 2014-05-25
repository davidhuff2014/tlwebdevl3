# encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'

set :sessions, true

BLACKJACK_AMT = 21
DEALER_MIN_HIT = 17

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
      total -= 10 if total > BLACKJACK_AMT
    end
    session[:total] = total
  end

  def card_image(card)
    suit =  case card[0]
            when 'H' then 'hearts'
            when 'D' then 'diamonds'
            when 'S' then 'spades'
            when 'C' then 'clubs'
    end

    value = card[1]
    if %w(J Q K A).include?(value)
      value = case card[1]
              when 'J' then 'jack'
              when 'Q' then 'queen'
              when 'K' then 'king'
              when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
    
  end
end
binding.pry
before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:player_name] != ''
    puts session[:player_name]
    # session[:player_name] = ''    # take out after testing

    session[:player_kitty] = 500
    session[:player_score] = 0
    session[:dealer_score] = 0
    session[:player_cards] = []
    session[:dealer_cards] = []
    session[:player_hits] = false
    session[:dealer_hits] = false
    session[:dealer_turn] = false
    session[:player_turn] = false
    session[:game_over] = false
    # redirect '/new_player'        # change redirect after testing
    redirect '/bet'             # add back after testign

  else
    session[:player_score] = 0
    session[:dealer_score] = 0
    session[:player_kitty] = 500
    session[:player_cards] = []
    session[:dealer_cards] = []
    session[:player_hits] = false
    session[:dealer_hits] = false
    session[:dealer_turn] = false
    session[:player_turn] = false
    session[:game_over] = false

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
    session[:player_stays] = false
    session[:dealer_turn]  = false
    session[:game_over] = false
    session[:dealer_turn] = true if session[:player_score] == BLACKJACK_AMT
# binding.pry
  end

  if session[:player_hits] == true
    session[:player_cards] << session[:deck].pop
    calc_total(session[:player_cards])
    session[:player_score] = session[:total]
    @show_hit_or_stay_buttons = false if session[:player_score] == BLACKJACK_AMT
    @show_hit_or_stay_buttons = false if session[:player_stays] == true

    session[:dealer_turn] = true if session[:player_score] == BLACKJACK_AMT
  end

  if session[:dealer_turn] == true
    while session[:dealer_score] < DEALER_MIN_HIT
      session[:dealer_cards] << session[:deck].pop
      calc_total(session[:dealer_cards])
      session[:dealer_score] = session[:total]
      session[:dealer_turn] = true if session[:dealer_score] == BLACKJACK_AMT
    end
  end

  # need to blow out here if someone goes over BLACKJACK_AMT

  erb :game
end

get '/bet' do
  # session[:player_kitty] = 500
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_score] = 0
  session[:dealer_score] = 0
  if session[:player_kitty] <= 0
    redirect '/game_over'
  end

  erb :bet
end

post '/bet' do
  session[:bet_amount] = params[:bet_amount]
  if session[:bet_amount].to_i > session[:player_kitty].to_i
    @error = 'You are trying to bet more money than you have'
    halt erb(:bet)  
  end
  redirect '/game'
end

post '/game/player/hit' do
  session[:player_hits] = true
  redirect '/game'
end

get '/game_over' do
    session[:player_name] = ''
    session[:player_kitty] == 0   ? session[:end_message] = 'You are out of money'  : ''
    session[:player_kitty] >= 0 ? session[:end_message] = 'Quitting so soon?'     : ''

  erb :game_over
end

post '/game/player/stay' do
  session[:player_hits] = false
  session[:player_stays] = true
  session[:dealer_turn] = true
  @success = 'You have chosen to stay'
  @show_hit_or_stay_buttons = false
  redirect '/game' # my own
  # erb :game # from solution
end
