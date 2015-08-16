require 'spec_helper'

describe TrieMatcher do
  before do
    @t = TrieMatcher.new
  end

  it 'has a version number' do
    expect(TrieMatcher::VERSION).not_to be nil
  end

  it 'should store values' do
    @t["foo"] = "bar"
  end

  it 'should retrieve stored values' do
    value = "bar"
    @t["foo"] = value
    expect(@t["foo"]).to be value
  end

  it 'should return the stored value' do
    value = "bar"
    expect(@t["foo"] = value).to be value
  end

  it 'should store values with shared prefixes' do
    @t["cat"] = 1
    @t["car"] = 2
    expect(@t["cat"]).to be 1
    expect(@t["car"]).to be 2
  end

  it 'should store keys that are a prefix of other keys' do
    @t["catch"] = 1
    @t["cat"] = 2
    expect(@t["catch"]).to be 1
    expect(@t["cat"]).to be 2
  end

  it 'should store keys that have a prefix of another key' do
    @t["cat"] = 1
    @t["catch"] = 2
    expect(@t["cat"]).to be 1
    expect(@t["catch"]).to be 2
  end

  it 'should do prefix searching' do
    @t["cat"] = 1
    expect(@t["cats"]).to be 1
  end

  it 'should do partial prefix matching' do
    @t["cat"] = 1
    @t["cats in the cradle"] = 2
    expect(@t["cats"]).to be 1
  end

  it 'should return the more specific prefix value' do
    @t["cat"] = 1
    @t["catch"] = 2
    expect(@t["catcher"]).to be 2
  end

  it 'should not give a longer prefix value' do
    @t["catch"] = 2
    expect(@t["cat"]).to be nil
  end
  end

end
