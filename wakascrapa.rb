#!/usr/bin/env ruby

# Wakascrapa v0.1 
# by Allan Clark - <napta2k@gmail.com>
# This script will download all images in a given category of a wakaba imageboard
# URL: http://github.com/ajclark/Wakascrapa/

require 'rubygems'
require 'mechanize'

# This url should be the first page, e.g. 1.php rather than wakaba.php. 
url = "http://www.intern3ts.com/general/anime/1.php"
baseurl = "http://www.intern3ts.com"

# Visit imageboard
agent = Mechanize.new
agent.user_agent = 'w3m/0.52'
page = agent.get(url)

# Find out how many pages the imageboard has ; visit each one
replies = agent.page.links_with(:text => %r{\d}, :href => %r{\d*php$}).each do |reply|
  link = "#{baseurl}#{reply.href}"
  page = agent.get(link)  
  puts "Page: #{baseurl}#{reply.href}"
  
  # Find image posts 
  replies = agent.page.links_with(:text => "Reply")

  # For each image post, click Reply and harvest image URLs
  replies.each do |reply|
    reply.click
    pp agent.page.title

    # Download all images on the page, try to ignore duplicates
    replies = agent.page.links_with(:text => %r{\d*.jpg$}, :href => %r{\/src\/\d*.jpg$})
    replies.each do |reply|
      link = "#{baseurl}#{reply.href}"
      filename = File.basename(reply.href)

      # Skip the file if it exists
      if FileTest.exist?("#{filename}")
        puts "Skipping: #{link} - #{filename} exists"
        next
      end
      puts "Saving: #{link}"
      agent.get(link).save_as(filename)
    end
  end
end
