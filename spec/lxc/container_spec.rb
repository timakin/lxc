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

describe LXC::Container do

  TEST_CONTAINER_NAME = "test-container"

  subject { LXC::Container.new(:lxc => LXC.new, :name => TEST_CONTAINER_NAME) }

  describe "class" do

    it "should be an instance of LXC::Container" do
      subject.should be_an_instance_of LXC::Container
    end

    describe "attributes" do

      describe "#name" do
        it "should be readable and match what was passed to the initializer" do
          subject.name.should == TEST_CONTAINER_NAME
        end
      end

   end

  end

  describe "methods" do

    LXC_VERSIONS.each do |lxc_version|
      context "LXC Target Version #{lxc_version}" do

        describe "#not_created?" do
          it "should return true for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.not_created?.should == true
          end
        end

        describe "#stopped?" do
          it "should return true for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.stopped?.should == false
          end
        end

        describe "#starting?" do
          it "should return false for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.starting?.should == false
          end
        end

        describe "#running?" do
          it "should return false for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.running?.should == false
          end
        end

        describe "#stopping?" do
          it "should return false for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.stopping?.should == false
          end
        end

        describe "#aborting?" do
          it "should return false for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.aborting?.should == false
          end
        end

        describe "#freezing?" do
          it "should return false for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.freezing?.should == false
          end
        end

        describe "#frozen?" do
          it "should return false for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.frozen?.should == false
          end
        end

        describe "#thawed?" do
          it "should return false for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.thawed?.should == false
          end
        end

        describe "#exists?" do
          it "should return false for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-wo-containers.out") }

            subject.exists?.should == false
          end
        end

        describe "#pid" do
          it "should return -1 for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-pid-stopped.out") }

            subject.pid.should == -1
          end
        end

        describe "#state" do
          it "should return not_created for an un-created container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-info-state-stopped.out") }

            subject.state.should == :not_created
          end

          it "should return unknown for a created but missing container" do
            subject.lxc.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-w-containers.out") }

            subject.state.should == :unknown
          end
        end

        describe "#create" do
          it "should create the container specified in the configuration file" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-create.out") }
            subject.create('-f', '/etc/lxc/dummy', '-t', 'ubuntu')
          end
        end

        describe "#destroy" do
          it "should destroy the container specified in the configuration file" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-destroy.out") }
            subject.destroy
          end
        end

        describe "#start" do
          it "should start the container specified in the configuration file" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-start.out") }
            subject.start
          end
        end

        describe "#stop" do
          it "should stop the container specified in the configuration file" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-stop.out") }
            subject.stop
          end
        end

        describe "#restart" do
          it "should restart the container specified in the configuration file" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-restart.out") }
            subject.restart
          end
        end

        describe "#freeze" do
          it "should freeze the container specified in the configuration file" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-freeze.out") }
            subject.freeze
          end
        end

        describe "#unfreeze" do
          it "should unfreeze the container specified in the configuration file" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-unfreeze.out") }
            subject.unfreeze
          end
        end

        describe "#attach" do
          it "should execute the supplied command inside the container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-attach.out") }
            subject.attach('whoami').strip.should == 'root'
          end
        end

        describe "#execute" do
          it "should execute the supplied command inside the container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-attach.out") }
            subject.execute('whoami').strip.should == 'root'
          end
        end

        describe "#fs_root" do
          it "should return the path to our containers filesystem" do
            subject.fs_root.should == '/var/lib/lxc/test-container/rootfs'
          end
        end

        describe "#config" do
          it "should return an LXC::Config object" do
            subject.config.should be_kind_of(LXC::Config)
          end
        end

        describe "#wait" do
          it "should be successfully when waiting to stop a non-existant container" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-wait.out") }

            subject.wait([:stopped], 120).should == true
          end
        end

        describe "#inspect" do
          it "should return an information string about our class instance" do
            subject.inspect.should be_kind_of(String)
            subject.inspect.length.should be > 0
          end
        end

      end
    end

  end

end
