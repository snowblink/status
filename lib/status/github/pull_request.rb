# coding: utf-8

module Status
  module Github
    class PullRequest
      def initialize(branch)
        @branch = branch
      end

      def pull_request_found?
        !get_pull_request.select {|pull| pull["head"]["ref"] == @branch}.empty?
      end

      def create_pull_request
        puts "No pull request found, create one? (y/n)"
        answer = gets
        answer.chomp.downcase == "y" ? new_pull_request : abort("exit")
      end

      def new_pull_request
        response = post_pull_request
        puts response == "not found" ? response : response["url"]
      end

      def payload
        puts "enter a description"
        body = gets

        {:title => title, :body => body, :base => "master", :head => @branch }
      end

      def title
        `git log #{@branch} -1 --pretty=format:'%s'`
      end

      def get_pull_request
        Status::Request.new.get(pull_request_api)
      end

      def post_pull_request
        Status::Request.new.post(pull_request_api, payload)
      end

      def pull_request_api
        "/repos/#{Status.owner}/#{Status.repo}/pulls?access_token=#{Status.token}"
      end
    end
  end
end
