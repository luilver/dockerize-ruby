class Dockerize
  def self.dockerfile(options: {})
    File.open("Dockerfile", 'w') do |file|
      file.write """# syntax=docker/dockerfile:1
FROM ruby:#{options[:ruby_version]}
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler -v #{options[:bundler_version]}
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [\"entrypoint.sh\"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD [\"rails\", \"server\", \"-b\", \"0.0.0.0\"]"""
    end
  end

  def self.dockercompose
    File.open("docker-compose.yml", 'w') do |file|
      file.write """version: \"3.9\"
services:
  db:
    image: postgres
    volumes:
      - ./tmp/db:/var/lib/postgresql/data
    ports:
      - \"5432:5432\"
    environment:
      POSTGRES_PASSWORD: password
  web:
    build: .
    command: bash -c \"rm -f tmp/pids/server.pid && bundle exec rails db:migrate && bundle exec rails s -p 3000 -b '0.0.0.0'\"
    volumes:
      - .:/myapp
    ports:
      - \"3000:3000\"
    depends_on:
      - db"""
    end
  end

  def self.entrypoint
    File.open("entrypoint.sh", 'w') do |file|
      file.write """#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec \"$@\""""
    end
  end
end
