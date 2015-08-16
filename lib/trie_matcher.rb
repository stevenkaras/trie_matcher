require File.expand_path("trie_matcher/version", __dir__)

# Trie implementation that acts as a weak mapping
#
# Values can be stored for a given prefix, and are returned for the longest prefix.
# Lookup searches for longer prefixes optimistically, so saturated tries with many lexemes in them will be less efficient
class TrieMatcher
  # Build an empty trie
  def initialize
    @root = { nodes: {}, value: nil, longest_node_length: 0, longest_node: nil }
  end

  # Store a prefix in the trie, and associate a value with it
  #
  # @param prefix [String]
  # @param value [Object] a value to return if prefix is the longest prefix on lookup
  # @return [Object] the value that was set
  def []=(prefix, value)
    current = @root
    current_prefix = prefix

    while current_prefix != ""
      current, current_prefix = find_canididate_insertion_node(current, current_prefix)
    end

    current[:value] = value
    return value
  end

  # Perform a prefix search. Will return the value associated with the longest prefix
  #
  # @param prefix [String] what to check for a prefix in
  # @return [Object] the value associated with the longest matching prefix in this trie
  def [](prefix)
    current = @root
    current_prefix = prefix

    while current != nil && current_prefix != ""
      previous = current
      current, current_prefix = next_node(current, current_prefix)
    end

    return current[:value] if current
    return previous[:value]
  end

  # Perform a prefix search, and return all values in the trie that have this prefix
  #
  # @param prefix [String] the prefix to search the trie with
  # @return [<Object>] the values that start with the given prefix
  def match(prefix)
    result = []
    current = @root
    current_prefix = prefix

    while current != nil && current_prefix != ""
      previous, previous_prefix = current, current_prefix
      current, current_prefix = next_node(current, current_prefix)
    end

    unless current
      if current_prefix
        return []
      else
        next_nodes = previous[:nodes].select { |prefix, node| prefix.start_with?(previous_prefix) }.values
      end
    else
      next_nodes = [current]
    end

    until next_nodes.empty?
      current = next_nodes.pop
      result << current[:value]
      current[:nodes].each { |prefix, node| next_nodes.push(node) }
    end

    return result.compact
  end

  private
  # get the node for insertion, splitting shared prefixes into subnodes if necessary
  def find_canididate_insertion_node(current, key)
    # look for a common prefix
    current[:nodes].keys.find do |prefix|
      common_prefix = shared_prefix(key, prefix)
      next unless common_prefix

      if common_prefix == prefix
        return current[:nodes][prefix], key[common_prefix.length..-1]
      else
        old = current[:nodes].delete(prefix)
        new_suffix = prefix[common_prefix.length..-1]
        new_node = {
          nodes: {
            new_suffix => old
          },
          value: nil,
          longest_node_length: new_suffix.length,
          longest_node: new_suffix,
        }
        current[:nodes][common_prefix] = new_node
        if current[:longest_node] == prefix
          longest_prefix = current[:nodes].keys.max_by(&:length)
          current[:longest_node_length] = longest_prefix.length
          current[:longest_node] = longest_prefix
        end
        return new_node, key[common_prefix.length..-1]
      end
    end

    new_node = {
      nodes: {},
      value: nil,
      longest_node: nil,
      longest_node_length: 0,
    }
    if key.length > current[:longest_node_length]
      current[:longest_node_length] = key.length
      current[:longest_node] = key
    end
    current[:nodes][key] = new_node
    return new_node, ""
  end

  # find the next node from the current one based on the given key
  def next_node(current, key)
    ([key.length, current[:longest_node_length]].max).times do |l|
      if current[:nodes].has_key?(key[0..-l-1])
        return current[:nodes][key[0..-l-1]], key[-l,l]
      end
    end
    return nil, nil
  end

  # finds a shared prefix between the two strings, or nil if there isn't any
  def shared_prefix(a, b)
    shared_prefix_length = [a.length, b.length].min
    while shared_prefix_length >= 0
      a_prefix = a[0..shared_prefix_length]
      b_prefix = b[0..shared_prefix_length]
      return a_prefix if a_prefix == b_prefix

      shared_prefix_length -= 1
    end

    return nil
  end

end
