require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "beehive"
    gem.summary = %Q{Beehive app}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "arilerner@mac.com"
    gem.homepage = "http://github.com/auser/beehive"
    gem.authors = ["Ari Lerner"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

namespace :erl do
  desc "Build erlang"
  task :build do
    puts `cd lib/erlang && make`
  end
  task :run => [:build] do
    Kernel.system "cd lib/erlang/scripts && ./start_router.sh"
  end
end

namespace :deploy do
  desc "Clean erlang"
  task :clean do
    Kernel.system "cd lib/erlang && make clean"
  end
  desc "Package erlang for deployment"
  task :pkg => :clean do
    Kernel.system "tar -cvzf pkg/router.tgz lib/erlang"
  end
end