class Log < ActiveRecord::Base
    belongs_to :user
    belongs_to :message

    # add answer to log
end