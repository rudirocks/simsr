# -*- encoding : utf-8 -*-
module Simsr
  module Providers
    module Mobilant
      def self.server
        "gw.mobilant.net"
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
          message:            { param: :message, needed: true },
          type:               { param: :messagetype },
          route:              { param: :route, :needed => true, :default => "lowcost" },        
          from:               { param: :from },
          debug:              { param: :debug },
          return_message_id:  { param: :message_id },
          delay:              { param: :senddate },
          cost:               { param: :cost },
          count:              { param: :count },
          delivery_report:    { param: :dlr }
        }
      end      
      
      def self.possible_responses
        {
          "10" => "Empfängernummer nicht korrekt. Korrektes Format verwenden.",
          "20" => "Absenderkennung nicht korrekt. Absender mit maximal 11 alpha-numerischen Zeichen oder 16 numerischen Zeichen verwenden.",
          "30" => "Nachrichttext nicht korrekt. Maximal 160 Zeichen Text oder Parameter concat=1 nutzen.",
          "31" => "Messagetyp nicht korrekt. Messagetype entfernen oder einen der folgenden Werte verwenden: flash, unicode, binary, voice.",
          "40" => "SMS Route nicht korrekt. Folgende Routen sind möglich: lowcost, lowcostplus, direct, directplus",
          "50" => "Identifikation fehlgeschlagen. Gateway Key überprüfen.",
          "60" => "Nicht genügend Guthaben. Guthaben aufladen.",
          "70" => "Netz wird nicht abgedeckt. Andere Route verwenden.",
          "71" => "Feature nicht möglich. Andere Route verwenden",
          "80" => "Übergabe an SMS-C fehlgeschlagen. Andere Route wählen oder an den Support wenden für weitere Informationen.",
          "100" => "SMS wurde angenommen und versendet."
        }
      end

      def self.parse_response(response_object)
        lines = response_object.body.lines.to_a
        response_hash = {}
        response_hash[:ok] = (lines[0].strip == "100") if lines[0].present?
        response_hash[:code] = lines[0].strip if lines[0].present?
        response_hash[:message] = possible_responses[lines[0].strip] if lines[0].present?
        response_hash[:message_id] = lines[1].strip if lines[1].present?
        response_hash[:cost] = lines[2].strip if lines[2].present?
        response_hash[:count] = lines[3].strip if lines[3].present?
        
        response_hash
      end
      
    end
  end
end