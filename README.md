# Activesupport BinaryProperty

Activesupport BinaryProperty is a ActiveSupport::Concern that provides an enum-like functionality for multiple values

## Installation

Run `bundle add activesupport-binary-property`

## Setup

First, add an integer-column to a table:

```ruby
class AddRolesToUser < ActiveRecord::Migration[7.0]
  def change
    add_column(:users, :roles, :integer)
  end
end
```

Then, include the concern in your model:

```ruby
  include BinaryProperty
```

And configure a property:

```ruby
  has_binary_property :roles, {
                        admin: 1,
                        manager: 2,
                        supervisor: 3
                      }
```

Optinally add _prefix or _suffix similar to how enum works

## Usage

Using the example above some methods are added to the User

### Listing

You can get all available roles by accessing `User#roles`:

```ruby
001:0> User.roles
=> {:admin=>1, :manager=>2, :supervisor=>4}
```

### Scope

Scopes are made for each of the values:

```ruby
001:0> User.admin.count
=> 1
```

### Getters

Get details about the roles:

```ruby
001:0> user = User.first
=> #<User ...

002:0> user.roles
=> 1

003:0> user.role_list
=> [:admin]

004:0> user.admin?
=> true

005:0> user.manager?
=> false
```

### Setters

Set roles:

```ruby
001:0> user = User.first
=> #<User ...

002:0> user.manager?
=> false

003:0> user.manager = true
=> true

004:0> user.manager?
=> true

005:0> user.supervisor = '0' # to process input from a check_box
=> "0"

006:0> user.supervisor?
=> false

007:0> user.supervisor = '1'
=> "1"

008:0> user.supervisor?
=> true
```

## License

The gem has been made available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
