################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
require "spec_helper"

describe LXC::Config do

  subject {
    config_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'support', 'fixtures', 'test-container'))

    @lxc = LXC.new(:use_sudo => true)
    lxc_config = LXC::Config.new(@lxc, config_file)
    lxc_config.load

    lxc_config
  }

  describe "class" do

    it "should be an instance of LXC::Config" do
      subject.should be_an_instance_of LXC::Config
    end

    describe "attributes" do

      describe "networks" do
        it "should define our network interfaces" do
          subject.networks.count.should == 1
          subject.networks.should be_kind_of(Array)
          subject.networks.first.should be_kind_of(Hash)
          subject.networks.first.keys.should_not be_empty
          subject.networks.first.values.should_not be_empty
        end
      end

    end

  end

  describe "methods" do

    describe "#load" do
      it "should load the configuration from the file on disk" do
        subject['lxc.utsname'].first.should == 'server-east-1'
      end
    end

    describe "#keys" do
      it "should return all of the keys in the configuration" do
        subject.keys.should be_kind_of(Array)
        subject.keys.should_not be_empty
      end
    end

    describe "#values" do
      it "should return all of the values in the configuration" do
        subject.values.should be_kind_of(Array)
        subject.values.should_not be_empty
      end
    end

    describe "#inspect" do
      it "should return a concise string representation of the instance" do
        subject.inspect.should be_kind_of(String)
        subject.inspect.should_not be_empty
      end
    end

    describe "#save" do
      it "should allow us to save the configuration to disk" do
        subject.filename = Tempfile.new('save').path
        subject.save
      end
    end

  end

end
