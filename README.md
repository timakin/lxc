[![Gem Version](https://badge.fury.io/rb/lxc.png)](http://badge.fury.io/rb/lxc)
[![Dependency Status](https://gemnasium.com/zpatten/lxc.png)](https://gemnasium.com/zpatten/lxc)
[![Build Status](https://secure.travis-ci.org/zpatten/lxc.png)](http://travis-ci.org/zpatten/lxc)
[![Coverage Status](https://coveralls.io/repos/zpatten/lxc/badge.png?branch=master)](https://coveralls.io/r/zpatten/lxc)
[![Code Climate](https://codeclimate.com/github/zpatten/lxc.png)](https://codeclimate.com/github/zpatten/lxc)

# LXC

An interface for controlling local or remote Linux Containers (LXC).

# EXAMPLES


Given the following code:

    require 'lxc'

    lxc = LXC.new(:use_sudo => true)
    lxc.use_sudo = true
    lxc.version
    c = LXC::Container.new(:lxc => lxc, :name => 'test')
    c.running?
    c.exists?

Executed via the lxc-console development binary:

    $ be ./bin/lxc-console

    From: /home/zpatten/Dropbox/code/personal/testlab-repo/vendor/checkouts/lxc/bin/lxc-console @ line 12 Object#lxc_console:

         3: def lxc_console
         4:   require 'pry'
         5:   require 'lxc'
         6:
         7:   ##
         8:   #
         9:   # Welcome to the LXC RubyGem console!
        10:   #
        11:   ##
     => 12:   binding.pry
        13: end

    [1] pry(main)> require 'lxc'
    => false
    [2] pry(main)>
    [3] pry(main)> lxc = LXC.new(:use_sudo => true)
    => #<LXC use_sudo=true use_ssh=false>
    [4] pry(main)> lxc.use_sudo = true
    => true
    [5] pry(main)> lxc.version
    => "0.8.0-rc2"
    [6] pry(main)> c = LXC::Container.new(:lxc => lxc, :name => 'test')
    => #<LXC::Container name="test">
    [7] pry(main)> c.running?
    => false
    [8] pry(main)> c.exists?
    => false
    [9] pry(main)>


# RESOURCES

Documentation:

* http://zpatten.github.io/lxc/

Source:

* https://github.com/zpatten/lxc

Issues:

* https://github.com/zpatten/lxc/issues

# LICENSE

LXC - An interface for controlling local or remote Linux Containers (LXC)

* Author: Zachary Patten <zachary@jovelabs.com> [![endorse](http://api.coderwall.com/zpatten/endorsecount.png)](http://coderwall.com/zpatten)
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
