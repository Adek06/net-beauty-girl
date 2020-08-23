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
    elsif text.match(/^(https|http):\/\/www.instagram/)
      download_from_ins params
      return
    end
  end
end

def download_from_ins(params)
  text = params['message']['text']
  chat = params['message']['chat']
  chat_id = chat['id']
  if chat['username'] != ENV['USERNAME']
    return '404'
  end
  url = text.split('?')[0] + '?utm_source=ig_web_button_share_sheet'
  res = HTTP.get(url).to_s
  m = res.match(/window._sharedData = (.{1,99999});\<\/script\>/)
  j = JSON.parse(m[1])

  img_list = []
  if j['entry_data']['PostPage'][0]['graphql']['shortcode_media']['edge_sidecar_to_children']
    nodes = j['entry_data']['PostPage'][0]['graphql']['shortcode_media']['edge_sidecar_to_children']['edges']

    nodes.each do |node|
      img_list << node['node']['display_resources'][-1]['src']
    end
  else
    m = res.match(/meta property="og:image" content="(.{1,99999})" \/>/)
    img_list << m[1]
  end

  caption = ''
  if j['entry_data']['PostPage'][0]['graphql']['shortcode_media']['edge_media_to_caption']['edges'][0]
    caption = j['entry_data']['PostPage'][0]['graphql']['shortcode_media']['edge_media_to_caption']['edges'][0]['node']['text']
  end
  record = GirlPhotoPost.create(url: url, imgs: img_list, content: caption, isPush: false)
  media = Array.new()
  img_list.each do |img|
    temp = {}
    temp['type'] = 'photo'
    temp['media'] = img
    media << temp
  end
  media[0]['caption'] = caption
  tele_json = {}
  tele_json['media'] = media
  tele_json['chat_id'] = chat_id
  bot = TeleBot.new ENV['BOT_TOKEN']
  bot.send_photos tele_json
  p "send to #{tele_json['chat_id']}"
  render json: record
end

def download_from_twitter(twitter_header, params)
  text = params['message']['text']
  chat = params['message']['chat']
  chat_id = chat['id']
  if chat['username'] != ENV['USERNAME']
    return '404'
  end

  twitter = Twitter.new twitter_header
  begin
    url = text.split('?')[0]
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