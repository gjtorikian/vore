# frozen_string_literal: true

require_relative "handlers/meta_extractor"
require_relative "handlers/tag_remover"

require "listen"

module Vore
  # This is the class that starts and controls the crawling
  class Crawler
    PLATFORM = [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
    FILE_SEPERATOR = PLATFORM.include?("windows") ? File::ALT_SEPARATOR : File::SEPARATOR

    attr_reader :handlers, :output_dir

    # Creates a crawler
    # denylist: Sets a denylist filter, allows a regexp, string or array of either to be matched.
    def initialize(sanitization_config: Vore::Configuration::DEFAULT_SANITIZATION_CONFIG, handlers: nil, options: {})
      @meta_extractor = Vore::Handlers::MetaExtractor.new

      @handlers = if handlers.nil?
        [@meta_extractor, Vore::Handlers::TagRemover.new]
      else
        handlers.unshift(@meta_extractor)
      end

      @selma = Selma::Rewriter.new(sanitizer: Selma::Sanitizer.new(sanitization_config), handlers: @handlers)
      ext = PLATFORM.include?("windows") ? ".exe" : ""
      @executable = File.expand_path([__FILE__, "..", "..", "..", "exe", "vore-spider#{ext}"].join(FILE_SEPERATOR))
      @options = Vore::Configuration::DEFAULT_OPTIONS.merge(options)
      @parent_output_dir = @options[:output_dir]
      @parent_output_dir_len = @parent_output_dir.to_s.split(FILE_SEPERATOR).size

      Vore.logger.level = @options[:log_level]
      Listen.logger = Vore.logger

      @results = {
        pages_visited: 0,
        unprocessed_pages: [],
      }

      return if File.exist?(@executable)

      warn("ERROR: Unsupported platform: `#{PLATFORM}`")
      exit(1)
    end

    def scrape_each_page(website, &block)
      @output_dir = "#{@parent_output_dir}/#{website.gsub(/[^a-zA-Z0-9]/, "_").squeeze("_")}"
      FileUtils.rm_rf(@output_dir)
      FileUtils.mkdir_p(@output_dir)

      listener = Listen.to(@output_dir) do |_modified, added, _removed|
        if added.any?
          added.each do |path|
            process_file(path, &block)
            File.delete(path) if @options[:delete_after_yield]
          end
        end
      end
      listener.start

      Vore.logger.info("Vore started crawling #{website}, outputting to #{output_dir}")

      begin
        run_command(website, delay: @options[:delay])
      ensure
        sleep(0.5) # give listener time to clean up
        listener.stop
      end

      Vore.logger.info("Vore finished crawling #{website}")

      @results
    end

    def process_file(path, &block)
      @results[:pages_visited] += 1

      html_file = File.read(path).force_encoding("UTF-8")

      if html_file.empty?
        @results[:unprocessed_pages] << path
        return
      end

      rewritten_html_file = @selma.rewrite(html_file)
      return if rewritten_html_file.empty?

      # drops the first 3 parts of the path, which are "tmp", "vore", and the site name
      url_path = path.split(FILE_SEPERATOR)[(@parent_output_dir_len + 1)..].join("/")

      page = Vore::PageData.new(
        content: rewritten_html_file,
        title: @meta_extractor.title,
        meta: @meta_extractor.meta,
        path: url_path,
      )

      yield page
    end

    def rewrite(html_file)
      @selma.rewrite(html_file)
    rescue StandardError => e
      Vore.logger.warn("Error rewriting #{path}: #{e}")
      @results[:unprocessed_pages] << path
      ""
    end

    def run_command(website, delay: 0)
      pid = Process.spawn(
        @executable,
        "--user-agent",
        user_agent,
        "--delay",
        delay.to_s,
        "--url",
        website,
        "download",
        "-t",
        @output_dir,
      )

      _, _status = Process.waitpid2(pid)
    rescue StandardError => e
      Vore.logger.error(e)
    end

    def user_agent
      "'Mozilla/5.0 (compatible; Vore/#{Vore::VERSION}; +https://github.com/gjtorikian/vore)'"
    end
  end
end
