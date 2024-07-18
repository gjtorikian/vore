# frozen_string_literal: true

require_relative "handlers/content_extractor"

module Vore
  # This is the class that starts and controls the crawling
  class Crawler
    PLATFORM = [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")

    # Creates a crawler
    # denylist: Sets a denylist filter, allows a regexp, string or array of either to be matched.
    def initialize(denylist: /a^/, sanitization_config: Vole::Configuration::DEFAULT_SANITIZATION_CONFIG)
      @denylist_regexp = Regexp.union(denylist)

      @selma = Selma::Rewriter.new(sanitizer: Selma::Sanitizer.new(sanitization_config), handlers: [Vole::Handlers::ContentExtractor.new])
      @executable = File.expand_path(File.join("exe", "vore-spider"))
      @output_dir = "tmp/vore"

      return if File.exist?(@executable)

      warn("ERROR: Unsupported platform: `#{PLATFORM}`")
      exit(1)
    end

    def scrape_each_page(website, &block)
      output_dir = "#{@output_dir}/#{website.gsub(/[^a-zA-Z0-9]/, "_").squeeze("_")}"
      Vore.logger.info("Vore started crawling #{website}, outputting to #{output_dir}")

      output = %x(#{@executable} \
        --user-agent #{user_agent} \
        --url #{website} \
        download \
        -t \
        #{output_dir})

      Vore.logger.info("Vore finished crawling #{website}: #{output}")

      Dir.glob("tmp/**/*").each do |path|
        next unless File.file?(path)

        html_file = File.read(path)
        rewritten_html_file = @selma.rewrite(html_file)

        yield rewritten_html_file
      ensure
        File.delete(path) if File.file?(path)
      end
    end

    # def crawl(site, block)
    #   Vore.logger.info "Visiting #{site.url}, visited_links: #{@collection.visited_pages.size}, discovered #{@collection.discovered_pages.size}"
    #   crawl_site(site)
    # end

    def user_agent
      "'Mozilla/5.0 (compatible; Vore/#{Vore::VERSION}; +https://github.com/gjtorikian/vore)'"
    end
  end
end
