#!/usr/bin/env ruby
require 'pathname'

unless ARGV.length >= 1 && ARGV.all? { |arg| File.exists?(arg) && File.directory?(arg) }
    STDERR.puts "Usage:"
    STDERR.puts "what-not-in-git.rb PATH_TO_PROJECTS [PATH_TO_PROJECTS ...]"
    exit 0
end

ARGV.map do |arg|
    if File.exists?(Pathname.new(arg) + ".git")
        arg
    else
        Dir.glob(Pathname.new(arg)+"*")
    end
end.flatten.each do |dir|
    next unless File.directory?(dir)
    
    print dir

    if File.exists?(Pathname.new(dir) + ".git")
        Dir.chdir(dir)
        git_status = `git status --porcelain --branch`
        if git_status.match(/^A/)
            puts " ❌ changes to be committed"
        elsif git_status.match(/^ M/)
            puts " ❌ modified files"
        elsif git_status.match(/^ D/)
            puts " ❌ deleted files"
        elsif git_status.include?("??")
            puts " ❌ untracked files"
        elsif git_status.match(/\A## master\.\.\..*\n\Z/)
            puts " clean ✅"
        elsif git_status.match(/\A## /)
            puts " ❌ not on master branch"
        else
            puts git_status.inspect
            exit(0)
        end
    else
        puts " ❌ not tracked in git"
    end
end
