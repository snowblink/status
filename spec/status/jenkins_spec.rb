require 'spec_helper'

describe Status::Jenkins do

  subject {Status::Jenkins.new("")}

  before do
    Status.stub(:config => stub(:attrs => {}, :parsed => {}))
    Status::Request.any_instance.stub(:get)
    Status.stub(:system_warn)
  end

  context "#state" do
    it "changes slashes to underscores" do
      Status::Jenkins.new("dr/feature").send(:path).should == "/job/dr_feature/lastBuild/api/json"
    end

    it "is success when ci result is success" do
      Status::Request.stub(:new => stub(:get => {"building" => false, "result" => "success"}))
      subject.state.should == "success"
    end

    it "is pending when ci result is building" do
      Status::Request.stub(:new => stub(:get => {"building" => true, "result" => "success"}))
      subject.state.should == "pending"
    end

    it "is pending when ci result is in any other state" do
      Status::Request.stub(:new => stub(:get => {"building" => true, "result" => "failed"}))
      subject.state.should == "pending"
    end

    it "is pending when ci result is not found" do
      Status::Request.stub(:new => stub(:get => "not found"))
      subject.state.should == "pending"
    end

    it "is failure when ci result is failure" do
      Status::Request.stub(:new => stub(:get => {"building" => false, "result" => "failure"}))
      subject.state.should == "failure"
    end
  end

  context "#target_url" do
    it "has the last build in the path as default" do
      Status::Request.stub(:new => stub(:get => {"builds" => []}))
      Status::Jenkins.new("dr/feature", '481002a').target_url.should == "/job/dr_feature"
    end

    it "has the last build number in the path as when last build contains sha" do
      build = {"number" => 12, "actions" => [{},{"lastBuiltRevision" => {"SHA1" => "481002a"}}], "url" => "/job/dr_feature/12/api/json"}
      Status::Request.stub(:new => stub(:get => {"builds" => [build]}))
      Status::Jenkins.new("dr/feature", '481002a').target_url.should == "/job/dr_feature/12/api/json"
    end

    it "has he last build number when the build is in the change set" do
      build = {"number" => 12, "changeSet" => {"items" => [{"commitId" => "481002a"}]}, "actions" => [], "url" => "/job/dr_feature/12/api/json"}
      Status::Request.stub(:new => stub(:get => {"builds" => [build]}))
      Status::Jenkins.new("dr/feature", '481002a').target_url.should == "/job/dr_feature/12/api/json"
    end
  end
end
