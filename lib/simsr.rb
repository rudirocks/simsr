# -*- encoding : utf-8 -*-
require "simsr/version"

require 'active_support/all'
require 'active_record'
require "net/http"

require 'simsr/providers/mobilant'
require 'simsr/providers/sms77'
require 'simsr/providers/dummy'
require 'simsr/acts_as_sms/acts_as_sms'
require 'simsr/verifies_phone_number/verifies_phone_number'

module Simsr
  def self.deliver!(*options)
		options = options.extract_options!

    raise "Error: No phone number (:to) given" if options[:to].blank?
    raise "Error: No text (:message) given" if options[:message].blank?
    raise "Error: No Provider Module given" if options[:provider].blank?
    raise "Error: Requested Provider Module '#{options[:provider].to_s.classify}' not found" unless Simsr::Providers.const_defined?(options[:provider].to_s.classify)
    
    validate_options!(options)
    
    puts "Sending text message '#{options[:message]}' to '#{options[:to]}' via #{options[:provider].to_s.classify}..."
    do_request(options)
  end

  def self.deliver(*options)
    begin
      return deliver!(*options)
    rescue
      puts $!
    end
  end
  
  def self.get_params_string(options)
    provider = get_provider(options[:provider])
    params = "/?" + provider.parameters.collect do |key, param_hash|
      if param_hash.present? && (options[key].present? || param_hash[:default].present?)
        s = options[key] || param_hash[:default]
        s = replace_umlauts(s.to_s)
        "#{param_hash[:param].to_s}=#{s}"
      end
    end.compact.join("&")
  end
  
  def self.get_provider(provider_name)
    Simsr::Providers.const_get(provider_name.to_s.classify)
  end
  
  def self.do_request(options)
    provider = get_provider(options[:provider])
 
    if provider.respond_to?(:request)
      # use custon request_method on provider, if given
      provider.request(options)
    else
      # else, get server variable from provider and send the request
  		server = provider.server
      params = get_params_string(options)
    
  		https = Net::HTTP.new(server, Net::HTTP.https_default_port)
  		https.use_ssl = true
  		https.ssl_timeout = 2

  		response = https.start do |http|
  			request = Net::HTTP::Get.new(params)
  			https.request(request)
  		end
    
      status = provider.parse_response(response)
      puts (status[:ok] ? "Message sent." : "Error: Message could not be sent.")
      status
    end
  end
  
	def self.replace_umlauts(text)
		return_string = text.clone
		umlauts.each do |umlaut|
			return_string.gsub!(umlaut[:zeichen], umlaut[:isolatin1])
		end
		return_string			
	end
		
	def self.umlauts
		[
			{ :zeichen => "Ä", :utf8 => "%C3%84", :isolatin1 => "%C4" },
			{ :zeichen => "Ö", :utf8 => "%C3%96", :isolatin1 => "%D6" },
			{ :zeichen => "Ü", :utf8 => "%C3%9C", :isolatin1 => "%DC" },
			{ :zeichen => "ä", :utf8 => "%C3%A4", :isolatin1 => "%E4" },
			{ :zeichen => "ö", :utf8 => "%C3%B6", :isolatin1 => "%F6" },
			{ :zeichen => "ü", :utf8 => "%C3%BC", :isolatin1 => "%FC" },
			{ :zeichen => "ß", :utf8 => "%C3%9F", :isolatin1 => "%DF" },
			{ :zeichen => " ", :utf8 => "", :isolatin1 => "%20" },
		]		
	end
  
      
  def self.validate_options!(options)
    provider = get_provider(options[:provider])
    provider.parameters.each do |key, param_hash|
      if param_hash.present? && param_hash[:needed] && options[key].blank? && param_hash[:default].blank?
        raise "Error: Option '#{key.to_s}' not set"
      end
    end
  end
end


$LOAD_PATH.shift

ActiveRecord::Base.extend Simsr::ActsAsSMS
ActiveRecord::Base.extend Simsr::VerifiesPhoneNumber
ActiveRecord::Base.class_eval { 
  include Simsr::ActsAsSMS 
  include Simsr::VerifiesPhoneNumber 
}
