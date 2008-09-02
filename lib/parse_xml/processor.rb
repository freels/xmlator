# in s expression assigns, _ is a dummy variable that isn't used
module ParseXml
  class Processor < SexpProcessor

    attr_accessor :dtd

    # callbacks for SexpProcessor

    def process_fcall(exp)
      if dtd.is_element? exp[1]
        process_xml_sexp(exp)
      else
        _, name, args = exp.shift, exp.shift, exp.shift
        if args.nil?
          s(:fcall, name)
        else
          s(:fcall, name, process(args))
        end
      end
    end


    def process_iter(exp)
      _, fcall, _, block = exp.shift, exp.shift, exp.shift, exp.shift

      if dtd.is_element? fcall[1]
        process_xml_sexp(fcall, block)
      else
        s(:iter, process(fcall), nil, process(block))
      end
    end

    private

    attr_accessor :current_elem

    def indent
      @indent ||= 0
      @indent += 2
      result = yield
      @indent -= 2
      result
    end


    def current_indent
      ' ' * @indent
    end


    def process_xml_sexp(fcall, block = nil)
      _, name, args = fcall.shift, fcall.shift, fcall.shift

      self.current_elem = dtd.elements[name]

      attrs, body = if block.nil?
        attrs_and_body_from(process(args))
      else
        [attrs_and_body_from(process(args)).first, indent { process block }]
      end

      output_xml_sexp name, attrs, body
    end


    def output_xml_sexp(name, attrs, body)
      block = s(:block)

      if current_elem.is_root?    
        block << puts_fcall(current_indent, dtd.doctype)
      end

      unless current_elem.has_body?
        block << puts_fcall(current_indent, "<#{name}", attrs, " />\n")

      else
        open_tag = str(current_indent, "<#{name}", attrs, ">")
        close_tag = "</#{name}>\n"

        if body.nil?
          block << puts_fcall(open_tag, close_tag)

        elsif body.head == :str || body.head == :dstr
          block << puts_fcall(open_tag, body, close_tag)

        else
          block << puts_fcall(open_tag, "\n")
          block << body
          block << puts_fcall(current_indent, close_tag)
        end
      end

      concat_puts_fcalls(block)
    end


    def concat_puts_fcalls(block)
      block = flatten_block(block)
      return block unless block.head == :block

      result = s(:block)

      last = block.tail.inject do |prev, current|
        if  puts_fcall?(prev) &&  puts_fcall?(current)
          puts_fcall(prev.last.last, current.last.last) # merge two xml_sexps
        else
          result << prev
          current
        end
      end

      result << last

      result.length > 2 ? result : result.last
    end


    def  puts_fcall(*args)
      raise ArgumentError, "wrong number of arguments (0 for 1 or more)" if args.length == 0
      s(:fcall, :puts, s(:array, str(*args)))
    end


    def  puts_fcall?(exp)
      s(:fcall, :puts, Any) == exp
    end


    def attrs_and_body_from(exp)
      attrs = {}
      body = nil

      current_elem.default_attributes.each do |key, val|
        attrs[str(key)] = str(val)
      end

      unless exp.nil?
        exp.tail.each do |atom|
          case atom.head
          when :hash
            atom.shift
            attrs[atom.shift] = atom.shift until atom.empty?
            attrs
          when :str, :dstr, :lit, :lvar
            body = str(atom)
          end
        end
      end

      [attr_string(attrs), body]
    end


    def attr_string(hash)
      attr_array = hash.collect do |key, val|
        if val == false
          nil
        else
          val = key if val === true
          str(" ", key, "=\"", val, "\"")  
        end
      end

      str(*attr_array)
    end
  end
end