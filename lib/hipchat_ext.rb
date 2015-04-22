require 'hipchat'

module HipChat
  class Room
    def web_hooks
      url = URI::escape("/#{room_id}/webhook")
      options = { query: { auth_token: @token }, headers: @api.headers }
      response = self.class.get(url,options)
      symbolize(JSON.parse(response.body)['items'])
    end

    def create_web_hook(settings = {})
      url = URI::escape("/#{room_id}/webhook")
      options = {query: { auth_token: @token}, body:{}, headers:@api.headers }
      options[:body][:url]     = settings[:url]
      options[:body][:event]   = settings[:event]
      options[:body][:pattern] = settings[:pattern] if settings[:pattern]
      options[:body][:name]    = settings[:name] if settings[:name]
      options[:body] = options[:body].to_json

      begin
        response = self.class.post(url,options)
      rescue
        raise "Couldn't create web hook for unkown reason"
      end
      
      raise response['error']['message'] if response['error']

      response[:url] = settings[:url]
      symbolize(response)
    end

    def delete_web_hook(hook_id)
      url = URI::escape("/#{room_id}/webhook/#{hook_id}")
      options = { query: { auth_token: @token }, headers: @api.headers }
      begin
        self.class.delete(url, options)
      rescue
        false
      end
      true
    end
  end
end