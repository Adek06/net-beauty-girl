class ApiController < ActionController::API
    if ENV['BOT_TOKEN']
      BOT_TOKEN = ENV['BOT_TOKEN']
    else
      BOT_TOKEN = ""
    end
    
    if ENV['Cookie']
      TWITTER_HEADER = {"Cookie": ENV['Cookie'], "x-csrf-token":ENV['x-csrf-token'], "authorization": ENV['authorization']}
    else
    
      TWITTER_HEADER = {"Cookie": '', "x-csrf-token": '', "authorization": ''}

    end
end
