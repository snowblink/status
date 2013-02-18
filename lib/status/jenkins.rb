# coding: utf-8

module Status
  class Jenkins
    attr_reader :target_url

    def target_url
      @build_url || "#{Status.ci_url}/job/#{@branch}"
    end

    def initialize(branch, sha=nil)
      @branch = branch.gsub(/\//, "_")
      @branch = @branch + "-" + Status.repo
      @sha = sha
      @build = "lastBuild"
      @queued = false
      @build_url = nil
      find_build_for(sha)
      warn "No build found for SHA #{@sha}" unless @build_url
    end

    # The only states github's API acccepts are "success", "failure", "pending", and "error".

    def state
      return "success" if pass?
      @status
    end

    def pass?
      @status ||= get_ci_status
      return false unless @status == "success"
      true
    end

    def get_ci_status
      response = Request.new(:ci).get(path)
      return "pending" if response == "not found" || @queued || response["building"] == true || @build_url.nil?
      return "failure" unless response["result"].downcase == "success"
      "success"
    end

    def path
      "/job/#{@branch}/#{@build}/api/json"
    end

    private

    def find_build_for(sha)
      return nil unless sha
      response = Request.new(:ci).get("/job/#{@branch}/api/json?depth=1")
      if response["queueItem"]
        @queued = true
        warn "Your build for SHA #{@sha} is in a queue."
        @build_url = response["url"]
        return
      end
      response["builds"].sort{|a,b| b["number"].to_i <=> a["number"].to_i}.each do |build|
        if build["actions"][1]["lastBuiltRevision"]["SHA1"] =~ /^#{@sha}/
          @build = build["number"]
          @build_url = build["url"]
          return
        else
          build["changeSet"]["items"].each do |item|
            if item["commitId"] =~ /^#{@sha}/
              @build = build["number"]
              @build_url = build["url"]
              return
            end
          end
        end
      end
    end
  end
end


