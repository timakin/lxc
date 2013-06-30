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

  # The runner we will use to execute all LXC commands.
  #
  # @overload runner=(value)
  #   Sets the runner to use.
  #   @param [LXC::Runner] value
  #
  # @overload runner
  #   Gets the runner we are using, if any.
  #
  # @return [LXC::Runner] Returns the instance of the runner we are using.
  attr_accessor :runner

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
    @runner   = (options[:runner] || LXC::Runner::Shell.new(:ui => @ui))
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
    @runner.exec(*args)
  end

  # Provides a concise string representation of the class
  # @return [String]
  def inspect
    tags = Array.new
    tags << "version=#{self.version.inspect}"
    tags << "runner=#{@runner.inspect}" if @runner
    tags = tags.join(' ')

    "#<LXC #{tags}>"
  end

end
