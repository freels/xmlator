require 'rubygems'
require 'ruby2ruby'
require 'lib/sexp'
require 'lib/sexp_processor'

# in s expression assigns, d is a dummy var that isn't used

class RubyToXMLProcessor < SexpProcessor
  
  attr_accessor :dtd

  # callbacks for SexpProcessor
  def process_fcall(exp)
    if dtd.is_element? exp[1]
      function_call_to_xml_call(exp)
    else
      d, name, args = exp.shift, exp.shift, exp.shift
      if args.nil?
        s(:fcall, name)
      else
        s(:fcall, name, process(args))
      end
    end
  end

  def process_iter(exp)
    d, fcall, d, block = exp.shift, exp.shift, exp.shift, exp.shift

    if dtd.is_element? fcall[1]
      function_call_to_xml_call(fcall, block)
    else
      s(:iter, process(fcall), nil, process(block))
    end
  end

  private

  def indent
    @indent ||= 0
    @indent += 2
    result = yield
    @indent -= 2
    result
  end

  
  def function_call_to_xml_call(fcall, block = nil)
    d, name, args = fcall.shift, fcall.shift, fcall.shift
    
    attrs, body = if block.nil?
      attrs_and_body_from(process(args))
    else
      [attrs_and_body_from(process(args)).first, indent { process block }]
    end
    
    xml_fcall name, attrs, body
  end
  
  def xml_fcall(name, attrs, body)
    unless dtd.elements[name].has_body?
      output_xml_sexp "#{' ' * @indent}<#{name}", attrs, " />\n"
    else
      open_tag = str("#{' ' * @indent}<#{name}", attrs, ">")
      close_tag = "</#{name}>\n"

      if body.nil?
        output_xml_sexp(open_tag, close_tag)
      elsif [:str, :dstr].include? body.head
        output_xml_sexp(open_tag, body, close_tag)
      else
        reduce_xml_sexps s(:block, output_xml_sexp(open_tag, "\n"), body, output_xml_sexp(' ' * @indent, close_tag))
      end
    end
  end

  def reduce_xml_sexps(block)
    return block unless block.head == :block

    result = s(:block)

    last = flatten_block(block).tail.inject do |prev, current|
      if output_xml_sexp?(prev) && output_xml_sexp?(current)
        output_xml_sexp(prev.last.last, current.last.last) # merge two xml_sexps
      else
        result << prev
        current
      end
    end

    result << last

    result.length > 2 ? result : result.last
  end

  def output_xml_sexp(*args)
    raise ArgumentError, "wrong number of arguments (0 for 1 or more)" if args.length == 0
    s(:fcall, :output_xml, s(:array, str(*args)))
  end

  def output_xml_sexp?(exp)
    s(:fcall, :output_xml, Any) == exp
  end

  def attrs_and_body_from(exp)
    attrs, body = nil

    unless exp.nil?
      exp.tail.each do |atom|
        case atom.head
        when :hash
          atom.shift
          attrs = str(attrs, attr_from_pair(atom.shift, atom.shift)) until atom.empty?
        when :str, :dstr, :lit
          body = str(atom)
        end
      end
    end

    [attrs, body]
  end

  def attr_from_pair(key, val)
    return nil if val == false
    val = key if val === true
          
    str(" ", key, "=\"", val, "\"")
  end
end
