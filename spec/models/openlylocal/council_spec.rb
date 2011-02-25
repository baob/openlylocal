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
    
    context "in intial state" do
      before(:each) do
        Openlylocal::Council.unload!
      end

      context "and with no local file available" do
    
        before(:each) do
          File.stub!(:exists?).with(Openlylocal::Council.councils_filename).and_return(false)
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
    
        it "should not call fetch_file on initial load" do
          Openlylocal::Council.should_not_receive(:fetch_file)
          Openlylocal::Council
        end
        
      end # context "and with no local file available" do

      context "and with local file available" do
        it "should not fetch file for .all" do
          Openlylocal::Council.should_not_receive(:fetch_file).and_return(nil)
          Openlylocal::Council.all
        end

          context "but the file is stale" do
            it "should fetch file once for 5 calls to .all" do
              Timecop.travel(Openlylocal::Council.councils_file.mtime + 2.days) do
                Openlylocal::Council.should_receive(:fetch_file).once.and_return(nil)
                5.times { Openlylocal::Council.all }
              end # Timecop.travel(Openlylocal::Council.councils_file.mtime + 2.days) do
            end
          end          
          
      end # context "and with local file available" do

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
