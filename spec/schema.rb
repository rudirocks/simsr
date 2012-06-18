ActiveRecord::Schema.define :version => 0 do
  create_table :short_messages, :force => true do |t|
    t.column :to, :string
    t.column :message, :text
    t.column :sent_at, :datetime
    t.column :response, :text
  end

  create_table :contact_infos, :force => true do |t|
    t.column :telephone, :string
    t.column :telephone_verification_code, :string
    t.column :telephone_verification_code_sent_at, :datetime
    t.column :telephone_verification_response, :text
    t.column :telephone_verified_at, :datetime
  end
end