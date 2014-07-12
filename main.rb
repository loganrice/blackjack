require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    total = 0
    ace_counter = 0
    cards.each do |card|
      suit = card[0]
      rank = card[1]
      if rank.is_a? String
        if rank == "ace"
          ace_counter += 1
          total += 11
        else
          total += 10
        end
      else
        total += rank
      end 
    end

    # adjust for aces
    ace_counter.times do |a|
      if total <= 21
        break
      else
        total -= 10
      end
    end
    total
  end

  def card_path(card)
    suit = card[0]
    rank = card[1]
    "/images/cards/#{suit}_#{rank}.jpg"
  end

  def bust(score)
    score > 21
  end

  def black_jack(score)
    score == 21
  end
end

before do
  @show_buttons = true
end

get "/" do
  if session[:name]
    redirect '/game'
  else
    redirect "/login"
  end
end

get "/login" do 
  erb :login
end

post "/" do 
  session[:name] = params[:name]
  redirect "/game"
end

get "/game" do 
  @show_dealers_cards = false
  suits = ["hearts", "diamonds", "clubs", "spades"]
  ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, "ace", "jack", "queen", "king"]
  @dealers_turn = false
  session[:deck] = suits.product(ranks).shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  erb :game
end

post "/game/player/hit" do
  @show_dealers_cards = false
  session[:player_cards] << session[:deck].pop
  score = calculate_total(session[:player_cards])
  if bust(score)
    @error = "Sorry #{session[:name]} busted."
    @show_buttons = false
  end

  if black_jack(score)
    @win = "#{session[:name]} wins!!"
    @show_buttons = false
  end
  erb :game
end

post "/game/player/stay" do
  @show_buttons = false
  @dealers_turn = true
  @show_dealers_cards = false
  erb :game
end

post '/game/dealer/hit' do
  @display_card = @dealers_turn if @dealers_turn == true
  player_score = calculate_total(session[:dealer_cards])
  dealer_score = calculate_total(session[:dealer_cards])
  while dealer_score <= 17
    session[:dealer_cards] << session[:deck].pop
    dealer_score = calculate_total(session[:dealer_cards])
  end
  
  if bust(dealer_score)
    @win = "#{session[:name]} wins!!"
  elsif player_score > dealer_score
    @win = "#{session[:name]} wins!!"
  else
    @win = "Dealer wins!!"
  end
  @show_buttons = false
  @show_dealers_cards = true
  erb :game
end
