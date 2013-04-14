require "spec_helper"

describe LXC do

  subject { LXC.new }

  describe "class" do

    it "should be an instance of LXC" do
      subject.should be_an_instance_of LXC
    end

    describe "defaults" do

      it "should have use_sudo set to false" do
        subject.use_sudo.should == false
      end

      it "should have use_ssh set to nil" do
        subject.use_ssh.should == nil
      end

    end

  end

  describe "methods" do

    LXC_VERSIONS.each do |lxc_version|
      context "LXC Target Version #{lxc_version}" do

        describe "#ls" do

          context "with containers" do

            it "should return an array of strings populated with container names" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-w-containers.out") }

              subject.ls.should be_kind_of(Array)
              subject.ls.should_not be_empty
              subject.ls.size.should eq(1)
            end

          end

          context "without containers" do

            it "should return an empty array" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-wo-containers.out") }

              subject.ls.should be_kind_of(Array)
              subject.ls.should be_empty
              subject.ls.size.should eq(0)
            end

          end

        end

        describe "#exists?" do

          context "with containers" do

            it "should return false if the container does not exist" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-w-containers.out") }
              subject.exists?("abc-123-test-container-name").should == false
            end

            it "should return true if the container does exist" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-w-containers.out") }
              subject.exists?("devop-test-1").should == true
            end

          end

          context "without containers" do

            it "should return false if the container does not exist" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-wo-containers.out") }
              subject.exists?("abc-123-test-container-name").should == false
            end

            it "should return false if the container does not exist" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-wo-containers.out") }
              subject.exists?("devop-test-1").should == false
            end

          end

        end

        describe "#ps" do
          it "should return an array of strings representing the lxc process list" do
            subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ps.out") }

            subject.ps.should be_kind_of(Array)
            subject.ps.should_not be_empty
          end
        end

        describe "#version" do
          it "should return a string representation of the installed LXC version" do
            subject.stub(:exec) { lxc_fixture(lxc_version, 'lxc-version.out') }

            subject.version.should be_kind_of(String)
            subject.version.should_not be_empty
            subject.version.should == lxc_version
          end
        end

        describe "#checkconfig" do
          it "should return an array of strings representing the LXC configuration" do
            subject.stub(:exec) { lxc_fixture(lxc_version, 'lxc-checkconfig.out') }

            subject.checkconfig.should be_kind_of(Array)
            subject.checkconfig.should_not be_empty

            subject.checkconfig.first.should be_kind_of(String)
            subject.checkconfig.first.should_not be_empty
          end
        end

        describe "#container" do
          it "should return a container object for the requested container" do
            result = subject.container("devop-test-1")
            result.should be_an_instance_of(::LXC::Container)
          end
        end

        describe "#containers" do

          context "with containers" do
            it "should return an array of container objects" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-w-containers.out") }

              subject.containers.should be_kind_of(Array)
              subject.containers.size.should eq(1)
            end
          end

          context "without containers" do
            it "should return an empty array" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-ls-wo-containers.out") }

              subject.containers.should be_kind_of(Array)
              subject.containers.size.should eq(0)
            end
          end

        end

        describe "#inspect" do
          it "should return an information string about our class instance" do
            subject.inspect.should be_kind_of(String)
            subject.inspect.length.should be > 0
          end
        end

        describe "#exec" do

          context "against local host" do
            it "should exec the supplied LXC command" do
              subject.stub(:exec) { lxc_fixture(lxc_version, "lxc-version.out") }

              subject.exec("version").should be_kind_of(String)
            end
          end

          context "against remote host" do
            before(:each) do
              @ssh_connection = ::ZTK::SSH.new(
                :host_name => "127.0.0.1",
                :user => ENV['USER'],
                :keys => "#{ENV['HOME']}/.ssh/id_rsa"
              ).ssh
            end

            it "should exec the supplied LXC command" do
              subject.use_ssh = @ssh_connection
              subject.exec("version").should be_kind_of(String)
            end
          end if !ENV['CI'] && !ENV['TRAVIS']

        end

      end # LXC Version Context
    end # LXC_VERSIONS

  end

end
