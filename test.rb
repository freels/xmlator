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

def erb(title_id, a_title)
  template = ERB.new <<-end_erb
  <html>
    <head>
      <title id="<%= title_id %>"><%= a_title %></title>
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

def markaby(title_id, a_title)  
  mab = Markaby::Builder.new(:title_id => title_id, :a_title => a_title)
  mab.html do
    head do
      title a_title, :id => title_id
    end
    body :id => "test", :class => 'class' do
      img :id => 'test', :src => "http://img.jpg"
      3.times do
        p "cool"
      end
    end
  end
end


def parsexml(title_id, a_title)  
  Html4Strict.render do
    html do
      head do
        title a_title, :id => title_id
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

puts "--- erb:\n\n"
puts erb('erb', 'i am erb!')
puts "\n--- markaby:\n\n"
puts markaby('markaby', 'i am markaby!')
puts "\n--- parsexml:\n\n"
puts parsexml('parsexml', 'i am parsexml!')
puts "\nbenchmarks:\n"

Benchmark.bm do |x|
  x.report('erb') { 10000.times {|i| erb("erb #{i}", 'i am erb!')} }
  x.report('markaby') { 10000.times {|i| markaby("markaby #{i}", 'i am markaby!')} }
  x.report('parsexml') { 10000.times {|i| parsexml("parsexml #{i}", 'i am parsexml!')} }
end
