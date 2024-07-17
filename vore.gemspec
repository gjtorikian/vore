# frozen_string_literal: true

require_relative "lib/vore/version"

Gem::Specification.new do |spec|
  spec.name = "vore"
  spec.version = Vore::VERSION
  spec.authors = ["Garen J. Torikian"]
  spec.email = ["gjtorikian@users.noreply.github.com"]

  spec.summary = "Quickly consume websites and spit out text."
  spec.homepage = "https://github.com/gjtorikian/vore"
  spec.license = "MIT"
  spec.required_ruby_version = "~> 3.1"
  # https://github.com/rubygems/rubygems/pull/5852#issuecomment-1231118509
  spec.required_rubygems_version = ">= 3.3.22"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gjtorikian/vore"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(["git", "ls-files", "-z"], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?("bin/", "test/", "spec/", "features/", ".git", ".github", "appveyor", "Gemfile")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/vore/Cargo.toml"]

  spec.add_dependency("selma", "~> 0.4")
end
