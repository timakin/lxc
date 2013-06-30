[![Gem Version](https://badge.fury.io/rb/lxc.png)](http://badge.fury.io/rb/lxc)
[![Dependency Status](https://gemnasium.com/zpatten/lxc.png)](https://gemnasium.com/zpatten/lxc)
[![Build Status](https://secure.travis-ci.org/zpatten/lxc.png)](http://travis-ci.org/zpatten/lxc)
[![Coverage Status](https://coveralls.io/repos/zpatten/lxc/badge.png?branch=master)](https://coveralls.io/r/zpatten/lxc)
[![Code Climate](https://codeclimate.com/github/zpatten/lxc.png)](https://codeclimate.com/github/zpatten/lxc)

# LXC RUBYGEM

RubyGem for controlling local or remote Linux Containers (LXC)

# EXAMPLES


Given the following code:

    require 'lxc'

    lxc = LXC.new
    lxc.version
    c = LXC::Container.new(:lxc => lxc, :name => 'test')
    c.running?
    c.exists?

Executed via the lxc-console development binary:

    $ bin/lxc-console

    From: /home/zpatten/code/personal/testlab-repo/vendor/checkouts/lxc/bin/lxc-console @ line 33 Object#lxc_console:

        24: def lxc_console
        25:   require 'pry'
        26:   require 'lxc'
        27:
        28:   ##
        29:   #
        30:   # Welcome to the LXC RubyGem console!
        31:   #
        32:   ##
     => 33:   binding.pry
        34: end

    [1] pry(main)> require 'lxc'
    => false
    [2] pry(main)>
    [3] pry(main)> lxc = LXC.new
    => #<LXC version="0.8.0-rc2" runner=#<LXC::Runner::Shell host="zsp-desktop" use_sudo=true>>
    [4] pry(main)> lxc.version
    => "0.8.0-rc2"
    [5] pry(main)> c = LXC::Container.new(:lxc => lxc, :name => 'test')
    => #<LXC::Container name="test">
    [6] pry(main)> c.running?
    => false
    [7] pry(main)> c.exists?
    => false
    [8] pry(main)>

# RUBIES TESTED AGAINST

* Ruby 1.8.7 (REE)
* Ruby 1.8.7 (MBARI)
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0

# RESOURCES

IRC:

* #jovelabs on irc.freenode.net

Documentation:

* http://zpatten.github.io/lxc/

Source:

* https://github.com/zpatten/lxc

Issues:

* https://github.com/zpatten/lxc/issues

# OFFICIAL LXC PROJECT

* http://lxc.sourceforge.net/
* https://github.com/lxc/lxc

# LICENSE

LXC RubyGem - RubyGem for controlling local or remote Linux Containers (LXC)

* Author: Zachary Patten <zachary AT jovelabs DOT com> [![endorse](http://api.coderwall.com/zpatten/endorsecount.png)](http://coderwall.com/zpatten)
* Copyright: Copyright (c) Zachary Patten
* License: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
