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

        # @!method example_description(node)
        def_node_matcher :example_description, <<-PATTERN
          (block (send _ {#Examples.all #ExampleGroups.all} ${
            (str $_)
            $(dstr ({str dstr `sym} ...) ...)
          } ...) ...)
        PATTERN

        def on_block(node)
          example_description(node) do |description_node, message|
            current_text = text(message)
            correct_text = strip_excessive_whitespace(current_text)

            if current_text != correct_text
              add_whitespace_offense(description_node, correct_text, MSG)
            end
          end
        end

        private

        def strip_excessive_whitespace(text)
          text.strip.gsub(/  +/, ' ')
        end

        def add_whitespace_offense(node, correct_text, message)
          docstring = docstring(node)

          add_offense(docstring, message: message) do |corrector|
            corrector.replace(docstring, correct_text)
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
          return node unless node.respond_to?(:type)

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
