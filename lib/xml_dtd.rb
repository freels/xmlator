class XmlDTD
  class << self

    attr_reader :elements
    
    def name
      @name ||= self.to_s.sub(/\A(.*?)DTD\Z/, '\1').downcase.intern
      @name
    end
            
    def doctype(*args)
      unless args.empty?
        args = args.collect { |arg| arg.is_a?(Symbol) ? arg.to_s : %{"#{arg}"} }
        inner_string = args.join(' ')
        @doctype = "<!DOCTYPE #{inner_string}>"
      end
      
      @doctype
    end

    def elem(name, &block)
      name = name.to_sym
      e = elements[name] || XmlElement.new(name)
      e.instance_eval &block unless block.nil?
      elements[name] = e
      e
    end
    
    def elements
      @elements ||= {}
    end
    
    def is_element?(name)
      elements.member? name
    end
  end
end

class XmlElement
  def initialize(name)
    @name = name
  end
  
  def root_element
    @root_element = true
  end
  
  def is_root?
    @root_element
  end
  
  def default_attributes(hash = nil)
    @default_attributes = hash unless hash.nil?    
    @default_attributes ||= {}
  end
  
  def self_closing
    @self_closing = true
  end
    
  def has_body?
    !@self_closing
  end
  
  def attributes
    @attributes ||= []
  end
end