require 'spec_helper'

describe Whoops::MongoidSearchParser do
  describe "#conditions" do
    let(:search_parser){ Whoops::MongoidSearchParser.new("
      details.backtrace#all [!r/event_groups_controller/, {1: t}, [a, b]]
    ") }
    
    it "correctly handles methods" do
      search_parser.conditions.keys.first.should == "details.backtrace".to_sym.all
    end
    
    it "correctly handles an array of various values" do
      search_parser.conditions.values.first.should == [/event_groups_controller/, {1 => 't'}, ['a', 'b']]
    end
  end

  let(:search_parser){ Whoops::MongoidSearchParser.new("test") }  
  describe "#parse_line" do
    it "provides a key, method, and value when present" do
      parsed = search_parser.parse_line('details.backtrace#in ["Test"]')
      parsed[:key].should == "details.backtrace".to_sym
      parsed[:method].should == :in
      parsed[:value].should  == ["Test"]
    end
    
    it "provides a key and value without method when no method is present" do
      parsed = search_parser.parse_line('details.backtrace "Test"')
      parsed[:key].should == "details.backtrace".to_sym
      parsed[:method].should be_nil
      parsed[:value].should  == "Test"
    end
  end
  
  describe "#parse_value" do
    it "handles regexp short form" do
      search_parser.parse_value('!r/test/').should == /test/
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
