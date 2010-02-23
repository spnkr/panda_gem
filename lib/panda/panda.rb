require 'restclient'

module Panda
  class << self
    
    def connect!(auth_params={})
      params = {:api_host => 'api.pandastream.com', :api_port => 80 }.merge(auth_params)
      
      @api_version = 2
      @cloud_id = params["cloud_id"] || params[:cloud_id]
      @access_key = params["access_key"] || params[:access_key]
      @secret_key = params["secret_key"] || params[:secret_key]
      @api_host = params["api_host"] || params[:api_host]
      @api_port = params["api_port"] || params[:api_port]
      
      @prefix = params["prefix_url"] || "v#{@api_version}"
      
      @connection = RestClient::Resource.new(api_url)
    end
    
    def get(request_uri, params={})
      query = signed_query("GET", request_uri, params)
      @connection[request_uri + '?' + query].get
    end

    def post(request_uri, params)
      @connection[request_uri].post(signed_params("POST", request_uri, params))
    end

    def put(request_uri, params)
      @connection[request_uri].put(signed_params("PUT", request_uri, params))
    end

    def delete(request_uri, params={})
      query = signed_query("DELETE", request_uri, params)
      @connection[request_uri + '?' + query].delete
    end
    
    def signed_query(*args)
      ApiAuthentication.hash_to_query(signed_params(*args))
    end
    
    def signed_params(verb, request_uri, params = {}, timestamp_str = nil)
      auth_params = params
      auth_params['cloud_id'] = @cloud_id
      auth_params['access_key'] = @access_key
      auth_params['timestamp'] = timestamp_str || Time.now.iso8601(6)
      auth_params['signature'] = ApiAuthentication.generate_signature(verb, request_uri, @api_host, @secret_key, params.merge(auth_params))
      auth_params
    end
    
    def api_url
      "http://#{@api_host}:#{@api_port}/#{@prefix}"
    end
  end
end
