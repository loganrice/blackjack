require 'rubygems'
require 'sinatra'

set :sessions, true

get "/" do
  erb :index
end

post "/" do
  puts "username"
  puts params[:username]
  puts "password"
  puts params[:password]
end

get "/form" do
  erb :form
end

post '/myaction' do
  puts params['username']
end

get "/start" do 
  erb :"login/login"
end
