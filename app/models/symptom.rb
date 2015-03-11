class Symptom < ActiveRecord::Base
    has_many :diseases, through: :disease_symptoms
    has_one :parent, class_name: :Symptom, foreign_key: :parent_id
end