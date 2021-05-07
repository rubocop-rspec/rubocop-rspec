# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExcessiveDocstringSpacing do
  it 'ignores non-example blocks' do
    expect_no_offenses('foo "should do something" do; end')
  end

  context 'when using `describe`' do
    it 'skips blocks without text' do
      expect_no_offenses(<<-RUBY)
        describe do
        end
      RUBY
    end

    it 'finds description with leading whitespace' do
      expect_offense(<<-RUBY)
        describe '  #mymethod' do
                  ^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        describe '#mymethod' do
        end
      RUBY
    end

    it 'finds interpolated description with leading whitespace' do
      expect_offense(<<-'RUBY')
        describe "  ##{:stuff}" do
                  ^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        describe "##{:stuff}" do
        end
      RUBY
    end

    it 'finds description with trailing whitespace' do
      expect_offense(<<-RUBY)
        describe '#mymethod  ' do
                  ^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        describe '#mymethod' do
        end
      RUBY
    end

    it 'finds interpolated description with trailing whitespace' do
      expect_offense(<<-'RUBY')
        describe "##{:stuff}  " do
                  ^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        describe "##{:stuff}" do
        end
      RUBY
    end

    it 'flags lone whitespace' do
      expect_offense(<<-RUBY)
        describe '   ' do
                  ^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        describe '' do
        end
      RUBY
    end

    it 'skips descriptions without any excessive whitespace' do
      expect_no_offenses(<<-RUBY)
        describe '#mymethod' do
        end
      RUBY
    end

    it 'skips interpolated description without leading whitespace' do
      expect_no_offenses(<<-'RUBY')
        describe "##{should}" do
        end
      RUBY
    end
  end

  context 'when using `context`' do
    it 'skips blocks without text' do
      expect_no_offenses(<<-RUBY)
        context do
        end
      RUBY
    end

    it 'finds description with leading whitespace' do
      expect_offense(<<-RUBY)
        context '  when doing something' do
                 ^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        context 'when doing something' do
        end
      RUBY
    end

    it 'finds interpolated description with leading whitespace' do
      expect_offense(<<-'RUBY')
        context "  when doing something #{:stuff}" do
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        context "when doing something #{:stuff}" do
        end
      RUBY
    end

    it 'finds description with trailing whitespace' do
      expect_offense(<<-RUBY)
        context 'when doing something  ' do
                 ^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        context 'when doing something' do
        end
      RUBY
    end

    it 'finds interpolated description with trailing whitespace' do
      expect_offense(<<-'RUBY')
        context "when doing #{:stuff}  " do
                 ^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        context "when doing #{:stuff}" do
        end
      RUBY
    end

    it 'finds interpolated description with both trailing and leading ' \
       'whitespace' do
      expect_offense(<<-'RUBY')
        context "  when doing #{:stuff}  " do
                 ^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        context "when doing #{:stuff}" do
        end
      RUBY
    end

    it 'flags lone whitespace' do
      expect_offense(<<-RUBY)
        context '   ' do
                 ^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        context '' do
        end
      RUBY
    end

    it 'skips descriptions without any excessive whitespace' do
      expect_no_offenses(<<-RUBY)
        context 'when doing something' do
        end
      RUBY
    end

    it 'skips interpolated description without leading whitespace' do
      expect_no_offenses(<<-'RUBY')
        context "#{should} the value be incorrect" do
        end
      RUBY
    end
  end

  context 'when using `it`' do
    it 'skips blocks without text' do
      expect_no_offenses(<<-RUBY)
        it do
        end
      RUBY
    end

    it 'finds description with leading whitespace' do
      expect_offense(<<-RUBY)
        it '  does something' do
            ^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'does something' do
        end
      RUBY
    end

    it 'finds interpolated description with leading whitespace' do
      expect_offense(<<-'RUBY')
        it "  does something #{:stuff}" do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        it "does something #{:stuff}" do
        end
      RUBY
    end

    it 'finds description with trailing whitespace' do
      expect_offense(<<-RUBY)
        it 'does something  ' do
            ^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'does something' do
        end
      RUBY
    end

    it 'finds interpolated description with trailing whitespace' do
      expect_offense(<<-'RUBY')
        it "does something #{:stuff}  " do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        it "does something #{:stuff}" do
        end
      RUBY
    end

    it 'handles one-word descriptions' do
      expect_offense(<<-'RUBY')
        it "tests  " do
            ^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        it "tests" do
        end
      RUBY
    end

    it 'handles interpolated one-word descriptions' do
      expect_offense(<<-'RUBY')
        it "#{:stuff}  " do
            ^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        it "#{:stuff}" do
        end
      RUBY
    end

    it 'handles descriptions starting with an interpolated value' do
      expect_offense(<<-'RUBY')
        it "#{:stuff} something   " do
            ^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        it "#{:stuff} something" do
        end
      RUBY
    end

    it 'flags lone whitespace' do
      expect_offense(<<-RUBY)
        it '   ' do
            ^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        it '' do
        end
      RUBY
    end

    it 'skips descriptions without any excessive whitespace' do
      expect_no_offenses(<<-RUBY)
        it 'finds no should here' do
        end
      RUBY
    end

    it 'skips interpolated description without leading whitespace' do
      expect_no_offenses(<<-'RUBY')
        it "#{should} not be here" do
        end
      RUBY
    end
  end
end
