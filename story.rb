require 'json'

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
end
