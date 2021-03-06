$: << 'lib'

require 'rubygems'
require 'xmlator'
require 'html_dtd'
require 'markaby'
require 'erb'
require 'erubis'
require 'benchmark'

def the_footer
  "the end"
end

erb_html = <<-end_erb
<html>
  <head>
    <title id="<%= title_id %>"><%= a_title %></title>
  </head>
  <body id="test" class="class">
    <img id="test" src="http://img.jpg" />
    <% 3.times do %>
      <p>cool</p>
    <% end %>
    <div class="footer"><%= the_footer %></div>
  </body>
</html>
end_erb

ErbTemplate = ERB.new(erb_html)
ErubisTemplate = Erubis::Eruby.new(erb_html)

def erb(title_id, a_title)
  ErbTemplate.result(binding)
end

def erubis(title_id, a_title)
  ErubisTemplate.result(binding)
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
      
      div the_footer, :class => 'footer'
    end
  end
end


def parsexml(title_id, a_title)  
  Html4Strict.render do
    html :id => "test", :class => 'class' do
      head do
        title a_title, :id => title_id
      end
      body :id => "test", :class => 'class' do
        img :id => 'test', :src => "http://img.jpg"
        
        3.times do
          p "cool"
        end
        
        div the_footer, :class => 'footer'
      end
    end
  end
end

puts "--- erb:\n\n"
puts erb('erb', 'i am erb!')
puts "--- erubis:\n\n"
puts erubis('erubis', 'i am erubis!')
puts "\n--- markaby:\n\n"
puts markaby('markaby', 'i am markaby!')
puts "\n--- parsexml:\n\n"
puts parsexml('parsexml', 'i am parsexml!')
puts "\nbenchmarks:\n"

Benchmark.bm do |x|
  x.report('parsexml') { 10000.times {|i| parsexml("parsexml #{i}", 'i am parsexml!')} }
  x.report('erubis') { 10000.times {|i| erubis("erubis #{i}", 'i am erubis!')} }
  x.report('erb') { 10000.times {|i| erb("erb #{i}", 'i am erb!')} }
  x.report('markaby') { 10000.times {|i| markaby("markaby #{i}", 'i am markaby!')} }
end
