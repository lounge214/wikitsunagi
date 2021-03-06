# サイトにアクセスしgem
require 'open-uri'

# スクレイピングのgem
require 'nokogiri'

# CSV出力するClass
require 'csv'
require "net/http"

class QuestionsController < ApplicationController
    def get_next_link_lst(now_link)
        uri = URI("https://ja.wikipedia.org/w/api.php?")
        params = {  format: 'json',
                    action: 'parse',
                    prop: 'links',
                    page: now_link
        }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        
        body = response.body
        body_hash = JSON.parse(body)

        link_lst = []
        now = body_hash['parse']['title']
        body_hash['parse']['links'].each do |element|
            if element['ns'] == 0
                link_lst.push(element['*'])
            end
        end

        return link_lst
    end

    def verify_answer()
        # params['answer'] = {'first': 'ジョジョの奇妙な冒険', 'second': 'リアル脱出ゲーム', 'third': 'コシノジュンコ', 'forth': '上沼恵美子'}
        # params['answer'] = ['ジョジョの奇妙な冒険', 'リアル脱出ゲーム', 'コシノジュンコ', '上沼恵美子']
        answers = params['answer']
        result = false
        (0..answers.length-2).each do |i|
            ans = answers[i]
            next_ans = answers[i + 1]
            next_link_lst = get_next_link_lst(ans)
            
            if !next_link_lst.include?(next_ans)
                break
            end

            if i == answers.length - 2
                result = true
            end
        end
        render json: result
    end
  
end
