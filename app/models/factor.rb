class Factor < ActiveRecord::Base
    has_many :diseases, through: :disease_factors
    has_many :factors, foreign_key: :parent_id
    has_one :parent, class_name: :Factor, foreign_key: :parent_id
end