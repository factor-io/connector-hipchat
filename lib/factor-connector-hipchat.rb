require 'factor/connector/definition'
require 'hipchat'

class HipchatConnectorDefinition < Factor::Connector::Definition
  id :hipchat

  def init_client(params)
    api_key = params.varify(:api_key, name:'API Key', required:true)
    client = HipChat::Client.new(api_key, api_version:'v2')
    client
  end

  resource :room do
    action :send do |params|
      client  = init_client(params)
      room    = params.varify(:room, required:true,is_a:String)
      message = params.varify(:message, required:true,is_a:String)
      color   = params.varify(:color, one_of:['yellow','green','purple','random'], default:'yellow')
      format  = params.varify(:format, one_of:['html','text'], default:'text')
      notify  = params.varify(:notify, one_of:[true,false], default:false)
      status  = false

      settings = { color: color, format: format }
      settings[:notify] = notify if notify

      username = 'Skierkowski'

      begin
        status = client[room].send(username,message,settings)
      rescue => ex
        fail ex.message
      end

      respond status:status
    end
  end
end