# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Checks for create_list usage.
        #
        # This cop can be configured using the `EnforcedStyle` option
        #
        # @example `EnforcedStyle: create_list`
        #   # bad
        #   3.times { create :user }
        #
        #   # good
        #   create_list :user, 3
        #
        #   # good
        #   3.times { |n| create :user, created_at: n.months.ago }
        #
        # @example `EnforcedStyle: n_times`
        #   # bad
        #   create_list :user, 3
        #
        #   # good
        #   3.times { create :user }
        class CreateList < Base
          extend AutoCorrector
          include ConfigurableEnforcedStyle

          MSG_CREATE_LIST = 'Prefer create_list.'
          MSG_N_TIMES = 'Prefer %<number>s.times.'
          RESTRICT_ON_SEND = %i[create_list].freeze

          # @!method n_times_block_without_arg?(node)
          def_node_matcher :n_times_block_without_arg?, <<-PATTERN
            (block
              (send (int _) :times)
              (args)
              ...
            )
          PATTERN

          # @!method factory_call(node)
          def_node_matcher :factory_call, <<-PATTERN
            (send ${(const nil? {:FactoryGirl :FactoryBot}) nil?} :create (sym $_) $...)
          PATTERN

          # @!method factory_list_call(node)
          def_node_matcher :factory_list_call, <<-PATTERN
            (send {(const nil? {:FactoryGirl :FactoryBot}) nil?} :create_list (sym _) (int $_) ...)
          PATTERN

          def on_block(node)
            return unless style == :create_list
            return unless n_times_block_without_arg?(node)
            return unless contains_only_factory?(node.body)

            add_offense(node.send_node, message: MSG_CREATE_LIST) do |corrector|
              CreateListCorrector.new(node.send_node).call(corrector)
            end
          end

          def on_send(node)
            return unless style == :n_times

            factory_list_call(node) do |count|
              message = format(MSG_N_TIMES, number: count)
              add_offense(node.loc.selector, message: message) do |corrector|
                TimesCorrector.new(node).call(corrector)
              end
            end
          end

          private

          def contains_only_factory?(node)
            if node.block_type?
              factory_call(node.send_node)
            else
              factory_call(node)
            end
          end

          # :nodoc
          module Corrector
            private

            def build_options_string(options)
              options.map(&:source).join(', ')
            end

            def format_method_call(node, method, arguments)
              if node.block_type? || node.parenthesized?
                "#{method}(#{arguments})"
              else
                "#{method} #{arguments}"
              end
            end

            def format_receiver(receiver)
              return '' unless receiver

              "#{receiver.source}."
            end
          end

          # :nodoc
          class TimesCorrector
            include Corrector

            def initialize(node)
              @node = node
            end

            def call(corrector)
              replacement = generate_n_times_block(node)
              corrector.replace(node, replacement)
            end

            private

            attr_reader :node

            def generate_n_times_block(node)
              factory, count, *options = node.arguments

              arguments = factory.source
              options = build_options_string(options)
              arguments += ", #{options}" unless options.empty?

              replacement = format_receiver(node.receiver)
              replacement += format_method_call(node, 'create', arguments)
              "#{count.source}.times { #{replacement} }"
            end
          end

          # :nodoc:
          class CreateListCorrector
            include Corrector

            def initialize(node)
              @node = node.parent
            end

            def call(corrector)
              replacement = if node.body.block_type?
                              call_with_block_replacement(node)
                            else
                              call_replacement(node)
                            end

              corrector.replace(node, replacement)
            end

            private

            attr_reader :node

            def call_with_block_replacement(node)
              block = node.body

              factory, *options = *block.send_node.arguments

              replacement = format_receiver(block.send_node.receiver)

              process_arguments(options) do |traits, static, dynamic|
                arguments = "#{factory.source}, #{node.receiver.source}"
                arguments += ", #{build_options_string(traits)}" if traits.any?
                arguments += ", #{build_options_string(static)}" if static.any?

                replacement += format_method_call(block, 'create_list', arguments)
                replacement += format_block(block, dynamic)
              end

              replacement
            end

            def call_replacement(node)
              block = node.body
              factory, *options = *block.arguments

              replacement = format_receiver(block.receiver)

              process_arguments(options) do |traits, static, dynamic|
                arguments = "#{factory.source}, #{node.receiver.source}"
                arguments += ", #{build_options_string(traits)}" if traits.any?
                arguments += ", #{build_options_string(static)}" if static.any?
                replacement += format_method_call(block, 'create_list', arguments)
                replacement += create_block(factory.value, dynamic) if dynamic.any?
              end

              replacement
            end

            def create_block(factory, arguments)
              block = " do |#{factory}|\n"
              arguments.each do |pair|
                block += "#{factory}.#{pair.key.source} = #{pair.value.source}\n"
              end
              block += "end"
            end


            def format_block(node, dynamic)
              if node.body.begin_type? || dynamic.any?
                format_multiline_block(node, dynamic)
              else
                format_singeline_block(node)
              end
            end

            def format_multiline_block(node, dynamic)
              indent = ' ' * node.body.loc.column
              indent_end = ' ' * node.parent.loc.column
              factory = node.arguments.first.source

              block = " do |#{factory}|\n"
              dynamic.each do |pair|
                block += "#{indent}#{factory}.#{pair.key.source} = #{pair.value.source}\n"
              end
              block += "#{indent}#{node.body.source}\n"
              block += "#{indent_end}end"
            end

            def format_singeline_block(node)
              " { #{node.arguments.source} #{node.body.source} }"
            end

            def process_arguments(options)
              traits = options.reject(&:hash_type?)
              properties = options.select(&:hash_type?).flat_map(&:pairs)
              static, dynamic = properties.partition { |pair| pair.value.literal? }

              yield traits, static, dynamic
            end
          end
        end
      end
    end
  end
end
