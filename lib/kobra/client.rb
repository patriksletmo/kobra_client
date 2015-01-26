require 'json/pure'
require 'open-uri'
require 'rest_client'

module Kobra
  class Client

    class BadResponse < RuntimeError; end
    class NotFound < RuntimeError; end
    class AuthError < RuntimeError; end
    class ServerError < RuntimeError; end
    class TimeoutError < RuntimeError; end

    # Kobra::Client.new(:domain => "kobra.ks.liu.se", :username => "john", :api_key => "a3h93hu393")
    def initialize(settings = {})
      settings[:domain] ||= 'kobra.ks.liu.se'
      @base_url = "https://#{settings[:username]}:#{settings[:api_key]}@#{settings[:domain]}/"
    end

    # get_student(:liu_id => 'johec890')
    # Parameters: liu_id, email, personal_number, rfid_number, barcode_number
    def get_student(parameters, timeout=nil)
      json_post('students/api.json', parameters, timeout)
    end

    private

    # Posts to path with parameters, returns JSON with symbols
    def json_post(path, parameters = {}, timeout=nil)
      # Make sure parameters is a Hash
      parameters = {}.merge(parameters)
      url = @base_url + path

      response = RestClient::Request.execute(method: :post, url: url, payload: parameters, timeout: timeout)

      JSON.parse(response.body, :symbolize_names => true)
    rescue JSON::ParserError
      raise BadResponse, "Can't parse JSON"
    rescue RestClient::ResourceNotFound
      raise NotFound, "Resource not found"
    rescue RestClient::Unauthorized
      raise AuthError, "Authentification failed"
    rescue RestClient::InternalServerError
      raise ServerError, "Server error"
    rescue RestClient::RequestTimeout
      raise TimeoutError, "Server didn't respond"
    end
  end
end
