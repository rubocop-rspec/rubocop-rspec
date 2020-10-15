# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExpectChange, :config do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'with EnforcedStyle `method_call`' do
    let(:enforced_style) { 'method_call' }

    it 'flags blocks that contain simple message sending' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change { User.count }.by(1)
                            ^^^^^^^^^^^^^^^^^^^^^ Prefer `change(User, :count)`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change(User, :count).by(1)
        end
      RUBY
    end

    it 'ignores blocks that cannot be converted to obj/attribute pair' do
      expect_no_offenses(<<-RUBY)
        it do
          expect { run }.to change { User.sum(:points) }
        end
      RUBY
    end

    it 'ignores change method of object that happens to receive a block' do
      expect_no_offenses(<<-RUBY)
        it do
          Record.change { User.count }
        end
      RUBY
    end

    it 'flags implicit block expectation syntax' do
      expect_offense(<<-RUBY)
        it do
          expect(run).to change { User.count }.by(1)
                         ^^^^^^^^^^^^^^^^^^^^^ Prefer `change(User, :count)`.
        end
      RUBY
    end
  end

  context 'with EnforcedStyle `block`' do
    let(:enforced_style) { 'block' }

    it 'flags change matcher without block' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(User, :count).by(1)
                            ^^^^^^^^^^^^^^^^^^^^ Prefer `change { User.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { User.count }.by(1)
        end
      RUBY
    end

    it 'flags change matcher without block with nested class' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(User::Token, :count).by(1)
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `change { User::Token.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { User::Token.count }.by(1)
        end
      RUBY
    end

    it 'flags change matcher without block with root class' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(::Token, :count).by(1)
                            ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `change { ::Token.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { ::Token.count }.by(1)
        end
      RUBY
    end

    it 'flags change matcher when receiver is a variable' do
      expect_offense(<<-RUBY)
        it do
          expect { run }.to change(user, :count)
                            ^^^^^^^^^^^^^^^^^^^^ Prefer `change { user.count }`.
        end
      RUBY

      expect_correction(<<-RUBY)
        it do
          expect { run }.to change { user.count }
        end
      RUBY
    end

    it 'ignores methods called change' do
      expect_no_offenses(<<-RUBY)
        it do
          record.change(user, :count)
        end
      RUBY
    end

    it 'flags implicit block expectation syntax' do
      expect_offense(<<-RUBY)
        it do
          expect(run).to change(User, :count).by(1)
                         ^^^^^^^^^^^^^^^^^^^^ Prefer `change { User.count }`.
        end
      RUBY
    end
  end
end
