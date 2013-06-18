require 'ztk'

require 'lxc/version'

# Top-Level LXC Class
#
# @author Zachary Patten <zachary AT jovelabs DOT com>
class LXC

  # Top-Level Error Class
  class LXCError < StandardError; end

  autoload :Config,    'lxc/config'
  autoload :Container, 'lxc/container'
  autoload :Runner,    'lxc/runner'

  # Controls if sudo is prefixed on all executed commands.
  #
  # @overload use_sudo=(value)
  #   Sets if all executed commands should be prefixed with sudo.
  #   @param [Boolean] value
  #
  # @overload use_sudo
  #   Gets if we are prefixing all executed commands with sudo.
  #
  # @return [Boolean] Returns true if we are prefixing commands with "sudo";
  #   otherwise false.
  attr_accessor :use_sudo

  # Controls if executed commands run locally or remotely via a Net::SSH
  # Session.
  #
  # @overload use_ssh=(value)
  #   Sets if all executed commands should be run locally or remotely.
  #   To force commands to run locally, assign a value of nil (default).
  #   To force commands to run remotely, assign a valid, active, Net::SSH
  #   Session.
  #
  # @overload use_ssh
  #   Gets if we are executing commands locally or remotely.
  #
  # @return [Net::SSH::Connection::Session] Returns nil if disabled; otherwise
  #   returns the assigned Net::SSH Session object.
  attr_accessor :use_ssh

  # RegEx pattern for extracting the LXC Version from the "lxc-version" command
  # output.
  REGEX_VERSION = /^lxc version:\s+([\w\W]+)$/

  # @param [Hash] options Options hash.
  # @option options [Boolean] :use_sudo (false) Whether or not to prefix all
  #   commands with 'sudo'.
  # @option options [Net::SSH,ZTK::SSH,nil] :use_ssh (nil) Whether or not to
  #   execute all commands remotely via an SSH connection.
  def initialize(options={})
    @ui       = (options[:ui] || ZTK::UI.new)
    @use_sudo = (options[:use_sudo] || false)
    @use_ssh  = (options[:use_ssh] || nil)
  end

  # LXC configuration class
  #
  # Gets the LXC configuration class object
  #
  # @return [LXC::Config] Returns the LXC configuration object.
  def config
    @config ||= LXC::Config.new(self, "/etc/lxc/lxc.conf")
  end

  # Initialize container object
  #
  # Initalizes an LXC::Container class for the supplied container name.
  #
  # @param [String] name The container name to initalize.
  # @return [LXC::Container] Returns the container object.
  def container(name)
    LXC::Container.new(:lxc => self, :name => name)
  end

  # Current containers
  #
  # Initalizes an LXC::Container object for all containers and returns them in
  # an Array.
  #
  # @return [Array<LXC::Container>]
  def containers
    container_names = self.ls
    container_names.map do |container_name|
      LXC::Container.new(:lxc => self, :name => container_name)
    end
  end

  # List of containers
  #
  # Runs the "lxc-ls" command.
  #
  # @param [Array] args Additional command-line arguments.
  # @return [Array<String>] A list of container names.
  def ls(*args)
    self.exec("lxc-ls", *args).split("\n").join(' ').split.uniq
  end

  # Check if a container exists
  #
  # Checks the container name list to see if the name supplied is an existing
  # container.
  #
  # @param [String] name The name of the container to check.
  # @return [Boolean] Returns true of the container exists, false otherwise.
  def exists?(name)
    self.ls(%(-1)).include?(name)
  end

  # Linux container processes
  #
  # Runs the "lxc-ps" command.
  #
  # @param [Array] args Additional command-line arguments.
  # @return [Array<String>] Output text of the "lxc-ps" command.
  def ps(*args)
    self.exec("lxc-ps", *args).split("\n")
  end

  # Linux container version
  #
  # Runs the "lxc-version" command.
  #
  # @param [Array] args Additional command-line arguments.
  # @return [String] The installed version of LXC.
  def version(*args)
    result = self.exec("lxc-version", *args).scan(REGEX_VERSION)
    result.flatten!.compact!

    result.first.strip
  end

  # Linux container configuration check
  #
  # Runs the "lxc-checkconfig" command.
  #
  # @param [Array] args Additional command-line arguments.
  # @return [Array<String>] Output text of the "lxc-checkconfig" command.
  def checkconfig(*args)
    ZTK::ANSI.uncolor(self.exec("lxc-checkconfig", *args)).split("\n")
  end

  # Linux container command execution wrapper
  #
  # Runs the supplied LXC command.  The first element in the "args" splat is the
  # command to be execute, the rest of the elements are treated as command line
  # arguments.
  #
  # If use_sudo is true then all commands will be prefix with "sudo".
  # If use_ssh is non-nil then all commands will be execute via the assigned
  # Net::SSH Session.
  #
  # @param [Array] args Additional command-line arguments.
  # @return [Array<String>] Stripped output text of the executed command.
  def exec(*args)
    command = args.shift

    arguments = Array.new
    arguments << %(sudo) if (@use_sudo == true)
    arguments << command
    arguments << args
    arguments = arguments.flatten.compact.join(' ')

    output = Array.new

    if @use_ssh.nil?
      begin
        ::ZTK::PTY.spawn(arguments) do |reader, writer, pid|
          while (buffer = reader.readpartial(1024))
            output << buffer
          end
        end
      rescue EOFError
        # NOOP
      end
    else
      if @use_ssh.is_a?(ZTK::SSH)
        output << @use_ssh.exec(arguments, :silence => true, :ignore_exit_status => true).output
      else
        if @use_ssh.respond_to?(:exec!)
          output << @use_ssh.exec!(arguments)
        else
          raise LXCError, "The object you assigned to use_ssh does not respond to #exec!"
        end
      end
    end

    output.join.strip
  end

  # Provides a concise string representation of the class
  # @return [String]
  def inspect
    tags = Array.new
    tags << "use_sudo=#{@use_sudo}" if @use_sudo
    tags << (@use_ssh.nil? ? "use_ssh=false" : "use_ssh=true")
    tags = tags.join(' ')

    "#<LXC #{tags}>"
  end

end
