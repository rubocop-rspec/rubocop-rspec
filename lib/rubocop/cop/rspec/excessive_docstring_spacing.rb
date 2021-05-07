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
          (block (send _ {:describe :context :it} ${
            (str $_)
            $(dstr ({str `sym} ...) ...)
          } ...) ...)
        PATTERN

        def on_block(node)
          example_description(node) do |description_node, message|
            current_text = text(message)
            correct_text = current_text.strip

            if current_text != correct_text
              add_whitespace_offense(description_node, MSG)
            end
          end
        end

        private

        def add_whitespace_offense(node, message)
          docstring = docstring(node)

          add_offense(docstring, message: message) do |corrector|
            corrector.replace(docstring, replacement_text(node))
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

        def replacement_text(node)
          text = text(node)

          text.strip
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
