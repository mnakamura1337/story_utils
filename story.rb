require 'json'

class Story
  def self.load(fn)
    s = new
    s.load(fn)
    s
  end

  def load(fn)
    File.open(fn, 'r') { |f|
      # skip first 'program = '
      f.read('program = '.length)
      @story = JSON.parse(f.read)
    }
  end

  def save(fn)
    File.open(fn, 'w') { |f|
      f.write('program = ')
      f.puts JSON.pretty_generate(@story)
    }
  end

  def [](x)
    @story[x]
  end
end
