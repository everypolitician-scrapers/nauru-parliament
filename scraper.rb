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

def scrape_list(url)
  noko = noko_for(url)

  current_constituency = ''
  noko.xpath('.//h2[contains(.,"Current MPs")]/following-sibling::table[1]//tr[td]').each do |tr|
    tds = tr.css('td')
    if tds.first.text.include? 'Constituency'
      current_constituency = tds.shift.text.tidy
    end
    data = { 
      name: tds[0].text.tidy,
      party: tds[1].text.tidy,
      faction: tds[2].text.tidy,
      constituency: current_constituency.sub(' Constituency', ''),
      wikipedia: tds[0].css('a[href*="/wiki/"]/@href').text,
      portfolio: tds[3].text.tidy,
      term: '21',
      source: url,
    }
    data[:wikipedia] = URI.join('https://en.wikipedia.org/', data[:wikipedia]).to_s unless data[:wikipedia].to_s.empty?
    # puts data
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/Parliament_of_Nauru')
