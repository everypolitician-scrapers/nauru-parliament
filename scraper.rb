#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

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
      name:         tds[0].text.tidy,
      party:        tds[1] ? tds[1].text.tidy : 'Unknown',
      faction:      tds[2] ? tds[2].text.tidy : 'Unknown',
      constituency: current_constituency.sub(' Constituency', ''),
      wikiname:     tds[0].xpath('a[not(@class="new")]/@title').text,
      term:         term.to_s,
    }
    # puts data
    ScraperWiki.save_sqlite(%i(name term), data)
  end
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list('https://en.wikipedia.org/wiki/Parliament_of_Nauru', 21)
scrape_list('https://en.wikipedia.org/w/index.php?title=Parliament_of_Nauru&oldid=555396216', 20)
scrape_list('https://en.wikipedia.org/w/index.php?title=Parliament_of_Nauru&oldid=361849426', 19)
