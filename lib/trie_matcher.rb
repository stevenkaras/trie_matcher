require File.expand_path("trie_matcher/version", __dir__)

class TrieMatcher
  def initialize
    @root = { nodes: {}, value: nil}
  end

  def []=(key, value)
    current = @root
    current_key = key

    while current_key != ""
      current, current_key = find_canididate_insertion_node(current, current_key)
    end

    current[:value] = value
    return value
  end


  def [](key)
    current = @root
    current_key = key

    while current != nil && current_key != ""
      previous = current
      current, current_key = next_node(current, current_key)
    end

    return current[:value] if current
    return previous[:value]
  end

  private
  def find_canididate_insertion_node(current, key)
    # look for a common prefix
    current[:nodes].keys.find do |prefix|
      common_prefix = shared_prefix(key, prefix)
      next unless common_prefix

      if common_prefix == prefix
        return current[:nodes][prefix], key[common_prefix.length..-1]
      else
        old = current[:nodes].delete(prefix)
        new_node = {
          nodes: {
            prefix[common_prefix.length..-1] => old
          },
          value: nil
        }
        current[:nodes][common_prefix] = new_node
        return new_node, key[common_prefix.length..-1]
      end
    end

    new_node = {
      nodes: {},
      value: nil
    }
    current[:nodes][key] = new_node
    return new_node, ""
  end

  # find the next node from the current one based on the given key
  def next_node(current, key)
    key.length.times do |l|
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
