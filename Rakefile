#!/usr/bin/env rake

require "bundler/gem_tasks"

FileList['tasks/**/*.rake'].each(&method(:import))

task default: :spec

desc 'Run all specs'
task ci: %w[ spec ]
