class SexpWildcard
  def eql?(obj)
    true
  end
  alias == eql?
end

class SexpProcessor
  Any = SexpWildcard.new

  def str(*args)
    Sexp.str(*args)
  end

  def flatten_block(block)
    return block unless block.head == :block
    
    result = s(:block)
    
    recurser = lambda do |exp|
      exp.tail.each do |atom|
        if atom.head == :block
          recurser.call(atom)
        else
          result << atom
        end
      end
    end
    
    recurser.call(block)

    result.length > 2 ? result : result.last
  end
end