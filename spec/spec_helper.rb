# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/support'

module SpecHelper
  ROOT = Pathname.new(__dir__).parent.freeze
end

spec_helper_glob = File.expand_path('{support,shared}/*.rb', __dir__)
Dir.glob(spec_helper_glob).sort.each(&method(:require))

RSpec.configure do |config|
  # Set metadata so smoke tests are run on all cop specs
  config.define_derived_metadata(file_path: %r{/spec/rubocop/cop/}) do |meta|
    meta[:type] = :cop_spec
  end

  # Include config shared context for all cop specs
  config.define_derived_metadata(type: :cop_spec) do |meta|
    meta[:config] = true
  end

  config.order = :random

  # Run focused tests with `fdescribe`, `fit`, `:focus` etc.
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Forbid RSpec from monkey patching any of our objects
  config.disable_monkey_patching!

  # We should address configuration warnings when we upgrade
  config.raise_errors_for_deprecations!

  # RSpec gives helpful warnings when you are doing something wrong.
  # We should take their advice!
  config.raise_on_warning = true

  config.include(ExpectOffense)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubocop-rspec'
