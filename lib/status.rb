# coding: utf-8

begin
  require 'rubygems'
rescue LoadError
end

require 'fileutils'
require 'multi_json'
require 'rest-client'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'status/base'
require 'status/jenkins'
require 'status/config'
require 'status/request'

require 'status/github/statuses'
require 'status/github/pull_request'

module Status
  extend self

  def config
    @config ||= Status::Config.new
  end

  def token
    Status.config.parsed[:github_token]
  end

  def repo
    Status.config.parsed[:github_repo]
  end

  def owner
    Status.config.parsed[:github_owner]
  end

  def ci_url
    Status.config.parsed[:ci_url]
  end

  def ci_user
    Status.config.parsed[:ci_username]
  end

  def ci_password
    Status.config.parsed[:ci_password]
  end

  def qa_required?
    Status.config.parsed[:qa_required].nil? ? true : Status.config.parsed[:qa_required]
  end

  def system_call(cmd)
    `#{cmd}`
  end

  def system_warn(cmd)
    Kernel.warn cmd
  end
end
