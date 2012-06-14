# -*- encoding : utf-8 -*-
module Simsr
  module Providers
    module Dummy
      def self.request(options)
        puts "Dummy Request"
        {:ok => true, :code => "100", :message => possible_responses["100"]}
      end

      def self.possible_routes 
        ["lowcost", "lowcostplus", "direct", "directplus"]
      end
      
      def self.possible_types
        ['flash', 'unicode', 'binary', 'voice']
      end
      
      def self.parameters
        {
          username: nil,
          password: nil,
          apikey:             { param: :key, needed: true },
          to:                 { param: :to, needed: true },
          message:            { param: :message, needed: true }
        }
      end      
      
      def self.possible_responses
        {
          "100" => "SMS has been sent through Dummy Provider."
        }
      end

      def self.parse_response(response_object)
        response_object
      end
      
    end
  end
end