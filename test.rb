require 'xml_dsl'

class Html4Strict < XmlDTD
  doctype :HTML, :PUBLIC, "-//W3C//DTD HTML 4.01//EN", "http://www.w3.org/TR/html4/strict.dtd"
  
  # allow_all_attributes # don't raise when encountering an unknown attribute
  
  # frameset/transitional elements:
  # 
  # %w(a abbr acronym address applet area b base basefont bdo big blockquote body br button caption center
  # cite code col colgroup dd del dir div dfn dl dt em fieldset font form frame frameset h1 h2 h3 h4 h5 h6 
  # head hr html i iframe img input ins isindex kbd label legend li link map menu meta noframes noscript
  # object ol optgroup option p param pre q s samp script select small span strike strong style sub sup
  # table tbody td textarea tfoot th thead title tr tt u ul var)
  
  tags = %w(a abbr acronym address area b base bdo big blockquote body br button caption
  cite code col colgroup dd del div dfn dl dt em fieldset form h1 h2 h3 h4 h5 h6 
  head hr html i img input ins kbd label legend li link map meta noscript
  object ol optgroup option p param pre q samp script select small span strong style sub sup
  table tbody td textarea tfoot th thead title tr tt ul var)
  
  tags.each do |tag|
    elem tag
  end
  
  %w(area base br hr input link meta param).each do |tag|
    elem(tag) { has_body false }
  end
  
end

the_id = "a_test"

block = <<-end_eval
lambda do
  html do
    head do
      title "title page", :id => the_id
    end
    body :id => "test", :class => 'class' do
      img :id => 'test', :src => "http://img.jpg"
      3.times do
        p "cool"
      end
    end
  end
end
end_eval

h = eval(block)

alias output_xml puts

puts "Block"
puts "-----"
puts block
puts "\n"

puts "Block as S-expression"
puts "---------------------"
p Sexp.from_array(h.to_sexp)
puts "\n"

puts "optimized S-expression"
puts "----------------------"
processor = RubyToXMLProcessor.new
processor.dtd = Html4Strict
s = processor.process(h.to_sexp)
p s
puts "\n"

puts "optimized block"
puts "---------------"
b = Ruby2Ruby.new.process(s.last)
puts eval("lambda {" + b + "}").to_ruby
puts "\n"

puts "output"
puts "------"
eval(b)
