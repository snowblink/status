# coding: utf-8

module Status
  module Github
    class Statuses
      def initialize(qa_status, branch, user_sha=nil)
        @qa_status = qa_status
        @branch = branch
        @user_sha = user_sha
        @jenkins = Jenkins.new(branch, sha)
      end

      def request
        Request.new.post(status_api, payload)
      end

      private

      def status_api
        "/repos/#{Status.owner}/#{Status.repo}/statuses/" + sha + "?access_token=" + Status.token
      end

      def description
        "Build status: #{@jenkins.state}, QA #{@qa_status}"
      end

      def payload
        {:state => state, :description => description, :target_url => target_url}
      end

      def target_url
        @jenkins.target_url
      end

      def state
        return "success" if @jenkins.pass? && @qa_status == "pass"
        return "pending" if @jenkins.pass? && @qa_status != "pass"
        return "pending" if @jenkins.state == "pending"
        git_state
      end

      def git_state
        states.include?(@jenkins.state) ? states[states.index(@jenkins.state)] : "error"
      end

      def states
        %w(error failure)
      end

      def sha
        @user_sha || `git log #{@branch} -1 --pretty=format:'%H'`
      end
    end
  end
end