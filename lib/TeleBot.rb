class TeleBot
  def initialize(token)
    @BOT_TOKEN = token
  end

  def send_photos(json)
    url = api_config() + '/sendMediaGroup'
    response = HTTP.headers({"Content-Type": "application/json"}).post(url, :json => json)
  end

  def send_message(json)
    url = api_config() + '/sendMessage'
    response = HTTP.headers({"Content-Type": "application/json"}).post(url, :json => json)
  end

  def api_config
    "https://api.telegram.org/bot" + @BOT_TOKEN
  end
end