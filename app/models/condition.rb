class Condition < ActiveRecord::Base
  has_many :factors

  validates :name, presence: true, allow_blank: false
  validates :hospital_treatment, presence: true, allow_blank: false

  # add threshold
end