RSpec.describe RuboCop::Cop::RSpec::ContainExactly do
  subject(:cop) { described_class.new }

  it 'flags `contain_exactly` with only splat arguments' do
    expect_offense(<<-RUBY)
      it { is_expected.to contain_exactly(*array1, *array2) }
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `match_array` when matching array values.
    RUBY
  end

  it 'does not flag `match_array`' do
    expect_no_offenses(<<-RUBY)
      it { is_expected.to match_array(array1 + array2) }
    RUBY
  end

  it 'does not flag `contain_exactly` with mixed arguments' do
    expect_no_offenses(<<-RUBY)
      it { is_expected.to contain_exactly(content, *array) }
    RUBY
  end

  include_examples 'autocorrect',
                   'it { is_expected.to contain_exactly(*array1, *array2) }',
                   'it { is_expected.to match_array(array1 + array2) }'
end
