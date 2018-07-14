module RuboCop
  module Cop
    module RSpec
      # Prefer `match_array` when matching array values.
      #
      # @example
      #   # bad
      #   it { is_expected.to contain_exactly(*array1, *array2) }
      #
      #   # good
      #   it { is_expected.to match_array(array1 + array2) }
      #
      #   # good
      #   it { is_expected.to contain_exactly(content, *array) }
      class ContainExactly < Cop
        MSG = 'Prefer `match_array` when matching array values.'.freeze

        def on_send(node)
          return unless node.method_name == :contain_exactly
          return unless node.each_child_node.all?(&:splat_type?)

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            arrays = node.arguments.map do |splat_node|
              splat_node.children.first
            end
            corrector.replace(
              node.source_range,
              "match_array(#{arrays.map(&:source).join(' + ')})"
            )
          end
        end
      end
    end
  end
end
