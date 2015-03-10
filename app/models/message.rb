class Message < ActiveRecord::Base
	belongs_to :factor
    has_many :logs

    validates :message, presence: true, allow_blank: false
    validates :weight, presence: true, allow_blank: false
end