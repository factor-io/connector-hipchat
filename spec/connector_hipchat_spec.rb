require 'spec_helper'

describe HipchatConnectorDefinition do
  before do
    @api_key = ENV['HIPCHAT_API_KEY']
    @runtime = Factor::Connector::Runtime.new(HipchatConnectorDefinition)
  end
  describe :room do
    it :send do
      @runtime.run([:room,:send],message:'hi',room:'Factor', api_key:@api_key)
      expect(@runtime).to respond
      data = @runtime.logs.last[:data]
      expect(data).to be_a(Hash)
      expect(data).to include(:status)
      expect(data[:status]).to eq(true)
    end
  end
end
