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

  def join(other)
    # meta: compare sans orig_lang
    m1 = @story['meta'].dup
    m1.delete('orig_lang')
    m2 = other['meta'].dup
    m2.delete('orig_lang')
    raise MergeConflict.new("meta mismatch: #{m1.inspect} vs #{m2.inspect}") unless m1 == m2

    # imgs
    merge_hashes(@story['imgs'], other['imgs'], 'imgs')

    # TODO: check & join chars here

    # script
    @story['script'].size.times { |i|
      c1 = @story['script'][i]
      c2 = other['script'][i]

      c1_op = c1['op']
      c2_op = c2['op']

      raise MergeConflict.new("script ##{i}: mismatch op: #{c1.inspect} vs #{c2.inspect}") unless c1_op == c2_op

      case c1_op
      when 'say', 'narrate', 'think', 'menu_add'
        c1_char = c1['char']
        c2_char = c2['char']
        raise MergeConflict.new("script ##{i}: mismatch char: #{c1_char.inspect} vs #{c2_char.inspect}") unless c1_char == c2_char

        c2['txt'].each_pair { |lang, txt|
          if c1['txt'][lang] and c1['txt'][lang] != txt
            raise MergeConflict.new("script ##{i}: mismatch txt for #{lang.inspect}: #{c1['txt'][lang]} vs #{txt}")
          end
          c1['txt'][lang] = txt
        }
      else
        raise MergeConflict.new("script ##{i}: mismatch #{c1.inspect} vs #{c2.inspect}") unless c1 == c2
      end
    }
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
