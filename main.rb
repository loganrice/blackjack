require 'rubygems'
require 'sinatra'

set :sessions, true

get "/" do
  if session[:name]

    SUITS = ["Hearts", "Diamonds", "Clubs", "Spades"]
    RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, "ace", "jack", "queen", "king"]
    session[:deck] = SUITS.product(RANKS)
    erb :game
  else
    redirect "login"
  end
end

get "/login" do 
  erb :login
end

post "/" do 
  session[:name] = params[:name]
  redirect "/"
end