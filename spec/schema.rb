ActiveRecord::Schema.define :version => 0 do
  create_table :short_messages, :force => true do |t|
    t.column :to, :string
    t.column :message, :text
    t.column :sent_at, :datetime
    t.column :response, :text
  end
end