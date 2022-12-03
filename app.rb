require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    'Hello World'
  end

  post '/webhook' do
    req_json = JSON.parse(request.body.read)

    # check username is correct
    username = ENV['USERNAME']
    if req_json['message']['chat']['username'] != username
      # 404
      status 404
    end
  end
end
