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
