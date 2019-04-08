require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default, :development)

require_relative './app/config/api_application'
app = App.new

use Rack::ContentType

app.draw_routes do
  match 'sign_up', 'auth#new'
  post 'register', 'auth#create'
  match ':controller', default: {'action' => 'index'}
end

run app