module Xmlator
  class AttributesProcessor
    include SexpHelpers

    attr_accessor :attrs, :body

    def process(exp)
      return nil if exp.nil?
      args = SexpProcessor.new.process(exp)
      args.shift

      raise ArgumentError, "wrong number of arguments (#{exp.length} for 2)" if exp.length > 2

      attrs = args.select { |arg| arg.head == :hash }.first
      body = args.select { |arg| arg.head != :hash }.first

      self.attrs = attr_string(attrs) unless attrs.nil?
      self.body = Sexp.str(body) unless body.nil?

      [self.attrs, self.body]
    end

    def attr_string(exp)      
      attr_array = Hash[*exp.tail].collect do |key, val|
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