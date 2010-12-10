module Openlylocal

  require 'rexml/document'
  require 'net/http'
  require 'uri'

  class Council
  
    attr_accessor :xml_data, :id, :name, :openlylocal_url, :wikipedia_url, :address, :normalised_title, :url,
                  :telephone, :country, :region

    OL_FILENAME = File.expand_path(File.dirname(__FILE__) + "/../../../files/openlylocal_councils.xml")
    OL_COUNCILS_URL = "http://openlylocal.com/councils/open.xml"

    def initialize(council_node)
      self.xml_data = council_node
      self.name = council_node.elements['name'].text
      self.openlylocal_url = council_node.elements['openlylocal-url'].text
      self.wikipedia_url = council_node.elements['wikipedia-url'].text
      self.address = council_node.elements['address'].text
      self.id = council_node.elements['id'].text
      self.normalised_title = council_node.elements['normalised-title'].text
      self.url = council_node.elements['url'].text
      self.telephone = council_node.elements['telephone'].text
      self.country = council_node.elements['country'].text
      self.region = council_node.elements['region'].text
      self
    end

    def self.fetch_file
      url = URI.parse(OL_COUNCILS_URL)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      File.open(OL_FILENAME, 'w') {|f| f.write(res.body) }
    end

    begin
      file = File.new(OL_FILENAME)
    rescue Errno::ENOENT
      fetch_file
      file = File.new(OL_FILENAME)
    end 
    
    council_doc = REXML::Document.new(file)
    @@councils = council_doc.root.elements.map do |council_node| 
      Council.new(council_node) 
    end
    
  
    def self.find_by_name(name)
      @@councils.detect{ |c| c.name == name } 
    end

    def self.find(id) # find on openly local's own id, takes string or integer
      match_id = id.is_a?(Fixnum) ? id.to_s : id
      @@councils.detect{ |c| c.id == match_id } 
    end
    
    def self.all
      @@councils
    end

    def self.count
      @@councils.size
    end
    
  end # class Council

end
