# frozen_string_literal: true

module Vole
  class Configuration
    DEFAULT_SANITIZATION_CONFIG = Selma::Sanitizer::Config::RELAXED.dup.merge({
      allow_doctype: false,
    })
  end
end
