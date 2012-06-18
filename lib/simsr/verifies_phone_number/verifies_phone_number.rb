# -*- encoding : utf-8 -*-
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

        # return a 4digit VerificationCode
        define_method "get_new_code" do
          code = ""
          4.times do 
            code += rand(10).to_s
          end
          code
        end
    
        define_method "deliver_#{sms_options[:field]}_verification_code" do
          code = get_new_code
  			  message = "Your Activation Code: #{code}"
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
          end
        end
        
        define_method "#{sms_options[:field]}_verification=" do |a_code|
          send("verify_#{sms_options[:field]}", a_code)
        end
        
      end

    end

  end
end
