require 'ruby-prof'
require 'stringio'
require File.expand_path('../lib/trie_matcher', __dir__)

# RubyProf.measure_mode = RubyProf::WALL_TIME
# RubyProf.measure_mode = RubyProf::PROCESS_TIME
# RubyProf.measure_mode = RubyProf::CPU_TIME
# RubyProf.measure_mode = RubyProf::ALLOCATIONS
RubyProf.measure_mode = RubyProf::MEMORY
# RubyProf.measure_mode = RubyProf::GC_TIME
# RubyProf.measure_mode = RubyProf::GC_RUNS

def profile
  RubyProf.start
  yield
  return RubyProf.stop
end

# we investigate two use cases: user agent matching, and t9 prediction.
# TODO: add third use case - route matching

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
  simulation = (uas.size * 10000).times.map do
    uas.sample
  end
  profile do
    simulation.each do |test_case|
      trie[test_case]
    end
  end
end

def report_profile(profile, outfile = "profile.html")
  # print the call graph
  output = StringIO.new

  printer = RubyProf::CallStackPrinter.new(profile)
  printer.print(output, min_percent: 2)

  File.write(outfile, output.string)

  # Print the raw report
  printer = RubyProf::FlatPrinter.new(profile)
  printer.print(STDOUT)
end

report_profile(run_user_agent_sim)
