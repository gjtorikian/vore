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

namespace :build do
  desc "Build native executables"
  task :native do
    build
  end
end
task gem: "build:native" # rubocop:disable Rake/Desc

TARGET = ENV.fetch("TOOLCHAIN", %x(rustc -vV | sed -n 's|host: ||p').strip)
SPIDER_VERSION = "1.99.5"
def build
  cmd = "cargo install --root dist/#{TARGET} --version #{SPIDER_VERSION} --target #{TARGET} spider_cli"
  puts "Running `#{cmd}`"
  %x(#{cmd})
  FileUtils.mkdir_p("exe")
  FileUtils.cp("dist/#{TARGET}/bin/spider", "exe/vore-spider")
end

NATIVE_PLATFORMS.each do |platform, executable|
  BASE_GEMSPEC.dup.tap do |gemspec|
    exedir = File.join(gemspec.bindir)
    exepath = File.join(exedir, "vore-spider")

    gemspec.platform = platform
    gemspec.files << exepath

    gem_path = Gem::PackageTask.new(gemspec).define

    desc "Build the #{platform} gem"
    task "gem:#{platform}" => [gem_path]

    directory exedir
    file exepath => [exedir] do
      FileUtils.chmod(0o755, exepath)
    end

    CLOBBER.add(exedir)
  end
end

CLOBBER.add("dist")
