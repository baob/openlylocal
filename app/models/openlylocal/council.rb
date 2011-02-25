module Openlylocal

  require 'rexml/document'
  require 'net/http'
  require 'uri'

  class Council
    
    # NOTE NOTE NOTE -----  This is not production ready code
    # 2) Needs memcaching
    # 4) Protection against HTTP problems, such as 404, server not responsding, short data file
    # 5) protection against XML parsing errors
    # 6) Probably more ...
  
    attr_accessor :xml_data, :id, :name, :openlylocal_url, :wikipedia_url, :address, :normalised_title, :url,
                  :telephone, :country, :region
    
    @@councils = nil
    
    def self.unload!
      @@councils = nil
    end
    
    def self.councils_filename
      File.expand_path(File.dirname(__FILE__) + "/../../../files/openlylocal_councils.xml")
    end

    def self.councils_url
      "http://openlylocal.com/councils/open.xml"
    end

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
      url = URI.parse(councils_url)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      File.open(councils_filename, 'w') {|f| f.write(res.body) }
    end
    
    def self.councils_file
      File.new(councils_filename)
    end
    
    def self.load!
      if !File.exists?(councils_filename)
        fetch_file 
        @@councils = parse_file
      elsif councils_file.mtime < Time.now - 1.day
        fetch_file
        @@councils = parse_file
      end
      @@councils = parse_file unless loaded?
    end
    
    def self.loaded?
      !@@councils.nil?
    end

    def self.parse_file
      council_doc = REXML::Document.new(councils_file)
      council_doc.root.elements.map do |council_node| 
        Council.new(council_node) 
      end
    end

    def self.find_by_name(name)
      all.detect{ |c| c.name == name } 
    end

    def self.find(id) # find on openly local's own id, takes string or integer
      match_id = id.is_a?(Fixnum) ? id.to_s : id
      all.detect{ |c| c.id == match_id } 
    end
    
    def self.all
      load! unless loaded?
      @@councils
    end

    def self.count
      all.size
    end
    
  end # class Council

end
