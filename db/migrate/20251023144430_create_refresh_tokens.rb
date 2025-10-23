class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.string :device_id, null: false
      t.string :device_name
      t.string :ip_address
      t.string :user_agent
      t.datetime :expires_at, null: false
      t.datetime :last_used_at
      t.boolean :revoked, default: false

      t.timestamps
    end

    add_index :refresh_tokens, :token, unique: true
    add_index :refresh_tokens, [ :user_id, :device_id ]
    add_index :refresh_tokens, :expires_at
  end
end
