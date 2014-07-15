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

  def bet(amount)
    @bet = amount.to_i
    session[:money] -= @bet
  end

  def player_wins
    @win = "#{session[:name]} wins!!"
    session[:money] = session[:money] + session[:bet_amount] 
  end

  def player_lose
    session[:money] = session[:money] - session[:bet_amount] 
    @show_buttons = false
  end
end

before do
  @show_buttons = true
  @show_dealers_cards = false
end

get "/bet" do
  session[:bet_amount] = nil
  erb :bet
end

post "/bet" do
  current_bet = params[:bet_amount].to_i
  if current_bet == 0 || current_bet < 0
    @error = "Please enter a valid bet amount"
    halt erb :bet
  elsif current_bet > session[:money]
    @error = "Sorry you do not have enough to bet that amount"
    halt erb :bet
  else
    session[:bet_amount] = current_bet
    redirect '/game'
  end
end


get "/" do
  if session[:name]
    redirect '/game'
  else
    redirect "/login"
  end
end

get "/login" do 
  session[:money] = 1000
  erb :login
end

post "/" do
  unless params[:name] == ""
    session[:name] = params[:name]
    redirect "/bet"
  else
    @error = "Please enter a valid name."
    erb :login
  end
end

get "/game" do 
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
  
  session[:player_cards] << session[:deck].pop
  score = calculate_total(session[:player_cards])
  if bust(score)
    @error = "Sorry #{session[:name]} busted."
    player_lose
  end

  if black_jack(score)
    player_wins
  end
  erb :game, layout: false
end

post "/game/player/stay" do
  @show_buttons = false
  @dealers_turn = true
  @show_dealers_cards = false
  erb :game, layout: false
end

post '/game/dealer/hit' do
  @display_card = @dealers_turn if @dealers_turn == true
  player_score = calculate_total(session[:player_cards])
  dealer_score = calculate_total(session[:dealer_cards])
  while dealer_score <= 17
    session[:dealer_cards] << session[:deck].pop
    dealer_score = calculate_total(session[:dealer_cards])
  end
  
  if bust(dealer_score)
    player_wins
  elsif player_score > dealer_score
    player_wins
  else
    @win = "Dealer wins!!"
    player_lose
  end
  @show_buttons = false
  @show_dealers_cards = true
  erb :game
end
