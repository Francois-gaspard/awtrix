# frozen_string_literal: true

require 'net/http'
require 'json'

module AwtrixControl
  module Request
    private

    def get(path)
      uri = uri(path)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      response.body
    end

    def post(path, payload = {}, query_params = {})
      uri = uri(path, query_params)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      request.body = payload.to_json
      response = http.request(request)
      response.body
    end

    def uri(path, query_params = {})
      query_params = query_params.map { |k, v| "#{k}=#{v}" }.join('&')
      query_params = "?#{query_params}" unless query_params.empty?
      URI("http://#{host}/api/#{path}#{query_params}")
    end
  end
end
