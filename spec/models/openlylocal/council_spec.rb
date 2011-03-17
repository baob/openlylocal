require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

Openlylocal::Council # load it up before modifying 

class Openlylocal::Council
  def self.councils_file 
    File.new(File.dirname(__FILE__) + '/../../fixtures/openlylocal/openlylocal_councils.xml')
  end
end

describe Openlylocal::Council do

  it "should have at least one council" do
    Timecop.travel(Openlylocal::Council.councils_file.mtime + 5.seconds) do # make sure the file we're using looks fresh
      Openlylocal::Council.should_not_receive(:fetch_file) # sanity check - should not go external
      Openlylocal::Council.count.should >= 1
    end
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

        it "should parse file once for 5 calls to .all" do
          Openlylocal::Council.stub!(:fetch_file).and_return(nil)
          Openlylocal::Council.should_receive(:parse_file).once.and_return([])
          5.times { Openlylocal::Council.all }
        end
    
        it "should not call fetch_file on initial load" do
          Openlylocal::Council.should_not_receive(:fetch_file)
          Openlylocal::Council
        end
        
      end # context "and with no local file available" do

      context "and with recent local file available" do
        before(:all) do
          councils_file = mock('councils_file')
          councils_file.stub!(:mtime).and_return( 1.second.ago )   
          Openlylocal::Council.stub!(:councils_file).and_return(councils_file)
          Openlylocal::Council.stub!(:parse_file).and_return([])
        end
        
        it "should not fetch file for .all" do
          Openlylocal::Council.should_not_receive(:fetch_file).and_return(nil)
          Openlylocal::Council.all
        end

        it "should parse file once for 5 calls to .all" do
          Openlylocal::Council.stub!(:fetch_file).and_return(nil)
          Openlylocal::Council.should_receive(:parse_file).once.and_return([])
          5.times { Openlylocal::Council.all }
        end

        context "but the file is stale" do
          it "should fetch file once for 5 calls to .all" do
            Timecop.travel(Openlylocal::Council.councils_file.mtime + 2.days) do
              Openlylocal::Council.should_receive(:fetch_file).once.and_return(nil)
              5.times { Openlylocal::Council.all }
            end # Timecop.travel(Openlylocal::Council.councils_file.mtime + 2.days) do
          end

          it "should parse file once for 5 calls to .all" do
            Timecop.travel(Openlylocal::Council.councils_file.mtime + 2.days) do
              Openlylocal::Council.stub!(:fetch_file).and_return(nil)
              Openlylocal::Council.should_receive(:parse_file).once.and_return([])
              5.times { Openlylocal::Council.all }
            end # Timecop.travel(Openlylocal::Council.councils_file.mtime + 2.days) do
          end
        end          
          
      end # context "and with local file available" do

    end
    
  end
  
  describe "instances" do
    before(:all) do
      Openlylocal::Council.unload!
    end
    before(:each) do
      Timecop.travel(Openlylocal::Council.councils_file.mtime + 5.seconds) do # make sure the file we're using looks fresh
        Openlylocal::Council.should_not_receive(:fetch_file) # sanity check - should not go external
        @it = Openlylocal::Council.all.first
      end
    end
    %w{ xml_data name address id telephone }.each do |attribute|
      it "should have attribute #{attribute}" do
        @it.should respond_to(attribute.to_sym)
      end
    end
  end 
  
end
