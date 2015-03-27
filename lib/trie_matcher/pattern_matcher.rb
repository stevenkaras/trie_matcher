require File.expand_path("../trie_matcher", __dir__)

# Convenience class for matching specific patterns, accelerated by a static prefix.
#
# This is extremely useful for matching complex patterns such as user agents or url routes
class TrieMatcher::PatternMatcher
  # Build an empty pattern matcher
  def initialize
    @trie = TrieMatcher.new
  end

  # Register a pattern, along with a static prefix
  #
  # @param prefix [String] a static prefix that indicates this pattern should be tested
  # @param pattern [Regexp] a pattern to test against
  # @yield [match] executed if a positive match is made
  # @yieldparam match [MatchData] the match data from the pattern
  def add_pattern(prefix, pattern, &block)
    @trie[prefix] ||= {}
    @trie[prefix][pattern] = block
  end

  # Match a string against all registered patterns efficiently.
  #
  # Calls the block registered against any matching pattern, and passes in the match data
  #
  # @param string [String] the string to match against
  def match(string)
    result = @trie[string]
    return nil unless result
    result.each do |pattern, block|
      match = pattern.match(string)
      block.call(match) if match
    end
  end

end
