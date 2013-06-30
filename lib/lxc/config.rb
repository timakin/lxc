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
      use_sudo = (@lxc.runner.use_sudo ? 'sudo ' : nil)

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

    NETWORK_KEY_ORDER = %w(lxc.network.type lxc.network.flags lxc.network.link lxc.network.name lxc.network.hwaddr lxc.network.ipv4 lxc.network.ipv6)

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
        network_keys = (network.keys - NETWORK_KEY_ORDER)
        NETWORK_KEY_ORDER.each do |key|
          network.has_key?(key) and (content << build_values(key, network[key]))
        end
        network_keys.each do |key|
          content << build_values(key, network[key])
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
        if key =~ /lxc\.network/
          if key =~ /lxc\.network\.type/
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
