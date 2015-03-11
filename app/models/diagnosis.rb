class Diagnosis < ActiveRecord::Base
	belongs_to :user
	has_one :log
	has_one :disease
	has_one :factor
	has_one :symptom
end