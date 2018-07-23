class User < ActiveRecord::Base
  has_secure_password
  # GIVES ME A METHOD, PASSWORD, THAT ALLOWS ME TO CREATE PASSWORD
  #add a method - password
  # add another methos - authenticate
end