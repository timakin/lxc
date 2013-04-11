class LXC
  class ContainerError < Error; end

  class Container

    STATES = %w(stopped starting running stopping aborting freezing frozen thawed)

    REGEX_STATE = /^state:\s+([\w]+)$/
    REGEX_PID = /^pid:\s+([\d]+)$/

################################################################################

    attr_reader :name

################################################################################

    def initialize(lxc, name)
      raise ContainerError, "You must supply a LXC object!" if lxc.nil?
      raise ContainerError, "You must supply a container name!" if (name.nil? || name.empty?)

      @lxc  = lxc
      @name = name
    end

################################################################################

    # Start the container
    #
    # Runs the "lxc-start" command with the "--daemon" flag.
    #
    # @param [Array] args Additional command-line arguments.
    def start(*args)
      self.exec("start", "--daemon", *args)
    end

    # Stop the container
    #
    # Runs the "lxc-stop" command.
    #
    # @param [Array] args Additional command-line arguments.
    def stop(*args)
      self.exec("stop", *args)
    end

    # Restart the container
    def restart(options={})
      self.stop
      self.start
    end
    alias :reload :restart

    # Freeze the container
    #
    # Runs the "lxc-freeze" command.
    #
    # @param [Array] args Additional command-line arguments.
    def freeze(*args)
      self.exec("freeze", *args)
    end

    # Unfreeze (thaw) the container
    #
    # Runs the "lxc-unfreeze" command.
    #
    # @param [Array] args Additional command-line arguments.
    def unfreeze(*args)
      self.exec("unfreeze", *args)
    end

    # Information on the container
    #
    # Runs the "lxc-info" command.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Array] Lines of output from the executed command.
    def info(*args)
      self.exec("info", *args).split("\n").uniq.flatten
    end

    # State of the container
    #
    # Runs the "lxc-info" command with the "--state" flag.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Symbol] Current state of the container.
    def state(*args)
      result = self.info("--state", *args).collect{ |str| str.scan(REGEX_STATE) }
      result.flatten!.compact!

      result.first.strip.downcase.to_sym
    end

    # PID of the container
    #
    # Runs the "lxc-info" command with the "--pid" flag.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Integer] Current PID of the container.
    def pid
      result = self.info("--pid").collect{ |str| str.scan(REGEX_PID) }
      result.flatten!.compact!

      result.first.strip.to_i
    end

################################################################################

    STATES.each do |state|
      define_method "#{state.downcase}?" do
        (self.state == state.downcase.to_sym)
      end
    end

################################################################################

    def exists?
      @lxc.exists?(self.name)
    end

################################################################################

    def exec(*args)
      arguments = Array.new
      arguments << args.shift
      arguments << "--name=#{self.name}"
      arguments << args
      arguments.flatten!.compact!

      puts("EXECUTE: #{arguments.inspect}")

      @lxc.exec(*arguments)
    end

################################################################################

    def inspect
      tags = Array.new
      tags << "name=#{self.name.inspect}"
      tags = tags.join(' ')

      "#<LXC::Container #{tags}>"
    end

################################################################################

  end
end
