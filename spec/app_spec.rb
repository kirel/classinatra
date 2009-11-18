require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

require 'rack/test'
require 'app'

def app
  Sinatra::Application
end

set :environment, :test

describe 'The Sinatra classifier' do
  include Rack::Test::Methods

  before do
    @id = 'someid'
    @data = 'somedata'
    CLASSIFIER.stub!(:train)
  end

  it "trains a wellformed request (POST /train/:id request.body~>data)" do
    CLASSIFIER.should_receive(:train)
    
    post "/train/#{@id}", @data
    last_response.should be_ok
  end

  it "classifies a wellformed request (POST /classify request.body~>data)" do
    CLASSIFIER.should_receive(:classify).and_return [Hit.new(@id.to_sym, 1)]
    
    post '/classify', @data
    last_response.should be_ok
    
    r = JSON last_response.body
    r.should be_an(Array)
    r.each do |h|
      h.should be_a(Hash)
      h.should have_key("id")
      h.should have_key("score")
      h["id"].should be_a(String)
      h["score"].should be_a(Numeric)
    end
  end
  
  # it "won't train without a body" do
  #   CLASSIFIER.should_not_receive(:train)
  #   post "/train/#{@id}"
  #   last_response.status.should == 422
  # end
  # 
  # it "won't classify without a request body"
  
end