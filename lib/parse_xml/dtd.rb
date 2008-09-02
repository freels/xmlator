module ParseXml
  class DTD
    class << self
      
      def render(&block)
        self.context = block.binding
        self.caller = eval('self', context)
        self.locals = eval('local_variables', context)
        
        unless compiled_procs.member? block.inspect
          processor = Processor.new
          processor.dtd = self
          ruby = Ruby2Ruby.new.process(processor.process(block.to_sexp).last)
          compiled_procs[block.inspect] = eval("proc { #{ruby} }")
        end
        
        capture { compiled_procs[block.inspect].call }
      end

      def doctype(*args)
        unless args.empty?
          args = args.collect { |arg| arg.is_a?(Symbol) ? arg.to_s : %{"#{arg}"} }
          inner_string = args.join(' ')
          @doctype = "<!DOCTYPE #{inner_string}>"
        end

        @doctype
      end

      def elements
        @elements ||= {}
      end

      def is_element?(name)
        elements.member? name
      end
      
      private
      
      attr_accessor :caller, :locals, :context
      
      def method_missing(method, *args, &block)
        if locals.include?(method.to_s) && args.empty? && block.nil?
          eval(method.to_s, context)
        else
          caller.send(method, *args, &block)
        end
      end
      
      def elem(name, &block)
        name = name.to_sym
        e = elements[name] || Element.new(name)
        e.instance_eval &block unless block.nil?
        elements[name] = e
        e
      end
      
      def compiled_procs
        @compiled_procs ||= {}
      end
      
      def capture
        real_stdout, $stdout = $stdout, StringIO.new
        yield
        stringio, $stdout = $stdout, real_stdout
        stringio.rewind
        result = stringio.read
        stringio.close
        result
      end
    end
  end
end