require 'hipchat_ext'
require 'factor/connector/definition'
require 'websockethook'

class HipchatConnectorDefinition < Factor::Connector::Definition
  id :hipchat

  def init_client(params)
    api_key = params.varify(:api_key, name:'API Key', required:true)
    client = HipChat::Client.new(api_key, api_version:'v2')
    client
  end

  resource :room do
    action :send do |params|
      client   = init_client(params)
      room     = params.varify(:room, required:true,is_a:String)
      message  = params.varify(:message, required:true,is_a:String)
      color    = params.varify(:color, one_of:['yellow','green','purple','random'], default:'yellow')
      format   = params.varify(:format, one_of:['html','text'], default:'text')
      notify   = params.varify(:notify, one_of:[true,false], default:false)
      username = params.varify(:username, is_a:String, default:'Factor.io')
      status   = false
      settings = { color: color, format: format }

      settings[:notify] = notify if notify

      begin
        status = client[room].send(username,message,settings)
      rescue => ex
        fail ex.message
      end

      respond status:status
    end

    listener :listen do
      websockethook = WebSocketHook.new
      client        = nil
      room          = nil
      hook          = nil

      start do |params|

        client    = init_client(params)
        room      = params.varify(:room, required:true,is_a:String)
        events    = ['message','notification','exit','enter','topic_change','archived','deleted','unarchived']
        raw_event = params.varify(:event, required:true, default:'message',one_of:events)
        event     = "room_#{raw_event}"
        pattern   = params.varify(:pattern, is_a:String)
        name      = params.varify(:name, is_a:String)

        websockethook.listen do |post|
          case post[:type]
          when 'registered'
            info "WebSocketHook webhook created, setting up webhook in Hipchat"
            hook_url                = post[:data][:url]
            hook_settings           = { event: event, url: hook_url}
            hook_settings[:pattern] = pattern if pattern
            hook_settings[:name]    = name if name

            begin
              hook = client[room].create_web_hook(hook_settings)
            rescue => ex
              fail ex.message
            end
            respond hook
          when 'hook'
            info "Received a web hook on '#{data[:id]}'"
            trigger post[:data]
          when 'close'
            warn 'Hook closed, will restart'
          when 'error'
            error "Error with web hook: #{post[:message]}"
          when 'open'
            info "Web hook now open"
          when 'restart'
            warn "Restarting web hook"
          else
            warn "Unknown state of web hook: #{post[:type]}"
          end
        end
      end

      stop do
        socket_closed = begin
          websockethook.stop
          true
        rescue
          false
        end
        hook_deleted = begin
          client[room].delete_web_hook(hook[:id])
          true
        rescue
          false
        end
        respond socket_closed: socket_closed, hook_deleted: hook_deleted
      end
    end
  end
end