# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ExcessiveDocstringSpacing, only: true do
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

    it 'finds descriptions with inner extra whitespace' do
      expect_offense(<<-RUBY)
        describe '#mymethod   (is cool)' do
                  ^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        describe '#mymethod (is cool)' do
        end
      RUBY
    end

    it 'finds descriptions with multiple inner extra whitespace' do
      expect_offense(<<-RUBY)
        describe '#mymethod      (  is     cool  )' do
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        describe '#mymethod ( is cool )' do
        end
      RUBY
    end

    it 'skips \-separated multiline strings whose trailing whitespace ' \
       'makes sense' do
      expect_no_offenses(<<-RUBY)
        describe '#mymethod ' \\
            '(is cool)' do
        end
      RUBY
    end

    it 'flags \-separated multiline strings whose trailing whitespace ' \
       'does not make sense' do
      expect_offense(<<-RUBY)
        describe '#mymethod   ' \\
                  ^^^^^^^^^^^^^^^ Excessive whitespace.
            '(is cool)' do
        end
      RUBY

      expect_correction(<<-RUBY)
        describe '#mymethod (is cool)' do
        end
      RUBY
    end

    it 'flags \-separated multiline interpolated strings with ' \
       'leading whitespace' do
      expect_offense(<<-'RUBY')
        describe "  ##{object} " \
                  ^^^^^^^^^^^^^^^^ Excessive whitespace.
            "(is cool)" do
        end
      RUBY

      expect_correction(<<-'RUBY')
        describe "##{object} (is cool)" do
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

    it 'finds descriptions with inner extra whitespace' do
      expect_offense(<<-RUBY)
        context 'when   something' do
                 ^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        context 'when something' do
        end
      RUBY
    end

    it 'finds descriptions with multiple inner extra whitespace' do
      expect_offense(<<-RUBY)
        context 'when     something    cool happens!' do
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        context 'when something cool happens!' do
        end
      RUBY
    end

    it 'skips \-separated multiline strings whose trailing whitespace ' \
       'makes sense' do
      expect_no_offenses(<<-RUBY)
        context 'when doing something ' \\
            'like this' do
        end
      RUBY
    end

    it 'flags \-separated multiline strings whose trailing whitespace ' \
       'does not make sense' do
      expect_offense(<<-RUBY)
        context 'when doing something   ' \\
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
            'like this' do
        end
      RUBY

      expect_correction(<<-RUBY)
        context 'when doing something like this' do
        end
      RUBY
    end

    it 'flags \-separated multiline interpolated strings with leading ' \
       'whitespace' do
      expect_offense(<<-'RUBY')
        context "  when doing something " \
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
            "like #{object}" do
        end
      RUBY

      expect_correction(<<-'RUBY')
        context "when doing something like #{object}" do
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

    it 'finds descriptions with inner extra whitespace' do
      expect_offense(<<-RUBY)
        it 'does   something' do
            ^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'does something' do
        end
      RUBY
    end

    it 'finds descriptions with multiple inner extra whitespace' do
      expect_offense(<<-RUBY)
        it 'does  something      cool!' do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'does something cool!' do
        end
      RUBY
    end

    it 'skips \-separated multiline strings whose trailing whitespace ' \
       'makes sense' do
      expect_no_offenses(<<-RUBY)
        it 'should do something ' \\
            'and correctly fix' do
        end
      RUBY
    end

    it 'flags \-separated multiline strings whose trailing whitespace ' \
       'does not make sense' do
      expect_offense(<<-RUBY)
        it 'does something   ' \\
            ^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
            'and correctly fix' do
        end
      RUBY

      expect_correction(<<-RUBY)
        it 'does something and correctly fix' do
        end
      RUBY
    end

    it 'flags \-separated multiline interpolated strings with leading ' \
       'whitespace' do
      expect_offense(<<-'RUBY')
        it "  does something " \
            ^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
            "with #{object}" do
        end
      RUBY

      expect_correction(<<-'RUBY')
        it "does something with #{object}" do
        end
      RUBY
    end
  end

  context 'when using other common example groups' do
    it 'supports `xcontext`' do
      expect_offense(<<-'RUBY')
        xcontext "when testing  " do
                  ^^^^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        xcontext "when testing" do
        end
      RUBY
    end

    it 'supports `feature`' do
      expect_offense(<<-'RUBY')
        feature "  #{:stuff}" do
                 ^^^^^^^^^^^ Excessive whitespace.
        end
      RUBY

      expect_correction(<<-'RUBY')
        feature "#{:stuff}" do
        end
      RUBY
    end

    it 'supports `its`' do
      expect_offense(<<-'RUBY')
        its("  length  ") { should eq(1) }
             ^^^^^^^^^^ Excessive whitespace.
      RUBY

      expect_correction(<<-'RUBY')
        its("length") { should eq(1) }
      RUBY
    end

    it 'supports `skip`' do
      expect_offense(<<-RUBY)
        skip '  this   please   ' \\
              ^^^^^^^^^^^^^^^^^^^^^ Excessive whitespace.
            '  and thank you  !' do
        end
      RUBY

      expect_correction(<<-'RUBY')
        skip 'this please and thank you !' do
        end
      RUBY
    end
  end
end
