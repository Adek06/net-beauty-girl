require 'json'
module WebhookUtils
  def self.get_image_and_content_from_twitter(twitter, text)
    url = text.split('?')[0]
    t_api, t_id = twitter.gen_img_api url

    res = twitter.get_twitter_json t_api
    res_json = JSON.parse(res)
    if res_json["errors"] != nil
      return [], res_json['errors'][0]['message']
    end

    images = twitter.get_images_from_tw_json res_json, t_id
    content = twitter.get_text_from_twitter_json res_json, t_id
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
    tele_json = {}
    tele_json['chat_id'] = chat_id
    if media.length == 0
      tele_json['text'] = content
      telegram_bot.send_message tele_json
    p "send text to #{tele_json['chat_id']}"
    else
      media[0]['caption'] = content
      tele_json['media'] = media
      telegram_bot.send_photos tele_json
      p "send medias to #{tele_json['chat_id']}"
    end

    # sent to telegram_bot self
  end
end