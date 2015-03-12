class Diagnosis < ActiveRecord::Base
	belongs_to :user
	belongs_to :log
	belongs_to :disease
	belongs_to :factor
	belongs_to :symptom
end