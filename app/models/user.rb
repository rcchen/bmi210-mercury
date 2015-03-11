class User < ActiveRecord::Base
    has_many :diagnoses
    has_many :logs
end