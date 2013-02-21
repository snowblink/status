# coding: utf-8
require "yaml"

module Status
  class Config
    FILE = ".status.yml"

    attr_reader :parsed
    def initialize
      bootstrap
      validate
    end

    def validate
      validate_presence_of :owner
      validate_presence_of :repo
      validate_presence_of :token
      validate_presence_of :ci_url, "ci"
      validate_presence_of :username, "ci"
      validate_presence_of :password, "ci"
    end

    def bootstrap
      @parsed = begin
        YAML.load(File.open(FILE))
      rescue Exception => e
        create_file
        puts "Could not parse YAML file #{FILE}: #{e.message}"
        abort("exit")
      end
    end

    private

    def validate_presence_of(sym, type="github")
      unless parsed.include?(sym)
        puts "Please update #{FILE} with a #{sym} for #{type}"
        abort("exit")
      end
    end

    def create_file
      puts "No #{FILE} found, create one? (y/n)"
      answer = gets
      if answer.chomp.downcase == "y"
        data = {
          :username => "Jenkins username",
          :password => "Jenkins password",
          :ci_url => "eg. http://ci.jenkins.com",
          :owner => "eg. dougdroper",
          :repo => "eg. status",
          :token => "Githubs API token (http://developer.github.com/v3/oauth/)",
          :qa_required => "true"
        }
        File.open(FILE, 'w') {|f| f.write(data.to_yaml)}
        puts "Please update #{FILE} and then run status"
        abort("exit")
      end
    end
  end
end