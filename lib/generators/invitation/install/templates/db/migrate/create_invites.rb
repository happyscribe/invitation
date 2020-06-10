class CreateInvites < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :invites do |t|
      t.string :email
      t.string :token
      t.integer :sender_id
      t.integer :recipient_id
      t.integer :invitable_id
      t.string  :invitable_type
      t.string  :role
      t.timestamps
      t.index :email
      t.index :token
      t.index [:invitable_id, :invitable_type]
      t.index :recipient_id
      t.index :sender_id
    end
  end
end
