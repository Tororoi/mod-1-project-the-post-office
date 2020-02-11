class Sender < ActiveRecord::Base
    has_many :letters
    has_many :receivers, through: :letters
end