require 'benchmark/ips'
require File.expand_path('../lib/trie_matcher', __dir__)

def run_user_agent_sim
  trie = TrieMatcher.new
  uas = <<-UAS.gsub(/^ +/, "").lines
    Tiny Tiny RSS/1.2
    Windows-RSS-Platform/1.0 Mozilla compatible
    RSSOwl/2.1
    Bloglovin/1.0 (http://www.bloglovin.com;
    NewsBlur Feed Fetcher - (
    g2reader-bot/1.0 (+http://www.g2reader.com;
    Mozilla/5.0 Vienna/3.1.1
    Mozilla/5.0 (compatible; theoldreader.com; 
    Feedbin - 
    Feed Wrangler/1.0 (
    Mozilla 5.0 (compatible; BazQux/2.4 +http://bazqux.com/fetcher; 
    livedoor FeedFetcher/0.01 (http://reader.livedoor.com/; 
    HanRSS/1.1 (http://www.hanrss.com; 
  UAS
  uas.each_with_index do |line, i|
    trie[line] = i
  end
  Benchmark.ips do |x|
    x.report { uas.sample }
    x.report { trie[uas.sample] }

    x.compare!
  end
end

run_user_agent_sim
