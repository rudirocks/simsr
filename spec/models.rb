class ShortMessage < ActiveRecord::Base
  acts_as_sms :provider => :dummy, :apikey => "secret"
end

class ContactInfo < ActiveRecord::Base
  verifies_phone_number  :provider => :dummy, :apikey => "secret", :field => :telephone
end