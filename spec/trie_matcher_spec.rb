require 'spec_helper'

describe TrieMatcher do
  it 'has a version number' do
    expect(TrieMatcher::VERSION).not_to be nil
  end

  it 'should store values' do
    t = TrieMatcher.new
    t["foo"] = "bar"
  end

  it 'should retrieve stored values' do
    t = TrieMatcher.new
    value = "bar"
    t["foo"] = value
    expect(t["foo"]).to be value
  end

  it 'should return the stored value' do
    t = TrieMatcher.new
    value = "bar"
    expect(t["foo"] = value).to be value
  end

  it 'should store values with shared prefixes' do
    t = TrieMatcher.new
    t["cat"] = 1
    t["car"] = 2
    expect(t["cat"]).to be 1
    expect(t["car"]).to be 2
  end

  it 'should store keys that are a prefix of other keys' do
    t = TrieMatcher.new
    t["catch"] = 1
    t["cat"] = 2
    expect(t["catch"]).to be 1
    expect(t["cat"]).to be 2
  end

  it 'should store keys that have a prefix of another key' do
    t = TrieMatcher.new
    t["cat"] = 1
    t["catch"] = 2
    expect(t["cat"]).to be 1
    expect(t["catch"]).to be 2
  end

  it 'should do prefix searching' do
    t = TrieMatcher.new
    t["cat"] = 1
    expect(t["cats"]).to be 1
  end

  it 'should do partial prefix matching' do
    t = TrieMatcher.new
    t["cat"] = 1
    t["cats in the cradle"] = 2
    expect(t["cats"]).to be 1
  end

end
