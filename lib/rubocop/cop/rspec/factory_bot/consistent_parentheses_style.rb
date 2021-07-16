# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Use a consistent style for parentheses in factory bot calls
        #
        # @example 
        #
        #   # bad
        #
        #   create :user
        #   build(:user)
        #   create(:login)
        #   create :login
        #
        # @example `EnforcedStyle: require_parentheses`
        #
        #   # good
        #   create(:user)
        #   create(:user)
        #   create(:login)
        #   build(:login)
        #
        # @example `EnforcedStyle: omit_parentheses`
        #
        #   # good
        #   create :user
        #   build :user
        #   create :login
        #   create :login
        #
        class ConsistentParenthesesStyle < Base
          extend AutoCorrector
          include ConfigurableEnforcedStyle

          MSG_ENFORCE_PARENS = 'Prefer method call with parentheses'
          MSG_OMIT_PARENS = 'Prefer method call without parentheses'

          FACTORY_CALLS = Set[:create, :build, :create_list,
                              :build_list, :create_pair,
                              :build_stubbed_list, :atributes_for,
                              :build_stubbed, :build_pair ].freeze

          def_node_matcher :factory_call, <<-PATTERN
              (send
                ${(const nil? {:FactoryGirl :FactoryBot}) nil?} %FACTORY_CALLS
              $...)
          PATTERN

          def on_send(node)
            return if nested_call?(node)

            factory_call(node) do
              if node.parenthesized?
                process_with_parentheses(node)
              else
                process_without_parentheses(node)
              end
            end
          end

          def process_with_parentheses(node)
            return if style == :require_parentheses

            add_offense(node.loc.selector,
                        message: MSG_OMIT_PARENS) do |corrector|
              autocorrect_remove_parens(corrector, node)
            end
          end

          def process_without_parentheses(node)
            return if style == :omit_parentheses

            add_offense(node.loc.selector,
                        message: MSG_ENFORCE_PARENS) do |corrector|
              autocorrect_enforce_parens(corrector, node)
            end
          end

          def nested_call?(node)
            parent = node.parent
            # prevent from nested matching
            parent&.send_type?
          end

          private

          def autocorrect_remove_parens(corrector, node)
            corrector.replace(node.location.begin, ' ')
            corrector.remove(node.location.end)
          end

          def autocorrect_enforce_parens(corrector, node)
            corrector.replace(args_begin(node), '(')
            corrector.replace(args_end(node), ')')
          end
        end
      end
    end
  end
end
