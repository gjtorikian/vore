# frozen_string_literal: true

module Vore
  class Configuration
    DEFAULT_SANITIZATION_CONFIG = Selma::Sanitizer::Config::RELAXED.dup.merge({
      allow_doctype: false,
    })

    DEFAULT_OPTIONS = {
      delay: 0,
      output_dir: "tmp/vore",
      delete_after_yield: true,
      log_level: :warn,
    }
  end
end
