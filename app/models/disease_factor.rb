class DiseaseFactor < ActiveRecord::Base
    belongs_to :disease
    belongs_to :factor
end