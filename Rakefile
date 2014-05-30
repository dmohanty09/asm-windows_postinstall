require 'puppetlabs_spec_helper/rake_tasks'

# Customize lint option
task :lint do
  PuppetLint.configuration.send("disable_80chars")
  PuppetLint.configuration.send("disable_class_parameter_defaults")
  PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
end

desc "Validate manifests, templates, and ruby files in lib."
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['lib/**/*.rb'].each do |lib_file|
    sh "ruby -c #{lib_file}"
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

# Initialize vagrant instance for testing
task :vagrant do
  Rake::Task["spec_prep"].execute
  IO.popen('vagrant up --provider=vmware_fusion') do |io|
    io.each{ |line| print line }
  end
end

# Cleanup vagrant environment
task :vagrant_clean do
  `vagrant destroy -f`
  Rake::Task["spec_clean"].execute
end
