require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Openlylocal::Council do

  it "should have at least one council" do
    Openlylocal::Council.count.should >= 1
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
