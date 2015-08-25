require File.expand_path("trie_matcher/version", __dir__)

# Trie implementation that acts as a weak mapping
#
# Values can be stored for a given prefix, and are returned for the longest prefix.
# Lookup searches based on a fixed prefix size. This can cause extra memory use and performance degredation on saturated tries with many lexemes.
class TrieMatcher
  # Build an empty trie
  def initialize
    @root = { nodes: {}, value: nil, key_length: nil }
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

    while !current.nil? && current_prefix != ""
      previous = current
      current, current_prefix = next_node(current, current_prefix)
    end

    return current[:value] if current
    return previous[:value]
  end

  # Set a value in the trie if it isn't null. Can be used to initialize collections as values
  #
  # @param word [String] The word to set the value for
  # @param value [Object] the value to set, if the value for the word is nil
  # @return [Object] the value associated with the word
  def set_if_nil(word, value)
    current = @root
    current_prefix = word

    while current_prefix != ""
      current, current_prefix = find_canididate_insertion_node(current, current_prefix)
    end

    current[:value] ||= value
    return current[:value]
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
  def insert_node(root, key)
    new_node = {
      nodes: {},
      value: nil,
      key_length: nil,
    }
    root[:nodes][key] = new_node
    return new_node
  end

  # get the node for insertion, splitting intermediary nodes as necessary
  def find_canididate_insertion_node(current, key)
    if current[:key_length].nil?
      new_node = insert_node(current, key)
      current[:key_length] = key.length
      return new_node, ""
    end

    # check if we have an existing shared prefix already
    current_key = key[0...current[:key_length]]

    # look for an existing key path
    if current[:nodes].has_key?(current_key)
      return current[:nodes][current_key], key[current_key.length..-1]
    end

    # search for a shared prefix, and split all the nodes if necessary
    current[:nodes].keys.each do |prefix|
      common_prefix = shared_prefix(key, prefix)
      next unless common_prefix

      new_key_length = common_prefix.length

      split_nodes(current, new_key_length)
      return current[:nodes][common_prefix], key[new_key_length..-1]
    end

    # potentially split all other keys
    if current_key.length < current[:key_length]
      split_nodes(current, current_key.length)
    end

    new_node = insert_node(current, current_key)
    return new_node, key[current_key.length..-1]
  end

  # split all the branches in the given root to the given length
  def split_nodes(root, new_length)
    old_nodes = root[:nodes]
    split_length = root[:key_length] - new_length
    root[:key_length] = new_length
    root[:nodes] = {}
    old_nodes.each do |key, old|
      new_node = insert_node(root, key[0...new_length])
      new_node[:nodes][key[new_length..-1]] = old
      new_node[:key_length] = split_length
    end
  end

  # find the next node from the current one based on the given key
  def next_node(current, key)
    return nil, nil unless current[:key_length]
    next_key = key[0...current[:key_length]]
    if current[:nodes].has_key?(next_key)
      return current[:nodes][next_key], key[next_key.length..-1]
    else
      return nil, nil
    end
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
