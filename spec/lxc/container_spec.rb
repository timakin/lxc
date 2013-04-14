require "spec_helper"

describe LXC::Container do

  TEST_CONTAINER_NAME = "test-container"

  subject { LXC::Container.new(LXC.new, TEST_CONTAINER_NAME) }

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

    describe "#exists?" do
      it "should return false for an un-created remote container" do
        subject.exists?.should == false
      end
    end

    describe "#pid" do
      it "should return -1 for an un-created remote container" do
        subject.pid.should == -1
      end
    end

    describe "#state" do
      it "should return stopped for an un-created remote container" do
        subject.state.should == :stopped
      end
    end

    describe "#wait" do
      it "should be successfully when waiting to stop a non-existant remote container" do
        subject.wait([:stopped], 120).should == true
      end
    end

  end

end
