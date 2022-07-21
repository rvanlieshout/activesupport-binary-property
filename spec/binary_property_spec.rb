require 'spec_helper'

RSpec.shared_examples "user with roles" do |parameters|
  prefix = case parameters[:prefix]
           when true then 'role_'
           when String then parameters[:prefix]
           else ''
           end

  suffix = case parameters[:suffix]
           when true then '_role'
           when String then parameters[:suffix]
           else ''
          end

  it 'should be able to list roles' do
    expect(subject.roles).to eql({ admin: 1, manager: 2, supervisor: 4 })
  end

  context 'with some users' do
    let!(:admin) { subject.create("#{prefix}admin#{suffix}": true) }
    let!(:admin_manager) { subject.create("#{prefix}admin#{suffix}": true, "#{prefix}manager#{suffix}": true) }
    let!(:supervisor) { subject.create("#{prefix}supervisor#{suffix}": true) }

    it 'should provide scope admin' do
      expect(subject.public_send("#{prefix}admin#{suffix}").count).to eql 2
      expect(subject.public_send("#{prefix}admin#{suffix}")).to include admin
      expect(subject.public_send("#{prefix}admin#{suffix}")).to include admin_manager
    end

    it 'should provide scope manager' do
      expect(subject.public_send("#{prefix}manager#{suffix}").count).to eql 1
      expect(subject.public_send("#{prefix}manager#{suffix}")).to include admin_manager
    end

    it 'should provide scope supervisor' do
      expect(subject.public_send("#{prefix}supervisor#{suffix}").count).to eql 1
      expect(subject.public_send("#{prefix}supervisor#{suffix}")).to include supervisor
    end

    it 'should prive a list of current roles' do
      expect(admin.roles).to eql 1
      expect(admin.role_list).to eql %i[admin]
      expect(admin.public_send("#{prefix}admin#{suffix}")).to be_truthy
      expect(admin.public_send("#{prefix}manager#{suffix}")).to be_falsy
      expect(admin.public_send("#{prefix}supervisor#{suffix}")).to be_falsy
      expect(admin.public_send("#{prefix}admin#{suffix}?")).to be_truthy
      expect(admin.public_send("#{prefix}manager#{suffix}?")).to be_falsy
      expect(admin.public_send("#{prefix}supervisor#{suffix}?")).to be_falsy

      expect(admin_manager.roles).to eql 3
      expect(admin_manager.role_list).to eql %i[admin manager]
      expect(admin_manager.public_send("#{prefix}admin#{suffix}")).to be_truthy
      expect(admin_manager.public_send("#{prefix}manager#{suffix}")).to be_truthy
      expect(admin_manager.public_send("#{prefix}supervisor#{suffix}")).to be_falsy
      expect(admin_manager.public_send("#{prefix}admin#{suffix}?")).to be_truthy
      expect(admin_manager.public_send("#{prefix}manager#{suffix}?")).to be_truthy
      expect(admin_manager.public_send("#{prefix}supervisor#{suffix}?")).to be_falsy

      expect(supervisor.roles).to eql 4
      expect(supervisor.role_list).to eql %i[supervisor]
      expect(supervisor.public_send("#{prefix}admin#{suffix}")).to be_falsy
      expect(supervisor.public_send("#{prefix}manager#{suffix}")).to be_falsy
      expect(supervisor.public_send("#{prefix}supervisor#{suffix}")).to be_truthy
      expect(supervisor.public_send("#{prefix}admin#{suffix}?")).to be_falsy
      expect(supervisor.public_send("#{prefix}manager#{suffix}?")).to be_falsy
      expect(supervisor.public_send("#{prefix}supervisor#{suffix}?")).to be_truthy
    end

    it 'should allow setting using a boolean true' do
      expect(admin.public_send("#{prefix}supervisor#{suffix}?")).to be_falsy

      admin.public_send("#{prefix}supervisor#{suffix}=", true)

      expect(admin.roles).to eql 5
      expect(admin.role_list).to eql %i[admin supervisor]
      expect(admin.public_send("#{prefix}supervisor#{suffix}?")).to be_truthy
    end

    it 'should allow setting using a string 1' do
      expect(admin.public_send("#{prefix}supervisor#{suffix}?")).to be_falsy

      admin.public_send("#{prefix}supervisor#{suffix}=", '1')

      expect(admin.roles).to eql 5
      expect(admin.role_list).to eql %i[admin supervisor]
      expect(admin.public_send("#{prefix}supervisor#{suffix}?")).to be_truthy
    end

    it 'should allow setting using an integer 1' do
      expect(admin.public_send("#{prefix}supervisor#{suffix}?")).to be_falsy

      admin.public_send("#{prefix}supervisor#{suffix}=", 1)

      expect(admin.roles).to eql 5
      expect(admin.role_list).to eql %i[admin supervisor]
      expect(admin.public_send("#{prefix}supervisor#{suffix}?")).to be_truthy
    end

    it 'should allow unsetting using a boolean false' do
      expect(admin.public_send("#{prefix}admin#{suffix}?")).to be_truthy

      admin.public_send("#{prefix}admin#{suffix}=", false)

      expect(admin.roles).to eql 0
      expect(admin.role_list).to eql %i[]
      expect(admin.public_send("#{prefix}admin#{suffix}?")).to be_falsy
    end

    it 'should allow unsetting using a string 0' do
      expect(admin.public_send("#{prefix}admin#{suffix}?")).to be_truthy

      admin.public_send("#{prefix}admin#{suffix}=", '0')

      expect(admin.roles).to eql 0
      expect(admin.role_list).to eql %i[]
      expect(admin.public_send("#{prefix}admin#{suffix}?")).to be_falsy
    end

    it 'should allow unsetting using an integer 0' do
      expect(admin.public_send("#{prefix}admin#{suffix}?")).to be_truthy

      admin.public_send("#{prefix}admin#{suffix}=", 0)

      expect(admin.roles).to eql 0
      expect(admin.role_list).to eql %i[]
      expect(admin.public_send("#{prefix}admin#{suffix}?")).to be_falsy
    end
  end
end

RSpec.describe BinaryProperty do
  describe 'generic user' do
    subject { User }
    it_behaves_like 'user with roles', prefix: false, suffix: false
  end

  describe 'user with prefix' do
    subject { UserWithPrefixTrue }
    it_behaves_like 'user with roles', prefix: true, suffix: false
  end

  describe 'user with prefix string' do
    subject { UserWithPrefixString }
    it_behaves_like 'user with roles', prefix: 'string', suffix: false
  end

  describe 'user with suffix' do
    subject { UserWithSuffixTrue }
    it_behaves_like 'user with roles', prefix: false, suffix: true
  end

  describe 'user with suffix string' do
    subject { UserWithSuffixString }
    it_behaves_like 'user with roles', prefix: false, suffix: 'string'
  end

  context 'using integer values that use multiple bits' do
    let(:user_class) do
      Struct.new(:roles) do
        include BinaryProperty

        has_binary_property :roles, {
                              admin: 1,
                              manager: 2,
                              supervisor: 3
                            }
      end
    end

    let(:user) { user_class.new(1) }

    it 'should trigger a BinaryProperty::ValueUsesMultipleBitsError' do
      expect { user }.to raise_error(BinaryProperty::ValueUsesMultipleBitsError)
    end
  end
end
