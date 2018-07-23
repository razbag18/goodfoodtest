class Dish < ActiveRecord::Base
  has_many :comments #plural. many comments. they add extra methods
  belongs_to :user #singular. one user. they add extra methods
  has_many :likes #add likes method
end