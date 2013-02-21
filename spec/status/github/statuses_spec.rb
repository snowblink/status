require 'spec_helper'

describe Status::Github::Statuses do
  subject { Status::Github::Statuses }

  before do
    @jenkins = stub
    stub_const("Status::Jenkins", @jenkins)
    Status.stub(:system_call)
  end

  it "has a payload target URL of the ci server URL and the branch name" do
    @jenkins.stub(:new => stub(:state => "success", :pass? => true, :target_url => :a_url))
    Status.stub(:ci_url => "http://jenkins-ci.org", :branch => "feature_branch")
    subject.new("pending", "feature_branch").send(:target_url).should == :a_url
  end

  it "has a payload description of the ci state and qa status" do
    @jenkins.stub(:new => stub(:state => "success"))
    subject.new("pending", "feature_branch").send(:description_text).should == "Build status: success, QA pending"
  end

  it "has a payload pending state when ci is passing but qa hasn't passed" do
    @jenkins.stub(:new => stub(:state => "pending", :pass? => true))
    subject.new("pending", "feature_branch").send(:state).should == "pending"
  end

  it "has a payload pending state when ci is pending but qa hasn't passed" do
    @jenkins.stub(:new => stub(:state => "pending", :pass? => false))
    subject.new("pending", "feature_branch").send(:state).should == "pending"
  end

  it "has a payload success state when ci is passing and qa has passed" do
    @jenkins.stub(:new => stub(:state => "success", :pass? => true))
    subject.new("pass", "feature_branch").send(:state).should == "success"
  end

  it "has a payloads success state when ci is n/a and qa has passed" do
    @jenkins.stub(:new => stub(:state => "success", :pass? => true))
    subject.new("n/a", "feature_branch").send(:state).should == "success"
  end

  it "has a payload error state when ci has an error" do
    @jenkins.stub(:new => stub(:state => "nothing", :pass? => false))
    subject.new("pass", "feature_branch").send(:state).should == "error"
  end

  it "goes to the correct status api" do
    @jenkins.stub(:new => stub)
    Status.stub(:owner => "owner", :repo => "status", :token => "123", :ci_url => "")
    status = subject.new("pending", "feature_branch")
    status.stub(:sha => "99efgd")
    status.send(:status_api).should == "/repos/owner/status/statuses/99efgd?access_token=123"
  end
end