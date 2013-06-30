class LXC
  class Runner

    class ShellError < RunnerError; end

    class Shell
      require 'socket'

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

      # @param [Hash] options Options hash.
      # @option options [Boolean] :use_sudo (false) Whether or not to prefix all
      #   commands with 'sudo'.
      def initialize(options={})
        @hostname = Socket.gethostname.split('.').first.strip

        @ui       = (options[:ui]       || ZTK::UI.new)
        @use_sudo = (options[:use_sudo] || true)
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

        begin
          ::ZTK::PTY.spawn(arguments) do |reader, writer, pid|
            while (buffer = reader.readpartial(1024))
              output << buffer
            end
          end
        rescue EOFError
          # NOOP
        end

        output.join.strip
      end

      # File I/O Wrapper
      #
      # This method renders the supplied *content* to the file named *name* on
      # the LXC host.
      #
      # @param [Hash] options The options hash.
      # @option options [String] :target The target file on the remote host.
      # @option options [String] :chown A user:group representation of who
      #   to change ownership of the target file to (i.e. 'root:root').
      # @option options [String] :chmod An octal file mode which to set the
      #   target file to (i.e. '0755').
      # @return [Boolean] True if successful.
      def file(name, options={}, &block)
        flags  = (options[:flags] || 'w')
        mode   = (options[:mode]  || nil)

        target = options[:target]
        chown  = options[:chown]
        chmod  = options[:chmod]

        target.nil? and raise SSHError, "You must supply a target file!"
        !block_given? and raise SSHError, "You must supply a block!"

        File.open(target, flags, mode) do |file|
          yield(file)
          file.respond_to?(:flush) and file.flush
        end

        chown.nil? or self.exec(%(chown -v #{chown} #{target}))
        chmod.nil? or self.exec(%(chmod -v #{chmod} #{target}))
      end

      # Provides a concise string representation of the class
      # @return [String]
      def inspect
        tags = Array.new
        tags << "host=#{@hostname.inspect}"
        tags << "use_sudo=#{@use_sudo.inspect}"
        tags = tags.join(' ')

        "#<#{self.class} #{tags}>"
      end

    end
  end
end
