class Symptom < ActiveRecord::Base
    has_many :diseases, through: :disease_symptoms
    has_many :symptoms, foreign_key: :parent_id
    belongs_to :parent, class_name: :Symptom, foreign_key: :parent_id
end