class Receiver < ActiveRecord::Base
    has_many :letters
    has_many :senders, through: :letters
end