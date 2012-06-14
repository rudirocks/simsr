class ShortMessage < ActiveRecord::Base
  acts_as_sms :provider => :dummy, :apikey => "secret"
end