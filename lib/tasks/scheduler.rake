task :send_reminders => :environment do
  posts = GirlPhotoPost.where(:isPush => false)[0..4]
  posts.each do |post|
    # send to myself
    media = Array.new()
    post.imgs.each do |img|
      temp = {}
      temp['type'] = 'photo'
      temp['media'] = img
      media << temp
    end
    media[0]['caption'] = post.content
    tele_json = {}
    tele_json['chat_id'] = ENV['channel_id']
    tele_json['media'] = media
    bot = TeleBot.new ENV['BOT_TOKEN']
    bot.send_photos tele_json
    p "send #{post.url}"
    post.update!(:isPush => true)
  end
  p "send to #{ENV['channel_id']}"
end