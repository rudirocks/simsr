# -*- encoding : utf-8 -*-
module Simsr
  module Providers
    module Sms77
      def self.server
        "gateway.sms77.de"
      end

      def self.possible_routes 
        []
      end
      
      def self.possible_types
        ["basicplus", "quality", "festnetz", "flash"]
      end

      def self.parameters
        {
          username:           { param: :u, needed: true },
          password:           { param: :p, needed: true },
          apikey: nil,        
          to:                 { param: :to, needed: true },
          message:            { param: :text, needed: true },
          type:               { param: :type, needed: true, default: "basicplus" },
          route: nil,        
          from:               { param: :from },
          debug:              { param: :debug },
          return_message_id:  { param: :return_msg_id },
          delay:              { param: :delay },
          cost: nil,
          count: nil,
          delivery_report: nil
        }
      end
      
      def self.possible_responses
        {
          "100" => "SMS wurde erfolgreich verschickt",
          "101" => "Versand an mindestens einen Empfänger fehlgeschlagen",
          "201" => "Ländercode für diesen SMS-Typ nicht gültig. Bitte als Basic SMS verschicken.",
          "202" => "Empfängernummer ungültig",
          "300" => "Bitte Benutzer/Passwort angeben",
          "301" => "Variable to nicht gesetzt",
          "304" => "Variable type nicht gesetzt",
          "305" => "Variable text nicht gesetzt",
          "306" => "Absendernummer ungültig. Diese muss vom Format 0049... sein und eine gültige Handynummer darstellen.",
          "307" => "Variable url nicht gesetzt",
          "400" => "type ungültig. Siehe erlaubte Werte oben.",
          "401" => "Variable text ist zu lang",
          "402" => "Reloadsperre – diese SMS wurde bereits innerhalb der letzten 90 Sekunden verschickt",
          "500" => "Zu wenig Guthaben vorhanden.",
          "600" => "Carrier Zustellung misslungen",
          "700" => "Unbekannter Fehler",
          "801" => "Logodatei nicht angegeben",
          "802" => "Logodatei existiert nicht",
          "803" => "Klingelton nicht angegeben",
          "900" => "Benutzer/Passwort-Kombination falsch",
          "902" => "http API für diesen Account deaktiviert",
          "903" => "Server IP ist falsch"
        }
      end

      def self.parse_response(response_object)
        {
          :ok => (response_object.body.strip == "100"),
          :code => response_object.body.strip,
          :message => possible_responses[response_object.body.strip]
        }
      end

    end
  end
end