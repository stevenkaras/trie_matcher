# TrieMatcher

Prefix matching in Ruby using a trie

I built this after needing to match user agents quickly, and found that existing trie implementations did not provide suitable interfaces.

## Installation

Add this line to your application's Gemfile:

    gem 'trie_matcher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install trie_matcher

## Usage

```ruby
t = TrieMatcher.new
t["cat"] = "feline"
t["car"] = "automobile"
t["bar"] = "exam"

t["cat"] # "feline"
t["catch"] # "feline"
t["ca"] # nil
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/trie_matcher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
