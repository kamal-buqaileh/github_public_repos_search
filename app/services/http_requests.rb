require 'net/http'
class HttpRequests
  def initialize(url, query_params = {}, headers = {}, auth = {}, ssl = true)
    @url = url
    @query_params = query_params
    @ssl = ssl
    @headers = headers
    @auth = auth
  end

  def send_get_request
    uri = URI.parse(@url)
    uri.query = URI.encode_www_form(@query_params)

    Net::HTTP.start(uri.host, uri.port, use_ssl: @ssl) do |http|
      request = Net::HTTP::Get.new uri

      @headers.each do |key, value|
        request[key] = value
      end

      request.basic_auth(@auth['username'], @auth['token']) if @auth.present?
      http.request request
    end
  end
end
