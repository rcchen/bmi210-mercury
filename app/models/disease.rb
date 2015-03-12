class Disease < ActiveRecord::Base
    include PgSearch
    has_many :disease_factors
    has_many :factors, through: :disease_factors, dependent: :destroy
    has_many :disease_symptoms
    has_many :symptoms, through: :disease_symptoms, dependent: :destroy
    has_one :parent, class_name: :Disease, foreign_key: :parent_id
    pg_search_scope :search_by_name, :against => :name
end