require 'rubygems'
require 'ruby2ruby'

class Sexp
  alias_method :head, :first

  def tail
    self.slice(1, self.length - 1)
  end
  
  def to_str_sexp
    case self.first
    when :str, :dstr
      self
    when :lit
      s(:str, self.last.to_s)
    else
      s(:dstr, '', s(:evstr, self))
    end
  end

  class << self
    def str(*elems)
      if elems.empty?
        s(:str, '')
      elsif elems.length == 1
        str_for(elems.first)
      else
        elems.compact.inject(str) { |l,r| concat_strs l, str(r) }
      end
    end

    private

    def concat_strs(left, right)
      if left.first == :str
        left = s(right.shift, left.last + right.shift)
      else
        right.shift
        left << (left.last.first == :str ? s(:str, left.pop.last + right.shift) : s(:str, right.shift))
      end

      left << right.shift until right.empty?
      left
    end

    def str_for(obj)
      obj = Sexp.from_array(obj) if obj.is_a? Array

      if obj.respond_to? :to_str_sexp
        obj.to_str_sexp
      else 
        s(:str, obj.to_s)
      end
    end
  end
end