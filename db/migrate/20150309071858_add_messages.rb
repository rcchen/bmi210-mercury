class AddMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string     :message
      t.float      :weight
    end
    Message.reset_column_information
    Message.create(:message => "What is your age?", :weight => 1)
  end
end
