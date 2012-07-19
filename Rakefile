require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

gemspec = eval(File.read("class_inheritable.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["class_inheritable.gemspec"] do
  system "gem build class_inheritable.gemspec"
  system "gem install class_inheritable-#{ClassInheritable::VERSION}.gem"
end
