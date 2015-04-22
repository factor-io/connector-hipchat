require 'spec_helper'

describe HipchatConnectorDefinition do
  describe :room do
    it :send do
      @runtime.run([:room,:send],message:'hi',room:'Factor', api_key:@api_key)
      expect(@runtime).to respond
      data = @runtime.logs.last[:data]
      expect(data).to be_a(Hash)
      expect(data).to include(:status)
      expect(data[:status]).to eq(true)
    end

    it :listen do
      @runtime.start_listener([:room,:listen],event:'message', room:@room, api_key:@api_key)

      expect(@runtime).to respond
      data = @runtime.logs.last[:data]
      @runtime.stop_listener
      expect(@runtime).to respond socket_closed: true, hook_deleted: true
    end
  end
end
