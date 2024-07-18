# frozen_string_literal: true

require_relative "handlers/content_extractor"

module Vore
  # This is the class that starts and controls the crawling
  class Crawler
    PLATFORM = [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
    FILE_SEPERATOR = PLATFORM.include?("windows") ? File::ALT_SEPARATOR : File::SEPARATOR

    attr_reader :output_dir

    # Creates a crawler
    # denylist: Sets a denylist filter, allows a regexp, string or array of either to be matched.
    def initialize(denylist: /a^/, sanitization_config: Vole::Configuration::DEFAULT_SANITIZATION_CONFIG)
      @denylist_regexp = Regexp.union(denylist)

      @content_extractor = Vole::Handlers::ContentExtractor.new
      @selma = Selma::Rewriter.new(sanitizer: Selma::Sanitizer.new(sanitization_config), handlers: [@content_extractor])
      ext = PLATFORM.include?("windows") ? ".exe" : ""
      @executable = File.expand_path([__FILE__, "..", "..", "..", "exe", "vore-spider#{ext}"].join(FILE_SEPERATOR))
      @parent_output_dir = "tmp/vore"

      return if File.exist?(@executable)

      warn("ERROR: Unsupported platform: `#{PLATFORM}`")
      exit(1)
    end

    def scrape_each_page(website, &block)
      @output_dir = "#{@parent_output_dir}/#{website.gsub(/[^a-zA-Z0-9]/, "_").squeeze("_")}"
      Vore.logger.info("Vore started crawling #{website}, outputting to #{output_dir}")

      output = run_command(website, @output_dir)

      Vore.logger.info("Vore finished crawling #{website}: #{output}")

      results = {
        pages_visited: 0,
        pages_unprocessed: 0,
        unprocessed_pages: [],
      }

      Dir.glob(File.join(output_dir, "**", "*")).each do |path|
        next unless File.file?(path)

        results[:pages_visited] += 1

        html_file = File.read(path).force_encoding("UTF-8")
        rewritten_html_file = ""

        if html_file.empty?
          results[:pages_unprocessed] += 1
          results[:unprocessed_pages] << path
          next
        end

        begin
          rewritten_html_file = @selma.rewrite(html_file)
        rescue StandardError => e
          Vore.logger.warn("Error rewriting #{path}: #{e}")
          results[:pages_unprocessed] += 1
          next
        end

        # drops the first 3 parts of the path, which are "tmp", "vore", and the site name
        url_path = path.split(FILE_SEPERATOR)[3..].join("/")

        page = Vore::PageData.new(
          content: rewritten_html_file,
          title: @content_extractor.title,
          meta: @content_extractor.meta,
          path: url_path,
        )

        yield page
      ensure
        File.delete(path) if File.file?(path)
      end

      results
    end

    # def crawl(site, block)
    #   Vore.logger.info "Visiting #{site.url}, visited_links: #{@collection.visited_pages.size}, discovered #{@collection.discovered_pages.size}"
    #   crawl_site(site)
    # end

    def run_command(website, output_dir)
      %x(#{@executable} \
        --user-agent #{user_agent} \
        --delay 3500 \
        --url #{website} \
        download \
        -t \
        #{output_dir})
    end

    def user_agent
      "'Mozilla/5.0 (compatible; Vore/#{Vore::VERSION}; +https://github.com/gjtorikian/vore)'"
    end
  end
end
