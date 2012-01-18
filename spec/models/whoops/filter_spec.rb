require 'spec_helper'

describe Whoops::Filter do
  describe "#to_query_document" do
    it "should not include _id" do
      keys = Whoops::Filter.new.to_query_document.keys
      keys.should_not include(:_id)
      keys.should_not include("_id")
    end
  end
end
