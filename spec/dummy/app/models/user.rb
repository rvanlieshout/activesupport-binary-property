class User < ActiveRecord::Base
  include BinaryProperty

  has_binary_property :roles, {
                        admin: 1,
                        manager: 2,
                        supervisor: 4
                      }
end
