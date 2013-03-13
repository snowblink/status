# coding: utf-8

module Status
  class Jenkins

    def initialize(branch, sha=nil)
      @branch = branch.gsub(/\//, "_")
      @branch = @branch + "-" + Status.repo
      @sha = sha
    end

    def target_url
      build_url || "#{Status.ci_url}/job/#{@branch}"
    end

    def state
      status
    end

    def pass?
      status == "success"
    end

    private

    def path
      "/job/#{@branch}/#{build}/api/json"
    end

    def status
      @status ||= ci_status
    end

    def ci_status
      return "pending" if any_pending_reasons?
      return "failure" if result_is_failure?
      "success"
    end

    def build
      return last_build["number"] if last_build
      "lastBuild"
    end

    def result_is_failure?
      response["result"].downcase != "success"
    end

    def build_url
      if last_build.nil?
        return
      end
      last_build["url"]
    end

    def last_build
      @last_build ||= get_build_for_sha
    end

    def get_build_for_sha
      return unless @sha
      ci_response["builds"].each do |build|
        return build if last_build_contails_sha?(build)
        return build if build_is_in_change_set?(build)
      end
      nil
    end

    def any_pending_reasons?
      response == "not found" || queued? || response["building"] == true
    end

    def response
      @response ||= Request.new(:ci).get(path)
    end

    def ci_response
      @ci_response ||= Request.new(:ci).get("/job/#{@branch}/api/json?depth=1")
    end

    def queued?
      (!!ci_response["queueItem"]).tap do |queued|
        if queued
          reasons = ci_response["queueItem"]["why"]
          message = "Your build (#{@branch}) is in a queue."
          message += "\n#{reasons}" if reasons
          Status.system_warn(message)
        end
      end
    end

    def last_build_contails_sha?(build)
      return false if build["actions"].nil? || build["actions"][1].nil?
      build["actions"][1]["lastBuiltRevision"]["SHA1"] =~ /^#{@sha}/
    end

    def build_is_in_change_set?(build)
      return false if build["changeSet"].nil?
      build["changeSet"]["items"].any? do |item|
        item["commitId"] =~ /^#{@sha}/
      end
    end
  end
end
