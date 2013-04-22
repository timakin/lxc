class LXC

  # Config Error Class
  class ConfigError < LXCError; end

  # Main Config Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Config

    def initialize(lxc, filename)
      raise ConfigError, "You must supply a LXC object!" if lxc.nil?
      raise ConfigError, "You must supply a configuration filename!" if filename.nil?

      @lxc      = lxc
      @filename = filename

      self.load
    end

    # Loads the specified LXC configuration
    #
    # Loads the filename specified at instantiation and converts it to an
    # internal hash so that we can manipulate it easier.
    #
    # @return [Hash] LXC configuration hash.
    def load
      @config = parse_config(@lxc.exec("cat #{@filename} 2>/dev/null"))
    end

    # Saves the specified LXC configuration
    #
    # Saves the internal hash out to an LXC configuration file.
    #
    # @return [Hash] LXC configuration hash.
    def save
      use_sudo = (@lxc.use_sudo ? 'sudo ' : '')

      script = Array.new
      script << "cat <<EOF | #{use_sudo}tee #{@filename}"
      script << build_config
      script << "EOF"
      script = script.join("\n")

      @lxc.exec(script)

      @config
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
      @config.merge!(key => value)
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

    def build_config
      content = Array.new
      @config.each do |key, value|
        content << "#{key} = #{value}"
      end
      content.sort.join("\n")
    end

    def parse_config(content)
      config = Hash.new

      content.split("\n").map(&:strip).each do |line|
        key, value = line.split('=').map(&:strip)
        config.merge!(key => value)
      end

      config
    end

  end
end
