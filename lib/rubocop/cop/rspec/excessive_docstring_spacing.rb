# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for excessive whitespace in example descriptions.
      #
      # @example
      #   # bad
      #   it '  has  excessive   spacing  ' do
      #   end
      #
      #   # good
      #   it 'has excessive spacing' do
      #   end
      #
      # @example
      #   # bad
      #   context '  when a condition   is met  ' do
      #   end
      #
      #   # good
      #   context 'when a condition is met' do
      #   end
      class ExcessiveDocstringSpacing < Base
        extend AutoCorrector

        MSG = 'Excessive whitespace.'
        RESTRICT_ON_SEND = %i[skip].freeze

        # @!method example_description(node)
        def_node_matcher :example_description, <<-PATTERN
          {
            (send _ _ ${
              $str
              $(dstr ({str dstr `sym} ...) ...)
            } ...)
            (block (send _ {#Examples.all #ExampleGroups.all} ${
              $str
              $(dstr ({str dstr `sym} ...) ...)
            } ...) ...)
          }
        PATTERN

        def on_send(node)
          example_description(node, &method(:check_for_whitespace_offense))
        end

        def on_block(node)
          example_description(node, &method(:check_for_whitespace_offense))
        end

        private

        # @param node [RuboCop::AST::Node]
        # @param message [RuboCop::AST::Node]
        def check_for_whitespace_offense(node, message)
          text = text(message)

          return unless excessive_whitespace?(text)

          add_whitespace_offense(node, text)
        end

        # @param text [String]
        def excessive_whitespace?(text)
          text.start_with?(' ') || text.include?('  ') || text.end_with?(' ')
        end

        # @param text [String]
        def strip_excessive_whitespace(text)
          text.strip.gsub(/  +/, ' ')
        end

        # @param node [RuboCop::AST::Node]
        # @param text [String]
        def add_whitespace_offense(node, text)
          docstring = docstring(node)
          corrected = strip_excessive_whitespace(text)

          add_offense(docstring) do |corrector|
            corrector.replace(docstring, corrected)
          end
        end

        def docstring(node)
          expr = node.loc.expression

          Parser::Source::Range.new(
            expr.source_buffer,
            expr.begin_pos + 1,
            expr.end_pos - 1
          )
        end

        # Recursive processing is required to process nested dstr nodes
        # that is the case for \-separated multiline strings with interpolation.
        def text(node)
          case node.type
          when :dstr
            node.node_parts.map { |child_node| text(child_node) }.join
          when :str, :sym
            node.value
          when :begin
            node.source
          end
        end
      end
    end
  end
end
