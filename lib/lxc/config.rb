################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
class LXC

  # Config Error Class
  class ConfigError < LXCError; end

  # Main Config Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Config

    attr_accessor :networks, :filename

    def initialize(lxc, filename)
      raise ConfigError, "You must supply a LXC object!" if lxc.nil?
      raise ConfigError, "You must supply a configuration filename!" if filename.nil?

      @lxc      = lxc
      @filename = filename

      self.clear
    end

    # Loads the specified LXC configuration
    #
    # Loads the filename specified at instantiation and converts it to an
    # internal hash so that we can manipulate it easier.
    #
    # @return [Hash] LXC configuration hash.
    def load
      parse_config(@lxc.exec("cat #{@filename} 2>/dev/null"))
    end

    # Saves the specified LXC configuration
    #
    # Saves the internal hash out to an LXC configuration file.
    #
    # @return [Hash] LXC configuration hash.
    def save
      use_sudo = (@lxc.use_sudo ? 'sudo ' : nil)

      script = Array.new
      script << "cat <<EOF | #{use_sudo}tee #{@filename}"
      script << build_config
      script << "EOF"
      script = script.join("\n")

      @lxc.exec(script)
    end

    # Clear configuration
    #
    # Clears out the current configuration, leaving an empty configuration
    # behind
    #
    # @return [Hash] LXC configuration hash.
    def clear
      @config   = Hash.new
      @networks = Array.new

      true
    end

    # Configuration keys
    #
    # Returns all of the configuration keys
    #
    # @return [Array] An array of the current configurations keys.
    def keys
      @config.keys
    end

    # Configuration Values
    #
    # Returns all of the configuration values
    #
    # @return [Array] An array of the current configurations values.
    def values
      @config.values
    end

    # Configuration Key/Value Assignment
    #
    # Allows setting the internal hash values.
    def []=(key, value)
      @config.merge!(key => [value]) { |k,o,n| k = (o + n) }
    end

    # Configuration Key/Value Query
    #
    # Allows getting the internal hash value for an internal hash key.
    def [](key)
      @config[key]
    end

    # Provides a concise string representation of the class
    # @return [String]
    def inspect
      @config.inspect
    end

  private

    def build_values(key, value)
      content = Array.new

      if value.is_a?(Array)
        value.each do |v|
          content << "#{key} = #{v}"
        end
      else
        content << "#{key} = #{value}"
      end

      content
    end

    def build_config
      content = Array.new
      @config.each do |key, value|
        content << build_values(key, value)
      end
      @networks.each do |network|
        network.each do |key, value|
          content << build_values(key, value)
        end
      end
      content.join("\n")
    end

    def parse_config(content)
      @config   = Hash.new
      @networks = Array.new
      network   = nil

      content.split("\n").map(&:strip).each do |line|
        key, value = line.split('=').map(&:strip)
        if key =~ /network/
          if key =~ /network.type/
            # this is a new network object
            @networks << network
            network = Hash.new
          else
            # add to previous network object
          end
          network.merge!(key => [value]) { |k,o,n| k = (o + n) }
        else
          @config.merge!(key => [value]) { |k,o,n| k = (o + n) }
        end
      end
      @networks << network
      @networks.compact!

      true
    end

  end
end
