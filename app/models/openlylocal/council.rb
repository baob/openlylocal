module Openlylocal

  require 'rexml/document'
  require 'net/http'
  require 'uri'

  class Council
  
    attr_accessor :xml_data, :name, :openlylocal_url, :wikipedia_url, :address

    def initialize(council_node)
      self.xml_data = council_node
      self.name = council_node.elements['name'].text
      self.openlylocal_url = council_node.elements['openlylocal-url'].text
      self.wikipedia_url = council_node.elements['wikipedia-url'].text
      self.address = council_node.elements['address'].text
      self
    end

    filename = File.expand_path(File.dirname(__FILE__) + "/../../../files/openlylocal_councils.xml")
    
    puts "------------"+filename
    
    begin
      file = File.new(filename)
    rescue Errno::ENOENT
      puts "------------ get "
      
      url = URI.parse('http://openlylocal.com/councils.xml')
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
  
      puts "------------ get 2"
      
      File.open(filename, 'w') {|f| f.write(res.body) }
      puts "------------ get 3 "
      
      file = File.new(filename)
      
    end 
    
    council_doc = REXML::Document.new(file)
    @@councils = council_doc.root.elements.map do |council_node| 
      Council.new(council_node) 
    end
    
  
    def self.find(name)
      @@councils.detect{ |c| c.name == name } 
    end
  end

end