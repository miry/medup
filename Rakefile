# frozen_string_literal: true

require 'rake/phony'

def version
  `shards version`.chop!
end

task default: %w[test]

desc "Run tests"
task test: :fmt do
  sh "crystal spec"
end

desc "Format crystal sources codes"
task :fmt do
  sh "crystal tool format"
end

task :setup

task release: %w[docker:push]

OUTPUT_PATH = "_output"
BIN_PATH = "#{OUTPUT_PATH}/medup"
directory OUTPUT_PATH

desc "Build app in #{OUTPUT_PATH}"
task build: BIN_PATH

task BIN_PATH => [OUTPUT_PATH] do |t|
  sh "crystal build --release --no-debug -o #{t.name} src/cli.cr"
end

desc "Run medup for provide user and distination via args."
task :run, [:user, :dist] => :build do |t, args|
  args.with_defaults(user: "miry", dist: "posts/medium_miry")
  sh "#{BIN_PATH} -u #{args.user} -d #{args.dist}"
end

namespace :docker do
  desc "Build docker image"
  task :build do
    sh "docker build -f Dockerfile -t miry/medup:#{version} -t miry/medup:latest ."
  end

  desc "Push docker image to Hub Docker"
  task push: %w[build] do
    sh "docker push miry/medup:#{version}"
    sh "docker push miry/medup:latest"
  end
end

namespace :github do
  desc "Create Github release"
  task :release do
    sh "hub release create -m 'v#{version}' v#{version}"
  end
end
