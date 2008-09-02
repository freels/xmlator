module ParseXml
  class DTD
    class << self
      
      def render(&block)
        locals = eval('local_variables', block.binding).join(', ')
        local_values = eval("[#{locals}]", block.binding)

        unless compiled_procs.member? block.inspect
          processor = Processor.new
          processor.dtd = self
          sexp = block.to_sexp
          ruby = Ruby2Ruby.new.process(processor.process(sexp).last)
          compiled_procs[block.inspect] = eval("proc { |#{locals}| #{ruby} }")
        end
        
        capture { compiled_procs[block.inspect].call(*local_values) }
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
        result = yield
        $stdout = real_stdout
        result
      end
    end
  end
end