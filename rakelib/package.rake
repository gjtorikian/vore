# frozen_string_literal: true

require "rubygems/package_task"

PLATFORM = [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")

NATIVE_PLATFORMS = {
  "arm64-darwin" => "aarch64-apple-darwin",
  "x86_64-darwin" => "x86_64-apple-darwin",

  "arm64-linux" => "aarch64-unknown-linux-gnu",
  "x86_64-linux" => "x86_64-unknown-linux-gnu",

  "x86_64-windows" => "x86_64-pc-windows-msvc",
}

BASE_GEMSPEC = Bundler.load_gemspec("vore.gemspec")

desc "Compile the gem"
task "compile" do
  build
end

gem_path = Gem::PackageTask.new(BASE_GEMSPEC).define
desc "Build the ruby gem"
task "gem:ruby" => [gem_path]

desc "Build native executables"
namespace :build do
  task :native do
    build
  end
end
task gem: "build:native" # rubocop:disable Rake/Desc

TARGET = %x(rustc -vV | sed -n 's|host: ||p').strip
SPIDER_VERSION = "1.99.5"
def build
  cmd = "cargo install --root dist/#{TARGET} --version #{SPIDER_VERSION} --target #{TARGET} spider_cli"
  puts "Running `#{cmd}`"
  %x(#{cmd})
  FileUtils.mkdir_p("exe")
  FileUtils.mv("dist/#{TARGET}/bin/spider", "exe/spider")
end

BASE_GEMSPEC.dup.tap do |gemspec|
  exedir = File.join(gemspec.bindir, NATIVE_PLATFORMS[PLATFORM])
  exepath = File.join(exedir, "spider")

  gemspec.platform = PLATFORM
  gemspec.files << exepath

  distdir = File.join("dist", NATIVE_PLATFORMS[PLATFORM])
  distpath = File.join(distdir, "bin", "spider")
  gem_path = Gem::PackageTask.new(gemspec).define

  desc "Build the #{PLATFORM} gem"
  task "gem:#{PLATFORM}" => [gem_path]

  directory exedir
  file exepath => [exedir] do
    FileUtils.cp(distpath, exepath)
    FileUtils.chmod(0o755, exepath)
  end

  CLOBBER.add(exedir)
end

CLOBBER.add("dist")
