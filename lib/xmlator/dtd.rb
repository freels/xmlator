module Xmlator
  class DTD
    class << self
      
      def render(&block)
        unless compiled_procs.member? block.inspect
          sexp = processor.process(block.to_sexp).last
          compiled_procs[block.inspect] = %{_xmlator_buf = []\n} + Ruby2Ruby.new.process(sexp) + %{\n_xmlator_buf.join("\n")}
        end

        eval(compiled_procs[block.inspect], block.binding)
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
      
      def processor
        if @processor.nil?
          @processor = TagProcessor.new
          @processor.dtd = self
        end
        
        @processor
      end
      
      def compiled_procs
        @compiled_procs ||= {}
      end
    end
  end
end