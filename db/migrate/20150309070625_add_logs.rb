class AddLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer     :user_id
      t.integer     :message_id
    end
  end
end
