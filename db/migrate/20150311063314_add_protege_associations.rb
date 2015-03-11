class AddProtegeAssociations < ActiveRecord::Migration
  def change
    create_table :diseases do |t|
        t.string :name
        t.integer :parent_id
    end
    create_table :symptoms do |t|
        t.string :name
        t.integer :parent_id
    end
    create_table :factors do |t|
        t.string :name
        t.integer :parent_id
    end
    create_table :disease_symptoms do |t|
        t.integer :disease_id
        t.integer :symptom_id
    end
    create_table :disease_factors do |t|
        t.integer :disease_id
        t.integer :factor_id
    end
  end
end
