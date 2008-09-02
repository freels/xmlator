$: << 'lib'

require 'rubygems'
require 'parsexml'
require 'html_dtd'
require 'markaby'
require 'erb'
require 'benchmark'

# the_id = "a_test"
# 
# block = <<-end_eval
# lambda do
#   html 'lang' => 'sp' do
#     head do
#       title "title page", :id => the_id
#     end
#     body :id => "test", :class => 'class' do
#       img :id => 'test', :src => "http://img.jpg"
#       3.times do
#         p "cool"
#       end
#     end
#   end
# end
# end_eval
# 
# h = eval(block)
# 
# puts "Block"
# puts "-----"
# puts block
# puts "\n"
# 
# puts "Block as S-expression"
# puts "---------------------"
# p Sexp.from_array(h.to_sexp)
# puts "\n"
# 
# puts "optimized S-expression"
# puts "----------------------"
# processor = XmlDTDProcessor.new
# processor.dtd = Html4Strict
# s = processor.process(h.to_sexp)
# p s
# puts "\n"
# 
# puts "optimized block"
# puts "---------------"
# b = Ruby2Ruby.new.process(s.last)
# puts eval("lambda {" + b + "}").to_ruby
# puts "\n"
# 
# puts "output"
# puts "------"
# eval(b)

def erbous(foo, a_title='icky')
  template = ERB.new <<-end_erb
  <html>
    <head>
      <title id="<%= foo %>"><%= a_title %></title>
    </head>
    <body id="test" class="class">
      <img id="test" src="http://img.jpg" />
      <% 3.times do %>
        <p>cool</p>
      <% end %>
    </body>
  </html>
  end_erb
  
  template.result(binding)
end

def markabous(foo, a_title='icky')  
  mab = Markaby::Builder.new(:foo => foo, :a_title => a_title)
  mab.html do
    head do
      title a_title, :id => foo
    end
    body :id => "test", :class => 'class' do
      img :id => 'test', :src => "http://img.jpg"
      3.times do
        p "cool"
      end
    end
  end
end


def renderous(foo, a_title='icky')  
  Html4Strict.render do
    html do
      head do
        title a_title, :id => foo
      end
      body :id => "test", :class => 'class' do
        img :id => 'test', :src => "http://img.jpg"
        3.times do
          p "cool"
        end
      end
    end
  end
end

10.times {erbous('foo')}
10.times {markabous('foo')}
10.times {renderous('foo')}


Benchmark.bm do |x|
  x.report('erb') { 10000.times {erbous('foo')} }
  x.report('markaby') { 10000.times {markabous('foo')} }
  x.report('parsexml') { 10000.times {renderous('foo')} }
end
