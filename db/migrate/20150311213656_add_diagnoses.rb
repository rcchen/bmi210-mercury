class AddDiagnoses < ActiveRecord::Migration
  def change
  	create_table :diagnoses do |t|
  	  t.integer		:user_id
  	  t.integer		:disease_id
  	  t.integer		:log_id
  	  t.integer		:symptom_id
  	  t.integer		:factor_id
      t.decimal   :symptom_score
      t.decimal   :factor_score
  	  t.boolean		:in_progress
  	  t.timestamps
  	end
  end
end
