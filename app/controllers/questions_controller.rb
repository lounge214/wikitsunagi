require "net/http"
require 'json'
require 'nokogiri'
require 'open-uri'

class QuestionsController < ApplicationController
    # 問題の生成
    def make_question
        render json: get_titles_from_kujirahand
    end

    # 複数のWikipediaのランダムなタイトルを取得
    def get_titles_from_wiki(num=50)
        uri = URI("https://ja.wikipedia.org/w/api.php?")
        params = {  format: 'json',
                    action: 'query',
                    list: 'random',
                    rnnamespace: 0,
                    rnlimit: num
        }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)

        body = response.body
        body_hash = JSON.parse(body)

        titles = {}
        index = 0
        body_hash['query']['random'].each do |elm|
            titles["title#{index}"] = elm["title"]
            index += 1
        end

        return titles.to_json
    end

    # くじらはんどのAPIを利用し, タイトルを取得
    def get_titles_from_kujirahand
        # 対象のURL
        url = "https://kujirahand.com/web-tools/words/api.php?m=random"

        # # NokogiriでURLの情報を取得する
        contents = Nokogiri::HTML.parse(URI.open(url),nil,"utf-8")

        titles = {}
        index = 0
        contents.css('a').each do |link|
            if exist?(link.content)
                titles["title#{index}"] = link.content
                index += 1
            end
        end

        return titles.to_json
    end

    # 生成した単語がWikipediaに存在するか確認
    def exist?(word)
        uri = URI("https://ja.wikipedia.org/w/api.php?")
        params = {  format: 'json',
                    action: 'query',
                    list: 'search',
                    srsearch: word
        }
        uri.query = URI.encode_www_form(params)

        response = Net::HTTP.get_response(uri)

        body = response.body
        body_hash = JSON.parse(body)

        return body_hash['query']['search'][0]['title'] == word
    end
end