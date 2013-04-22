require 'timeout'

class LXC

  # Container Error Class
  class ContainerError < LXCError; end

  # Main Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container

    # An array containing the valid container states extracted from the LXC
    # c-source code.
    STATES = %w(stopped starting running stopping aborting freezing frozen thawed).map(&:to_sym)

    # @!method stopped?
    #   Returns true if the container is stopped, false otherwise.
    #   @return [Boolean]
    #
    # @!method starting?
    #   Returns true if the container is starting, false otherwise.
    #   @return [Boolean]
    #
    # @!method running?
    #   Returns true if the container is running, false otherwise.
    #   @return [Boolean]
    #
    # @!method stopping?
    #   Returns true if the container is stopping, false otherwise.
    #   @return [Boolean]
    #
    # @!method aborting?
    #   Returns true if the container is aborting, false otherwise.
    #   @return [Boolean]
    #
    # @!method freezing?
    #   Returns true if the container is freezing, false otherwise.
    #   @return [Boolean]
    #
    # @!method frozen?
    #   Returns true if the container is frozen, false otherwise.
    #   @return [Boolean]
    #
    # @!method thawed?
    #   Returns true if the container is thawed, false otherwise.
    #   @return [Boolean]
    STATES.each do |state|
      define_method "#{state}?" do
        (self.state == state)
      end
    end

    # RegEx pattern for extracting the container state from the "lxc-info"
    # command output.
    REGEX_STATE = /^state:\s+([\w]+)$/

    # RegEx pattern for extracting the container PID from the "lxc-info"
    # command output.
    REGEX_PID = /^pid:\s+([-\d]+)$/

    # Returns the container name
    #
    # @return [String] Container name
    attr_reader :name

    def initialize(lxc, name)
      raise ContainerError, "You must supply a LXC object!" if lxc.nil?
      raise ContainerError, "You must supply a container name!" if (name.nil? || name.empty?)

      @lxc  = lxc
      @name = name
    end

    # Create the container
    #
    # Runs the "lxc-create" command.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Symbol] The state of the container.
    def create(*args)
      self.exec("lxc-create", *args)
      self.state
    end

    # Destroy the container
    #
    # Runs the "lxc-destroy" command.  If the container has not been stopped
    # first then this will fail unless '-f' is passed as an argument.  See
    # the 'lxc-destroy' man page for more details.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Symbol] The state of the container.
    def destroy(*args)
      self.exec("lxc-destroy", *args)
      self.state
    end

    # Start the container
    #
    # Runs the "lxc-start" command with the "--daemon" flag.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Symbol] The state of the container.
    def start(*args)
      self.exec("lxc-start", "--daemon", *args)
      self.state
    end

    # Stop the container
    #
    # Runs the "lxc-stop" command.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Symbol] The state of the container.
    def stop(*args)
      self.exec("lxc-stop", *args)
      self.state
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
    # @return [Symbol] The state of the container.
    def freeze(*args)
      self.exec("lxc-freeze", *args)
      self.state
    end

    # Unfreeze (thaw) the container
    #
    # Runs the "lxc-unfreeze" command.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Symbol] The state of the container.
    def unfreeze(*args)
      self.exec("lxc-unfreeze", *args)
      self.state
    end

    # Information on the container
    #
    # Runs the "lxc-info" command.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Array] Lines of output from the executed command.
    def info(*args)
      self.exec("lxc-info", *args).split("\n").uniq.flatten
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
    def pid(*args)
      result = self.info("--pid", *args).collect{ |str| str.scan(REGEX_PID) }
      result.flatten!.compact!

      result.first.strip.to_i
    end

    # Does the container exist?
    #
    # @return [Boolean] Returns true if the container exists, false otherwise.
    def exists?
      @lxc.exists?(self.name)
    end

    # Wait for a specific container state
    #
    # Runs the "lxc-wait" command.
    #
    # The timeout only works when using remote control via SSH and will orphan
    # the process ('lxc-wait') on the remote host.
    #
    # @param [Array] states An array of container states for which we will wait
    #   for the container to change state to.
    # @param [Integer] timeout How long in seconds we will wait before the
    #   operation times out.
    # @return [Boolean] Returns true of the state change happened, false
    #   otherwise.
    def wait(states, timeout=60)
      state_arg = states.map do |state|
        state.to_s.upcase.strip
      end.join('|')

      begin
        Timeout.timeout(timeout) do
          self.exec("lxc-wait", "-s", %('#{state_arg}'))
        end
      rescue Timeout::Error => e
        return false
      end

      true
    end

    # Linux container command execution wrapper
    #
    # Executes the supplied command by injecting the container name into the
    # argument list and then passes to the arguments to the top-level LXC class
    # exec method.
    #
    # @param [Array] args Additional command-line arguments.
    # @return [Array<String>] Stripped output text of the executed command.
    #
    # @see LXC#exec
    def exec(*args)
      arguments = Array.new
      arguments << args.shift
      arguments << %(--name=#{self.name})
      arguments << args
      arguments.flatten!.compact!

      @lxc.exec(*arguments)
    end

    # Provides a concise string representation of the class
    # @return [String]
    def inspect
      tags = Array.new
      tags << "name=#{self.name.inspect}"
      tags = tags.join(' ')

      "#<LXC::Container #{tags}>"
    end

  end
end
