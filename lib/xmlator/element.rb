module Xmlator
  class Element
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
end