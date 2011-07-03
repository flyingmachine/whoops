require 'spec_helper'

describe Whoops::SearchParser do
  let(:sp){ Whoops::SearchParser.new("test") }
  
  describe "#parse_line" do
    it "provides a key, method, and value when present" do
      parsed = sp.parse_line('details.backtrace#in ["Test"]')
      parsed[:key].should == "details.backtrace".to_sym
      parsed[:method].should == :in
      parsed[:value].should  == ["Test"]
    end
  end
  
  describe "#parse_value" do
    it "handles numeric and string values in arrays" do
      sp.parse_value('[1,"2",4]').should == [1,'2',4]
    end
  end
end
