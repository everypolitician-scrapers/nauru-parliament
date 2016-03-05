#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(url, term)
  noko = noko_for(url)

  current_constituency = ''
  noko.xpath('.//table[.//th[.="Constituency"]]//tr[td]').each do |tr|
    tds = tr.css('td')
    if tds.first.text.include? 'Constituency'
      current_constituency = tds.shift.text.tidy
    end
    data = { 
      name: tds[0].text.tidy,
      party: tds[1].text.tidy,
      faction: tds[2].text.tidy,
      constituency: current_constituency.sub(' Constituency', ''),
      wikiname: tds[0].xpath('a[not(@class="new")]/@title').text,
      term: term.to_s,
    } rescue binding.pry
    # puts data
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/Parliament_of_Nauru', 21)
scrape_list('https://en.wikipedia.org/w/index.php?title=Parliament_of_Nauru&oldid=555396216', 20)
