require 'chatgpt'
require 'json'

class Dockerize
  ChatGPT.configure do |config|
    config.api_key = ENV['OPENAI_API_KEY']
    config.api_version = 'v1'
    config.default_engine = 'gpt-4'
    config.request_timeout = 30
    config.max_retries = 2
    config.default_parameters = {
      max_tokens: 300,
      temperature: 0.5,
      top_p: 1.0,
      n: 1
    }
  end

  def self.dockerfile(options: {})
    content = generate_dockerfile(options)
    File.open("Dockerfile", 'w') { |file| file.write(content) }
  end

  def self.dockercompose
    content = generate_dockercompose
    File.open("docker-compose.yml", 'w') { |file| file.write(content) }
  end

  def self.entrypoint
    content = """#!/bin/bash
set -e
rm -f /myapp/tmp/pids/server.pid
exec $@
"""
    File.open("entrypoint.sh", 'w') { |file| file.write(content) }
  end

  private

  def self.generate_dockerfile(options)
    prompt = """
Generate a Dockerfile for a Ruby on Rails application with the following specifications:
- Ruby version: #{options[:ruby_version] || "3.3.3"}
- Bundler version: #{options[:bundler_version] || "2.3.26"}
- Include PostgreSQL client and Node.js
- Set up working directory `/myapp`
- Install dependencies from Gemfile
- Expose port 3000 and run Rails server
"""
    call_openai(prompt)
  end

  def self.generate_dockercompose
    prompt = """
Generate a docker-compose.yml file for a Ruby on Rails application with the following setup:
- PostgreSQL database service with volume storage
- Web service that depends on the database
- Proper command setup for starting the Rails app
- Port mappings: 3000 for web, 5432 for database
- Bind-mount the application directory
"""
    call_openai(prompt)
  end

  def self.call_openai(prompt)
    client = ChatGPT::Client.new
    response = client.chat(
      [
        { role: "system", content: "You are an expert in Docker configurations." },
        { role: "user", content: prompt }
      ],
      model: 'gpt-4'
    )
    parse(response.dig("choices", 0, "message", "content").strip)
  end

  def self.parse(string)
    reg = /```Dockerfile\n(.*)```/m
    reg.match(string)[1]
  end
end
