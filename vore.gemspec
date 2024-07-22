# frozen_string_literal: true

require_relative "lib/vore/version"

Gem::Specification.new do |spec|
  spec.name = "vore"
  spec.version = Vore::VERSION
  spec.authors = ["Garen J. Torikian"]
  spec.email = ["gjtorikian@users.noreply.github.com"]

  spec.summary = "Quickly crawls websites and spits out text sans tags. Powered by Rust."
  spec.homepage = "https://github.com/gjtorikian/vore"
  spec.license = "MIT"
  spec.required_ruby_version = "~> 3.1"
  # https://github.com/rubygems/rubygems/pull/5852#issuecomment-1231118509
  spec.required_rubygems_version = ">= 3.3.22"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gjtorikian/vore"

  spec.files = ["LICENSE.txt", "README.md", "Cargo.lock", "Cargo.toml"]
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("ext/**/*.{rs,toml,lock,rb}")

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  # spec.extensions = ["ext/vore/Cargo.toml"]

  spec.add_dependency("listen", "~> 3.9")
  spec.add_dependency("selma", "~> 0.4")
end
