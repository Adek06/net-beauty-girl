require_relative '../../lib/WebhookUtils'
require "test/unit"

class Twitter
  def initialize(headers)
    @TWITTER_HEADER = headers
  end

  def gen_img_api(url)
    ["https://api.twitter.com/2/timeline/conversation.json", 1]
  end

  def get_twitter_json(url)
    "{}"
  end

  def get_images_from_tw_json(tw_json, t_id)
    %w[a.jpg b.jpg]
  end

  def get_text_from_twitter_json(tw_json, t_id)
    "{}"
  end
end

class TeleBot
  def initialize(token)
    @BOT_TOKEN = token
  end

  def send_photos(json) end

  def api_config
  end
end

class TestWebhookUtil < Test::Unit::TestCase

  def test_get_image_and_content_from_twitter
    twitter = Twitter.new("")
    assert_equal([%w[a.jpg b.jpg], "{}"], WebhookUtils.get_image_and_content_from_twitter(twitter, ""))
  end

  def test_send_to_bot
    telegram_bot = TeleBot.new("")
    chat_id, images, content = "1", %w[a.jpg b.jpg], ""
    WebhookUtils.send_to_bot(telegram_bot = telegram_bot,
                             chat_id = chat_id,
                             images = images,
                             content = content)
  end
end