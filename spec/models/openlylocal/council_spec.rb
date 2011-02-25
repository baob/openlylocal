require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

Openlylocal::Council # load it up before modifying 

class Openlylocal::Council
  def self.councils_file 
    File.new(File.dirname(__FILE__) + '/../../fixtures/openlylocal/openlylocal_councils.xml')
  end
end

describe Openlylocal::Council do

  it "should have at least one council" do
    Openlylocal::Council.count.should >= 1
  end
  
  describe "Caching:" do
    before(:each) do
      Openlylocal::Council.unload!
      File.stub!(:exists?).with(Openlylocal::Council.councils_filename).and_return(false)
      # Openlylocal::Council.stub!(:fetch_file).and_return(nil)
    end
    
    it "should fetch file once for .count" do
      Openlylocal::Council.should_receive(:fetch_file).once.and_return(nil)
      Openlylocal::Council.count
    end
      
    it "should fetch file once for .all" do
      Openlylocal::Council.should_receive(:fetch_file).once.and_return(nil)
      Openlylocal::Council.all
    end

    it "should fetch file once for 5 calls to .all" do
      Openlylocal::Council.should_receive(:fetch_file).once.and_return(nil)
      5.times { Openlylocal::Council.all }
    end
    
    context "on initial load" do
      it "should not call fetch_file" do
        Openlylocal::Council.should_not_receive(:fetch_file)
        Openlylocal::Council
      end
    end
    
  end
  
  describe "instances" do
    before(:each) do
      @it = Openlylocal::Council.all.first
    end
    %w{ xml_data name address id telephone }.each do |attribute|
      it "should have attribute #{attribute}" do
        @it.should respond_to(attribute.to_sym)
      end
    end
  end 
  
end
