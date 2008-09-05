# in s expression assigns, _ is a dummy variable that isn't used
module Xmlator
  class TagProcessor < SexpProcessor

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

    attr_accessor :indent

    def indent
      '  ' * @indent || 0
    end

    def shift_right
      @indent ||= 0
      @indent += 1
      result = yield
      @indent -= 1
      result
    end

    def element(name)
      dtd.elements[name]
    end

    def process_xml_sexp(fcall, block = nil)
      _, name, args = fcall.shift, fcall.shift, fcall.shift
      attrs, body = AttributesProcessor.new.process(args)

      output_xml_sexp(name, attrs, body, shift_right { process(block) })
    end

    def output_xml_sexp(name, attrs, inline_body, block)
      sexp = s(:block)

      sexp << emit_fcall(dtd.doctype) if element(name).is_root?

      unless element(name).has_body?
        sexp << emit_fcall(indent, "<#{name}", attrs, " />")

      else
        open_tag, close_tag = str("<#{name}", attrs, ">"), "</#{name}>"

        if block.nil?
          sexp << emit_fcall(indent, open_tag, inline_body, close_tag)
        else
          sexp << emit_fcall(indent, open_tag, inline_body) << block << emit_fcall(indent, close_tag)
        end
      end

      concat_emit_fcalls(sexp)
    end

    def concat_emit_fcalls(block)
      block = flatten_block(block)
      return block unless block.head == :block

      result = s(:block)

      last = block.tail.inject do |prev, current|
        if  emit_fcall?(prev) &&  emit_fcall?(current)
          emit_fcall(prev.last.last, "\n", current.last.last) # merge two xml_sexps
        else
          result << prev
          current
        end
      end

      result << last

      result.length > 2 ? result : result.last
    end

    def  emit_fcall(*args)
      raise ArgumentError, "wrong number of arguments (0 for 1 or more)" if args.empty?
      s(:call, s(:vcall, :_xmlator_buf), :<<, s(:array, str(*args)))
    end
    
    def  emit_fcall?(exp)
      s(:call, s(:vcall, :_xmlator_buf), :<<, Any) == exp
    end
    
  end
end