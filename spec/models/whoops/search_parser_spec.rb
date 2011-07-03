require 'spec_helper'

describe Whoops::SearchParser do
  describe "#mongoid_conditions" do
    let(:search_parser){ Whoops::SearchParser.new("
      details.backtrace#in 
    ") }
    it "correctly handles mehtods" do
      
    end
  end

  let(:search_parser){ Whoops::SearchParser.new("test") }  
  describe "#parse_line" do
    it "provides a key, method, and value when present" do
      parsed = search_parser.parse_line('details.backtrace#in ["Test"]')
      parsed[:key].should == "details.backtrace".to_sym
      parsed[:method].should == :in
      parsed[:value].should  == ["Test"]
    end
  end
  
  describe "#parse_value" do
    it "handles regular expressions" do
      search_parser.parse_value('!ruby/regexp "/test/"').should == /test/
    end
    
    it "handles regexp short form" do
      search_parser.parse_value('/test/').should == /test/
    end
    
    it "handles numeric and string values in arrays" do
      search_parser.parse_value('[1, "2", 4]').should == [1,'2',4]
    end
    
    it "handles hashes" do
      search_parser.parse_value('{1: 3, "a": 3, "1": "3"}').should == {
        1 => 3,
        'a' => 3,
        '1' => '3'
      }
    end
  end
end
