class Twitter
    def initialize(headers)
        @TWITTER_HEADER = headers
    end

    def gen_img_api(url)
        t_id = url.split("/")[-1]
        ["https://api.twitter.com/2/timeline/conversation/#{t_id}.json", t_id]
    end

    def get_twitter_json(url)
        res = HTTP.headers(@TWITTER_HEADER).get(url)
        res.body
    end

    def get_images_from_tw_json(tw_json, t_id)
        medias = tw_json["globalObjects"]["tweets"]["#{t_id}"]["extended_entities"]["media"]
        images = Array.new()
        medias.each do |media|
            images.push media['media_url']
        end
        images
    end

    def get_text_from_twitter_json(tw_json, t_id)
        tw_json["globalObjects"]["tweets"]["#{t_id}"]['text']
    end 
end