class WebhookController < ApiController
  def create
    params = JSON.parse request.body.read
    p params
    if not params['message']
      return '404'
    end

    text = params['message']['text']

    if text.match(/^(https|http):\/\/twitter/)
      download_from_twitter @@TWITTER_HEADER, params
      return
    end
  end
end

def download_from_twitter(twitter_header, params)
  text = params['message']['text']
  chat = params['message']['chat']
  chat_id = chat['id']
  if chat['username'] != ENV['USERNAME']
    return '404'
  end

  url = text.split('?')[0]
  record = GirlPhotoPost.find_by_url url
  if not record
    twitter = Twitter.new twitter_header
    begin
      t_api, t_id = twitter.gen_img_api url
    rescue NoMethodError
      p "get api from #{text} error"
      return '404'
    end
    res = twitter.get_twitter_json t_api
    begin
      imgs = twitter.get_imgs_from_tw_json JSON.parse(res), t_id
    rescue NoMethodError
      p "get imgs from #{text} error"
      return '404'
    end

    content = twitter.get_text_from_twitter_json JSON.parse(res), t_id
    record = GirlPhotoPost.create(url: url, imgs: imgs, content: content, isPush: false)
  end

  # send to myself
  media = Array.new()
  record.imgs.each do |img|
    temp = {}
    temp['type'] = 'photo'
    temp['media'] = img
    media << temp
  end
  media[0]['caption'] = record.content
  tele_json = {}
  tele_json['chat_id'] = chat_id
  tele_json['media'] = media
  bot = TeleBot.new ENV['BOT_TOKEN']
  bot.send_photos tele_json
  p "send to #{tele_json['chat_id']}"
  render json: record
end