class AddLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer     :user_id
      t.string		:request
      t.string		:response
      t.timestamps
    end
  end
end
