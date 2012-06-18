require 'spec_helper'
require 'simsr'

# describe "Simsr" do
#   
# end

describe "ActsAsSMS" do
  it "sends an sms" do
    s = ShortMessage.new(:to => "12345", :message => "Hello World")
    s.deliver
    s.response.should be_a_kind_of(Hash)
    s.sent_at.should_not eq(nil)
    s.response[:ok].should eq(true)
  end
end

describe "VerifiesPhoneNumber" do
  before(:each) do
    @contact = ContactInfo.new(:telephone => "12345")
    @contact.deliver_telephone_verification_code
  end
  
  it "should send a verfication sms" do
    @contact.telephone_verification_response.should be_a_kind_of(Hash)
    @contact.telephone_verification_code_sent_at.should_not eq(nil)
    @contact.telephone_verification_response[:ok].should eq(true)
  end

  it "should not set verified_at in the first place" do
    @contact.telephone_verified_at.should eq(nil)
  end
  
  it "should set verified_at when correct code is given" do
    @contact.telephone_verification = @contact.telephone_verification_code
    @contact.save
    @contact.telephone_verified_at.should_not eq(nil)
  end

  it "should not set verified_at when incorrect code is given" do
    @contact.telephone_verification = @contact.telephone_verification_code + "x"
    @contact.save
    @contact.telephone_verified_at.should eq(nil)
  end
  
  it "should unverify and reverify when phone number has changed" do
    @contact.telephone_verification = @contact.telephone_verification_code
    @contact.save
    @contact.telephone_verified_at.should_not eq(nil)

    @contact.telephone = "54321"
    @contact.save
    @contact.telephone_verified_at.should eq(nil)

    @contact.telephone = "12345"
    @contact.save
    @contact.telephone_verified_at.should_not eq(nil)
  end

end
