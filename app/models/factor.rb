class Factor < ActiveRecord::Base
  belongs_to :condition
  has_one :message

  validates :name, presence: true, allow_blank: false
  validates :type, presence: true, allow_blank: false
end