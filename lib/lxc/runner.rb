require 'timeout'

class LXC

  # Runner Error Class
  class RunnerError < LXCError; end

  # Main Runner Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Runner

    autoload :Shell, 'lxc/runners/shell'
    autoload :SSH,   'lxc/runners/ssh'

  end
end
