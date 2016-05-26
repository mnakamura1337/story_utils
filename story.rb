require 'json'
require 'set'

class Story
  VAR_HEADER = 'program = '

  def initialize
    @story = {}
  end

  def self.load(fn)
    s = new
    s.load(fn)
    s
  end

  def load(fn)
    File.open(fn, 'r') { |f|
      # skip first 'program = '
      f.read(VAR_HEADER.length)
      @story = JSON.parse(f.read)
    }
  end

  def save(fn)
    File.open(fn, 'w') { |f|
      save_io(f)
    }
  end

  def save_io(f)
    f.write(VAR_HEADER)
    f.puts JSON.pretty_generate(@story)
  end

  def [](x)
    @story[x]
  end

  def []=(k, v)
    @story[k] = v
  end

  class MergeConflict < Exception; end

  def merge(other)
    # meta
    raise MergeConflict.new('meta mismatch') unless @story['meta'] == other['meta']

    # imgs
    merge_hashes(@story['imgs'], other['imgs'], 'imgs')

    # chars
    merge_hashes(@story['chars'], other['chars'], 'chars')

    # script
    @story['script'] += other['script']
  end

  private
  def merge_hashes(h1, h2, hash_name)
    h1_keys = Set.new(h1.keys)
    h2_keys = Set.new(h2.keys)
    h_common_keys = h1_keys.intersection(h2_keys)

    h_common_keys.each { |k|
      v1 = h1[k]
      v2 = h2[k]
      raise MergeConflict.new("#{hash_name} mismatch: key #{k}, got #{v1.inspect} vs #{v2.inspect}") unless v1 == v2
    }

    h2.each_pair { |k, v|
      h1[k] = v
    }
  end
end
