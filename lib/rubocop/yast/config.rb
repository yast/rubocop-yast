# encoding: utf-8

require "yaml"

module RuboCop
  module Yast
    # patch the Rubocop config - include the plugin defaults
    module Config
      DEFAULT = File.expand_path("../../../../config/default.yml", __FILE__)

      def self.load_defaults
        plugin_config = YAML.load_file(DEFAULT)
        config = ConfigLoader.merge_with_default(plugin_config, DEFAULT)

        ConfigLoader.instance_variable_set(:@default_configuration, config)
      end
    end
  end
end
