# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Rails::PersistenceCalledOutsideExample, :config do # rubocop:disable Layout/LineLength
  describe 'flagged methods' do
    it 'flags create!' do
      expect_offense(<<-RUBY)
        describe User do
          User.create!
          ^^^^^^^^^^^^ Persistence called outside of example.
        end
      RUBY
    end

    it 'flags save!' do
      expect_offense(<<-RUBY)
        describe User do
          user = User.new
          user.save!
          ^^^^^^^^^^ Persistence called outside of example.
        end
      RUBY
    end

    it 'flags Fabricate' do
      expect_offense(<<-RUBY)
        describe User do
          Fabricate(:user)
          ^^^^^^^^^^^^^^^^ Persistence called outside of example.
        end
      RUBY
    end

    it 'flags assignment' do
      expect_offense(<<-RUBY)
        describe User do
          user = User.create
                 ^^^^^^^^^^^ Persistence called outside of example.
        end
      RUBY
    end

    it 'flags shared example parameters' do
      expect_offense(<<-RUBY)
        describe User do
          it_behaves_like "user", User.create
                                  ^^^^^^^^^^^ Persistence called outside of example.
        end
      RUBY
    end

    it 'flags inside context' do
      expect_offense(<<-RUBY)
        describe User do
          context "when" do
            User.create!
            ^^^^^^^^^^^^ Persistence called outside of example.
          end
        end
      RUBY
    end

    it 'flags inside shared examples' do
      expect_offense(<<-RUBY)
        shared_examples "user tests" do
          User.create!
          ^^^^^^^^^^^^ Persistence called outside of example.
        end
      RUBY
    end

    it 'flags inside blocks inside describe' do
      expect_offense(<<-RUBY)
        describe User do
          5.times do
            User.create!
            ^^^^^^^^^^^^ Persistence called outside of example.
          end
        end
      RUBY
    end
  end

  describe 'allowed contexts' do
    it 'does not flag outside describe' do
      expect_no_offenses(<<-RUBY)
        User.create!
      RUBY
    end

    it 'does not flag inside method' do
      expect_no_offenses(<<-RUBY)
        describe User do
          def create_user
            User.create!
          end
        end
      RUBY
    end

    it 'does not flag inside spec helper hook' do
      expect_no_offenses(<<-RUBY)
        RSpec.configure do |config|
          config.before(:each) do
            User.create!
          end
        end
      RUBY
    end

    it 'does not flag inside example' do
      expect_no_offenses(<<-RUBY)
        describe User do
          it do
            User.create!
          end
        end
      RUBY
    end

    it 'does not flag inside let' do
      expect_no_offenses(<<-RUBY)
        describe User do
          let(:user) { User.create! }

          it do
            user
          end
        end
      RUBY
    end

    it 'does not flag inside hook' do
      expect_no_offenses(<<-RUBY)
        describe User do
          before do
            User.create!
          end

          it do
            expect(User.count).to eq(1)
          end
        end
      RUBY
    end

    it 'does not flag inside subject' do
      expect_no_offenses(<<-RUBY)
        describe User do
          subject do
            User.create!
          end
        end
      RUBY
    end

    it 'does not flag inside proc' do
      expect_no_offenses(<<-RUBY)
        describe User do
          examples = [
            proc {
              User.create!
            }
          ]
        end
      RUBY

      expect_no_offenses(<<-RUBY)
        describe User do
          examples = [
            Proc.new {
              User.create!
            }
          ]
        end
      RUBY
    end

    it 'does not flag inside lambda' do
      expect_no_offenses(<<-RUBY)
        describe User do
          examples = [
            lambda {
              User.create!
            }
          ]
        end
      RUBY

      expect_no_offenses(<<-RUBY)
        describe User do
          examples = [
            -> {
              User.create!
            }
          ]
        end
      RUBY
    end
  end

  context 'when configured with ForbiddenMethods', :config do
    let(:cop_config) do
      { 'ForbiddenMethods' => ['seed_db'] }
    end

    it 'flags offenses in config' do
      expect_offense(<<-RUBY)
        describe User do
          User.seed_db
          ^^^^^^^^^^^^ Persistence called outside of example.
        end
      RUBY
    end

    it 'does not flag default offenses' do
      expect_no_offenses(<<-RUBY)
        describe User do
          User.create!
        end
      RUBY
    end
  end

  context 'when configured with AllowedMethods', :config do
    let(:cop_config) do
      { 'AllowedMethods' => ['create!'] }
    end

    it 'flags offenses that are not allowed' do
      expect_offense(<<-RUBY)
        describe User do
          User.create
          ^^^^^^^^^^^ Persistence called outside of example.
        end
      RUBY
    end

    it 'does not flag AllowedMethods' do
      expect_no_offenses(<<-RUBY)
        describe User do
          User.create!
        end
      RUBY
    end
  end
end
