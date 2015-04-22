require "codeclimate-test-reporter"
require 'rspec'
require 'factor/connector/test'
require 'factor/connector/runtime'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

require 'factor-connector-hipchat'

RSpec.configure do |c|
  c.include Factor::Connector::Test

  c.before do
    @api_key = ENV['HIPCHAT_API_KEY']
    @runtime = Factor::Connector::Runtime.new(HipchatConnectorDefinition)
    @room    = 'Factor'
  end

  def send_message(room,message)
    client = HipChat::Client.new(@api_key, api_version:'v2')
    client[room].send('Factor.io',message)
  end
end