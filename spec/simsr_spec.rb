require 'spec_helper'
require 'simsr'

describe "Simsr" do
  it "sends an sms" do
    s = ShortMessage.new(:to => "12345", :message => "Hello World")
    s.deliver
    s.response.should be_a_kind_of(Hash)
    s.sent_at.should_not eq(nil)
    s.response[:ok].should eq(true)
  end
  
  # it "does not send an empty message" do
  #   result = Simsr.deliver(:to => "123", :message => "Hello", :provider => :mobilant, :apikey => "secret", :debug => 1)
  #   
  #   result.should eq(0)
  #   # bowling = Bowling.new
  #   # 20.times { bowling.hit(0) }
  #   # bowling.score.should eq(0)
  # end
end
