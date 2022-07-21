class UserWithSuffixString < ActiveRecord::Base
  self.table_name = 'users'

  include BinaryProperty

  has_binary_property :roles, {
                        admin: 1,
                        manager: 2,
                        supervisor: 4
                      }, _suffix: 'string'
end
