class WebhookController < ApiController
    def create
        params = JSON.parse request.body.read
        p params
        if not params['message']
            return '404'
        end
        chat = params['message']['chat']
        chat_id = chat['id']

        if chat['username'] != 'MrAe06'
            return '404'
        end

        twitter = Twitter.new @@TWITTER_HEADER
        begin
            text = params['message']['text']
            t_api = twitter.gen_img_api text
        rescue NoMethodError
            p "get api from #{text} error"
            return '404'
        end
        url = text.split('?')[0]
        t_api, t_id = twitter.gen_img_api url
        res = twitter.get_twitter_json t_api
        begin
            imgs = twitter.get_imgs_from_tw_json JSON.parse(res), t_id 
        rescue NoMethodError
            p "get imgs from #{text} error"
            return '404'
        end
        media = Array.new()
        imgs.each do |img|
            temp = {}
            temp['type'] = 'photo'
            temp['media'] = img
            media << temp
        end
        # p res
        media[0]['caption'] = twitter.get_text_from_twitter_json JSON.parse(res), t_id 
        # p media
        tele_json = {}
        tele_json['chat_id'] = chat_id
        tele_json['media'] = media
        send_photos tele_json
        p "send to #{tele_json['chat_id']}"
        tele_json['chat_id'] = '-1001251893052'
        send_photos tele_json
        p "send to #{tele_json['chat_id']}"
        "ok"
    end

    def get_update()
        url = api_config()+'/getUpdates'
        response = HTTP.headers({"Content-Type": "application/json"}).get(url)

        # JSON.parse(response.body.to_s)
        # response.body
        # j = JSON.parse(response.body)
    end

    def send_photos(json)
        url = api_config()+'/sendMediaGroup'
        response = HTTP.headers({"Content-Type": "application/json"}).post(url, :json => json)
    end

    def api_config()
        "https://api.telegram.org/bot" + @@BOT_TOKEN
    end
end

class Twitter
    def initialize(headers)
        @TWITTER_HEADER = headers
    end

    def gen_img_api(url)
        t_id = url.split("/")[-1]
        return "https://api.twitter.com/2/timeline/conversation/#{t_id}.json", t_id
    end

    def get_twitter_json(url)
        res = HTTP.headers(@TWITTER_HEADER).get(url)
        res.body
    end

    def get_imgs_from_tw_json(tw_json, t_id)
        # p tw_json
        medias = tw_json["globalObjects"]["tweets"]["#{t_id}"]["extended_entities"]["media"]
        images = Array.new()
        medias.each do |media|
            images.push media['media_url']
        end
        images
    end

    def get_text_from_twitter_json(tw_json, t_id)
        # p tw_json["globalObjects"]["tweets"]["#{t_id}"]['text']
        tw_json["globalObjects"]["tweets"]["#{t_id}"]['text']
    end 
end