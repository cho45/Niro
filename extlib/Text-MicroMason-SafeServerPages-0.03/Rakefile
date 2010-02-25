require "rubygems"
require "rake"
require "shipit"
require "pathname"

makefilepl = Pathname.new("Makefile.PL").read
mainmodule = Pathname.new("lib/Text/MicroMason/SafeServerPages.pm").read

NAME        = makefilepl[/name '([^']+)';/, 1]
VERS        = mainmodule[/our \$VERSION = '([^']+)';/, 1]
DESCRIPTION = mainmodule[/=head1 NAME\s+\S+ - (.*)/, 1]

task :default => :test

desc "make test"
task :test => ["Makefile"] do
	sh %{make test}
end

desc "make clean"
task :clean => ["Makefile"] do
	sh %{make clean}
end

desc "make install"
task :install => ["Makefile"] do
	sh %{sudo make install}
end

desc "release"
task :release => :shipit

task :shipit => [:test, "MANIFEST"]
Rake::ShipitTask.new do |s|
	ENV["LANG"] = "C"
	s.Step.new {
		# check
		system("svn", "up")
		raise "Any chages remain?\n#{`svn st`}" unless `svn st`.empty?
	}.and {}
	s.Step.new {
		system "shipit", "-n"
		print "Check dry-run result and press Any Key to continue (or cancel by Ctrl-C)."
		$stdin.gets
	}.and {
		system "shipit"
	}
end

file "Makefile" => ["Makefile.PL"] do
	sh %{perl Makefile.PL}
end

file "Makefile.PL"

file "MANIFEST" => Dir["**/*"].delete_if {|i| i == "MANIFEST" }  do
	rm "MANIFEST" if File.exist?("MANIFEST")
	sh %{perl Makefile.PL}
	sh %{make}
	sh %{make manifest}
end
