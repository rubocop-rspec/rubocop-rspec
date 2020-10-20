# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Rails
        # Checks for persistence calls outside example blocks.
        #
        # Prevents persistence calls outside examples which usually run
        # with some sort of cleanup hook. Saving outside of example causes
        # records to leak into other tests.
        #
        # @ example
        #   # bad - records created outside example group
        #   describe User do
        #     User.create!
        #   end
        #
        #   describe User do
        #     user = User.new
        #     user.save!
        #   end
        #
        #   # good - records created inside an example group
        #   describe User do
        #     it do
        #       User.create!
        #     end
        #   end
        #
        #   describe User do
        #     it do
        #       user = User.new
        #       user.save!
        #     end
        #   end
        class PersistenceCalledOutsideExample < Base
          MSG = 'Persistence called outside of example.'

          def on_send(node)
            return if inside_example_scope?(node) ||
              inside_method_definition?(node) ||
              inside_proc_or_lambda?(node) ||
              allowed_method?(node)
            return unless inside_describe_block?(node)
            return unless persistent_call?(node)

            add_offense(node)
          end

          private

          def inside_example_scope?(node)
            node.each_ancestor(:block).any?(&method(:example_scope?))
          end

          def example_scope?(node)
            example?(node) ||
              let?(node) ||
              hook?(node) ||
              subject?(node)
          end

          def inside_method_definition?(node)
            node.each_ancestor(:def).any?
          end

          def inside_proc_or_lambda?(node)
            node.each_ancestor(:block).any?(&:lambda_or_proc?)
          end

          def allowed_method?(node)
            allowed_methods.include?(node.method_name.to_s)
          end

          def allowed_methods
            cop_config['AllowedMethods'] || []
          end

          def inside_describe_block?(node)
            node.each_ancestor(:block).any?(&method(:spec_group?))
          end

          def persistent_call?(node)
            method_name = node.method_name.to_s

            forbidden_methods.include?(method_name)
          end

          def forbidden_methods
            cop_config['ForbiddenMethods'] || []
          end
        end
      end
    end
  end
end
