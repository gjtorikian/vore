# frozen_string_literal: true

require "rubygems/package_task"

PLATFORM = [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")

# keep this synchronized with vore/crawler.rb
NATIVE_PLATFORMS = {
  "arm64-darwin" => "exe/aarch64-apple-darwin",
  "x86_64-darwin" => "exe/x86_64-apple-darwin",

  "arm64-linux" => "exe/aarch64-unknown-linux-gnu",
  "x86_64-linux" => "exe/x86_64-unknown-linux-gnu",

  "x86_64-windows" => "exe/x86_64-pc-windows-msvc",
}

BASE_GEMSPEC = Bundler.load_gemspec("vore.gemspec")

gem_path = Gem::PackageTask.new(BASE_GEMSPEC).define
desc "Build the ruby gem"
task "gem:ruby" => [gem_path]

desc "Build native executables"
namespace :build do
  task :native do
    system("make dist")
  end
end
task gem: "build:native" # rubocop:disable Rake/Desc

exedir = File.join(gemspec.bindir, NATIVE_PLATFORMS[PLATFORM])
exepath = File.join(exedir, "spider")

gemspec.platform = platform
gemspec.files << exepath

gem_path = Gem::PackageTask.new(gemspec).define
desc "Build the #{platform} gem"
task "gem:#{platform}" => [gem_path]

directory exedir
file exepath => [exedir] do
  FileUtils.cp(executable, exepath)
  FileUtils.chmod(0o755, exepath)
end

CLOBBER.add(exedir)

CLOBBER.add("dist")
