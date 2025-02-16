require 'openai'
require 'json'

class Dockerize
  OPENAI_API_KEY = ENV['OPENAI_API_KEY']
  MODEL = "gpt-4"

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
exec "$@"
"""
    File.open("entrypoint.sh", 'w') { |file| file.write(content) }
  end

  private

  def self.generate_dockerfile(options)
    prompt = """
Generate a Dockerfile for a Ruby on Rails application with the following specifications:
- Ruby version: #{options[:ruby_version]}
- Bundler version: #{options[:bundler_version]}
- Include PostgreSQL client and Node.js
- Set up working directory `/myapp`
- Install dependencies from Gemfile
- Use entrypoint script `/usr/bin/entrypoint.sh`
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
    client = OpenAI::Client.new(access_token: OPENAI_API_KEY)
    response = client.chat(parameters: {
      model: MODEL,
      messages: [{ role: "system", content: "You are an expert in Docker configurations." },
                 { role: "user", content: prompt }],
      max_tokens: 500
    })
    response.dig("choices", 0, "message", "content").strip
  end
end
