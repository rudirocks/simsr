# -*- encoding : utf-8 -*-
module Simsr
  module ActsAsSMS
    # Mixin acts_as_sms für active_record models
    #
    # Folgende Datenbankfelder werden benötigt:
    #
    # message:text      # SMS-Nachrichtentext
    # sent_at:datetime  # Sendezeitpunk, wird automatisch gesetzt
    # to:string         # Handynummer des Empfängers
    # response:text     # geparstes Ergebnis des HTTP-Requests
    #
    # Beispiel (für Provider mobilant.de):
    #
    # class ShortMessage < ActiveRecord::Base
    #   acts_as_sms :provider => :mobilant, :key => "secret.from.provider"
    # end
    #
    # ShortMessage.new(:to => "0170123456", :message => "Hallo Welt").deliver
    #
    # Mögliche Parameter für acts_as_sms (abhängig vom Provider):
    #
    # username:           Benutzername für Dienst
    # password:           Passwort für Dienst
    # apikey:             API-Key vom Provider
    # to:                 Zielrufnummer
    # message:            Nachrichtentext
    # type:               Typ der Nachricht
    # route:              Route der Nachricht (siehe Provider)
    # from:               Absender (alphanumerisch, abhängig von Route/Typ)
    # debug:              Debugmodus, wenn auf 1 gesetzt. Es wird keine SMS versendet. Default => 0
    # return_message_id:  Wenn auf 1 gesetzt, wird eine message_id vom Provider zurückgegeben. Default => 0
    # delay:              Unix-Timestamp zum zeitversetzten Senden von SMS
    # cost:               Wenn auf 1 gesetzt, werden die Kosten der SMS zurückgegeben (abhängig von Proiver), Default => 0
    # count:              Wenn auf 1 gesetzt, wird die Anzahl der gesendete SMS zurückgegeben (abhängig von Proiver), Default => 0
    # delivery_report:    Wenn auf 1 gesetzt, wird ein Versandbericht zurückgesendet (per Mail oder HTTP-Push, siehe Provider)
    
    
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
      
      def acts_as_sms(*options)	
    		sms_options = options.extract_options!
    
        provider_name = sms_options[:provider].to_s.classify
        raise "Requested Provider Module #{provider_name} not found" unless Simsr::Providers.const_defined?(provider_name)
  		    
    		validates_presence_of :message, :to
    		validates_length_of :message, :maximum => 160

        define_method "can_be_sent" do
    			if sent_at
    				errors.add(:base, "SMS has already been sent") if sent_at
    				false
    			end
        end
    
        define_method "deliver" do
          begin
            deliver!
          rescue
            puts $! 
          end
        end
      
        define_method "sent?" do
          sent_at.present?
        end
    
        define_method "deliver!" do
    			if valid? == false || can_be_sent == false
    				false
    			else
    			  self.response = Simsr.deliver!(sms_options.merge(:to => to, :message => message))
          
            if (self.response[:ok])
              self.sent_at = Time.now
              save
            else
              errors.add :base, "API-Error, Message could not be sent (Errorcode: #{self.response[:code]})"
              false
            end
    			end
        end
      end

    end

  end
end