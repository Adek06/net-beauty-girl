require 'json'
module WebhookUtils
  def self.get_image_and_content_from_twitter(twitter, text)
    begin
      url = text.split('?')[0]
      t_api, t_id = twitter.gen_img_api url
    rescue NoMethodError
      p "get api from #{text} error"
      return '404'
    end
    res = twitter.get_twitter_json t_api

    begin
      images = twitter.get_images_from_tw_json JSON.parse(res), t_id
    rescue NoMethodError
      p "get images from #{text} error"
      return '404'
    end

    content = twitter.get_text_from_twitter_json JSON.parse(res), t_id
    [images, content]
  end

  def self.send_to_bot(telegram_bot, chat_id, images, content)
    # gen json struct
    media = []
    images.each do |img|
      temp = {}
      temp['type'] = 'photo'
      temp['media'] = img
      media << temp
    end
    media[0]['caption'] = content
    tele_json = {}
    tele_json['chat_id'] = chat_id
    tele_json['media'] = media

    # sent to telegram_bot self
    telegram_bot.send_photos tele_json
    p "send to #{tele_json['chat_id']}"
  end
end