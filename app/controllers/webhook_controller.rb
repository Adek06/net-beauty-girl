class WebhookController < ApiController
  def create
    params = JSON.parse request.body.read
    if not params['message']
      return '404'
    end

    text = params['message']['text']
    if text.match(/^(https|http):\/\/twitter/)
      text = params['message']['text']
      chat = params['message']['chat']
      chat_id = chat['id']
      if chat['username'] != ENV['USERNAME']
        return '404'
      end
      url = text.split('?')[0]
      record = GirlPhotoPost.find_by_url url
      if not record
        twitter = Twitter.new @@TWITTER_HEADER
        images, content = WebhookUtils.get_image_and_content_from_twitter(twitter, text)
        record = GirlPhotoPost.create(url: url, imgs: images, content: content, isPush: false)
      else
        images, content = record.imgs, record.content
      end
      telegram_bot = TeleBot.new ENV['BOT_TOKEN']
      WebhookUtils.send_to_bot(telegram_bot, chat_id, images, content)
      render json: record
    end
  end
end