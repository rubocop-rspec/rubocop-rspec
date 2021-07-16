# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::CreateList do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'when EnforcedStyle is :create_list' do
    let(:enforced_style) { :create_list }

    it 'flags usage of n.times with no arguments' do
      expect_offense(<<~RUBY)
        3.times { create :user }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        create_list :user, 3
      RUBY
    end

    it 'flags usage of n.times when FactoryGirl.create is used' do
      expect_offense(<<~RUBY)
        3.times { FactoryGirl.create :user }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        FactoryGirl.create_list :user, 3
      RUBY
    end

    it 'flags usage of n.times when FactoryBot.create is used' do
      expect_offense(<<~RUBY)
        3.times { FactoryBot.create :user }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        FactoryBot.create_list :user, 3
      RUBY
    end

    it 'ignores create method of other object' do
      expect_no_offenses(<<~RUBY)
        3.times { SomeFactory.create :user }
      RUBY
    end

    it 'ignores create in other block' do
      expect_no_offenses(<<~RUBY)
        allow(User).to receive(:create) { create :user }
      RUBY
    end

    it 'ignores n.times with argument' do
      expect_no_offenses(<<~RUBY)
        3.times { |n| create :user, created_at: n.days.ago }
      RUBY
    end

    it 'ignores n.times when there is no create call inside' do
      expect_no_offenses(<<~RUBY)
        3.times { do_something }
      RUBY
    end

    it 'ignores n.times when there is other calls but create' do
      expect_no_offenses(<<~RUBY)
        used_passwords = []
        3.times do
          u = create :user
          expect(used_passwords).not_to include(u.password)
          used_passwords << u.password
        end
      RUBY
    end

    it 'flags FactoryGirl.create calls with a block' do
      expect_offense(<<~RUBY)
        3.times do
        ^^^^^^^ Prefer create_list.
          create(:user) { |user| create :account, user: user }
        end
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 3) { |user| create :account, user: user }
      RUBY
    end

    it 'flags usage of n.times with arguments' do
      expect_offense(<<~RUBY)
        5.times { create(:user, :trait) }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 5, :trait)
      RUBY
    end

    it 'flags usage of n.times with keyword arguments' do
      expect_offense(<<~RUBY)
        5.times { create :user, :trait, key: :val }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        create_list :user, 5, :trait, key: :val
      RUBY
    end

    it 'flags usage of n.times with block argument' do
      expect_offense(<<~RUBY)
        3.times do
        ^^^^^^^ Prefer create_list.
          create(:user, :trait) { |user| create :account, user: user }
        end
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 3, :trait) { |user| create :account, user: user }
      RUBY
    end

    it 'flags usage of n.times with nested block arguments' do
      expect_offense(<<~RUBY)
        3.times do
        ^^^^^^^ Prefer create_list.
          create(:user, :trait) do |user|
            create :account, user: user
            create :profile, user: user
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 3, :trait) do |user|
            create :account, user: user
            create :profile, user: user
        end
      RUBY
    end

    it 'flags usage of n.times with dynamic arguments' do
      expect_offense(<<~RUBY)
        3.times { create(:user, foo: rand(2), bar: 'baz', joe: doe) }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
create_list(:user, 3, bar: 'baz') do |user|
user.foo = rand(2)
user.joe = doe
end
      RUBY
    end

    it 'flags usage of n.times with dynamic arguments and existing block' do
      expect_offense(<<~RUBY)
      3.times do
      ^^^^^^^ Prefer create_list.
        create(:user, foo: rand(2), bar: 'baz', joe: doe) do |user|
          create(:account, user: user)
        end
      end
      RUBY

      expect_correction(<<~RUBY)
      create_list(:user, 3, bar: 'baz') do |user|
          user.foo = rand(2)
          user.joe = doe
          create(:account, user: user)
      end
      RUBY
    end
  end

  context 'when EnforcedStyle is :n_times' do
    let(:enforced_style) { :n_times }

    it 'flags usage of create_list' do
      expect_offense(<<~RUBY)
        create_list :user, 3
        ^^^^^^^^^^^ Prefer 3.times.
      RUBY

      expect_correction(<<~RUBY)
        3.times { create :user }
      RUBY
    end

    it 'flags usage of create_list with argument' do
      expect_offense(<<~RUBY)
        create_list(:user, 3, :trait)
        ^^^^^^^^^^^ Prefer 3.times.
      RUBY

      expect_correction(<<~RUBY)
        3.times { create(:user, :trait) }
      RUBY
    end

    it 'flags usage of create_list with keyword arguments' do
      expect_offense(<<~RUBY)
        create_list :user, 3, :trait, key: val
        ^^^^^^^^^^^ Prefer 3.times.
      RUBY

      expect_correction(<<~RUBY)
        3.times { create :user, :trait, key: val }
      RUBY
    end

    it 'flags usage of FactoryGirl.create_list' do
      expect_offense(<<~RUBY)
        FactoryGirl.create_list :user, 3
                    ^^^^^^^^^^^ Prefer 3.times.
      RUBY

      expect_correction(<<~RUBY)
        3.times { FactoryGirl.create :user }
      RUBY
    end

    it 'flags usage of FactoryGirl.create_list with a block' do
      expect_offense(<<~RUBY)
        FactoryGirl.create_list(:user, 3) { |user| user.points = rand(1000) }
                    ^^^^^^^^^^^ Prefer 3.times.
      RUBY

      expect_correction(<<~RUBY)
        3.times { FactoryGirl.create(:user) } { |user| user.points = rand(1000) }
      RUBY
    end

    it 'ignores create method of other object' do
      expect_no_offenses(<<~RUBY)
        SomeFactory.create_list :user, 3
      RUBY
    end
  end
end
