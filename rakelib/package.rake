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

TARGET = ENV["TOOLCHAIN"] || %x(rustc -vV | sed -n 's|host: ||p').strip
SPIDER_VERSION = "1.99.11"

def build
  dist_dir = if TARGET.include?("windows")
    ["dist", TARGET].join("\\")
  else
    File.join("dist", TARGET)
  end

  cmd = if TARGET.include?("aarch64") && TARGET.include?("linux")
    [
      "git clone --depth 1 --branch v#{SPIDER_VERSION} https://github.com/spider-rs/spider.git",
      "cp Cross.toml spider/spider_cli",
      "cd spider/spider_cli",
      "CROSS_CONFIG=Cross.toml cross build --release --target #{TARGET} --target-dir ../../#{dist_dir}",
    ].join(";\n")
  else
    "cargo install --root #{dist_dir} --version #{SPIDER_VERSION} --target #{TARGET} spider_cli"
  end

  puts "Running `#{cmd}`"
  %x(#{cmd})

  FileUtils.mkdir_p("exe")
  executable = if TARGET.include?("windows")
    [dist_dir, "bin", "spider.exe"].join("\\")
  elsif TARGET.include?("aarch64") && TARGET.include?("linux")
    File.join(dist_dir, TARGET, "release", "spider")
  else
    File.join(dist_dir, "bin", "spider")
  end

  dest_dir = if TARGET.include?("windows")
    [BASE_GEMSPEC.bindir, "vore-spider.exe"].join("\\")
  else
    File.join(BASE_GEMSPEC.bindir, "vore-spider")
  end
  FileUtils.cp(executable, dest_dir)
end

NATIVE_PLATFORMS.each do |platform, _executable|
  BASE_GEMSPEC.dup.tap do |gemspec|
    exedir = File.join(gemspec.bindir)
    ext = platform.include?("windows") ? ".exe" : ""
    exepath = File.join(exedir, "vore-spider#{ext}")

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
