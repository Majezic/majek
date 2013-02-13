require 'md_inc'

# Add Octopress commands to MdInc.
module MdInc
  module Commands
    class << self
      def octo_tag(name, attrs=[], lines=[])
        output = []
        output << "{% #{([name] + attrs).join(" ")} %}"
        unless lines.empty?
          output += lines
          output << "{% end#{name} %}"
        end
        output
      end

      # Public: Octopress command to include other files.
      #
      # path  - Path to the file to be included.
      # attrs - Array of attributes passed to the Octopress tag.
      #
      # Examples
      #
      #   .codeblock 'snippets/stub-spec.rb', 'ruby'
      #   # =>
      #   # {% codeblock ruby %}
      #   # contents of snippets/stub-spec.rb
      #   # {% endcodeblock %}
      #
      # Returns the Octopress tag as a String Array.
      %w(blockquote codeblock pullquote).each do |meth|
        define_method(meth) { |path, *attrs| octo_tag(meth, attrs, inc(path)) }
      end

      # Public: Octopress command that doesn't include anything; only added for
      # consistency and convenience.
      #
      # attrs - Array of attributes passed to the Octopress tag.
      #
      # Examples
      #
      #   .gist 1234
      #   # => {% gist 1234 %}
      #
      #   .img 'left', 'http://placekitten.com/320/250', 'Place Kitten #2'
      #   # => {% img left http://placekitten.com/320/250 Place Kitten #2 %}
      #
      # Returns the Octopress tag as a String Array.
      %w(gist img include_code jsfiddle render_partial video).each do |meth|
        define_method(meth) { |*attrs| octo_tag(meth, attrs) }
      end
    end
  end
end

module Md2Jekyll
  class Application
    MATCH_TITLE = %r{^# (.+)$}

    def initialize(argv)
      @filename = argv.first
      @base_dir = File.dirname(File.expand_path(@filename))
    end

    def run
      markdown = File.read(@filename)
      title = markdown.match(MATCH_TITLE)[1]
      jekyll_body = markdown.gsub(MATCH_TITLE, '')
      jekyll_header = %Q(---
layout: post
title: "#{title}"
date: #{Time.now}
comments: true
categories:
---)
      MdInc::Commands::root(@base_dir)
      tp = MdInc::TextProcessor.new
      puts tp.process(jekyll_header + jekyll_body)
    end
  end
end
