# -*- encoding : utf-8 -*-
require 'digest/sha1'

module Simsr
  module VerifiesPhoneNumber
    
    def self.included(base)
      base.extend ClassMethods  
    end
    
    module ClassMethods
      def sms_options=(options)
        @sms_options = options
      end

      def sms_options
        @sms_options
      end
      
      def verifies_phone_number(*options)
        sms_options = options.extract_options!
        sms_options[:field] ||= "mobile_phone"
    
        provider_name = sms_options[:provider].to_s.classify
        raise "Requested Provider Module #{provider_name} not found" unless Simsr::Providers.const_defined?(provider_name)

        # protected the verified_at column from mass assignment
        attr_protected "#{sms_options[:field]}_verified_at"
        
        # protect the hash column
        attr_protected "#{sms_options[:field]}_verified_hash"

        validate "#{sms_options[:field]}_verification_correct"

        # The order is important!!!
        before_save "unverify_#{sms_options[:field]}", "reverify_#{sms_options[:field]}"

        # return a 4-digit VerificationCode, perhaps should be a bit more advanced in the future
        define_method "get_new_code" do
          code = ""
          4.times do 
            code += rand(10).to_s
          end
          code
        end
    
        define_method "deliver_#{sms_options[:field]}_verification_code" do
          code = get_new_code
  			  message = I18n.t("simsr.verification_message", :code => code, :default => "Your Activation Code: #{code}")
          response = Simsr.deliver!(sms_options.merge(:to => self.send(sms_options[:field]), :message => message))
          self.send("#{sms_options[:field]}_verification_response=",  response)
          
          if (response[:ok])
            self.send("#{sms_options[:field]}_verification_code=", code)
            self.send("#{sms_options[:field]}_verification_code_sent_at=", Time.now)
              
            save
          else
            errors.add :base, "API-Error, Message could not be sent (Errorcode: #{self.response[:code]})"
            false
          end
  			end
    			     
        define_method "verify_#{sms_options[:field]}" do |a_code|
          if a_code.strip == self.send("#{sms_options[:field]}_verification_code")
            self.send("#{sms_options[:field]}_verified_at=", Time.now)
            self.send("#{sms_options[:field]}_verified_hash=", Digest::SHA1.hexdigest(self.send(sms_options[:field])))
          end
        end
        
        define_method "unverify_#{sms_options[:field]}" do
          if self.send("#{sms_options[:field]}_changed?")
            self.send("#{sms_options[:field]}_verified_at=", nil)
          end
        end
        
        define_method "reverify_#{sms_options[:field]}" do
          if self.send("#{sms_options[:field]}_changed?")
            if send("#{sms_options[:field]}_verified_hash") == Digest::SHA1.hexdigest(self.send(sms_options[:field]))
              self.send("#{sms_options[:field]}_verified_at=", Time.now)
            end 
          end
        end
        
        define_method "#{sms_options[:field]}_verification_correct" do
          if self.instance_variable_get("@#{sms_options[:field]}_verification").present?
            if self.instance_variable_get("@#{sms_options[:field]}_verification") != self.send("#{sms_options[:field]}_verification_code")
              errors.add(:base, I18n.t("simsr.errors.verification_code_invalid", :default => "The Verification Code is invalid"))
            end
          end
        end
        
        define_method "#{sms_options[:field]}_verification=" do |a_code|
          self.instance_variable_set("@#{sms_options[:field]}_verification", a_code.strip)
          send("verify_#{sms_options[:field]}", a_code.strip)
        end
        
      end

    end

  end
end
