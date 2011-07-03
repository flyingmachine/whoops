class Whoops::SearchParser
  attr_accessor :query
  def initialize(query)
    self.query = query
  end
  
  def mongoid_conditions
    self.query.split("\n").each do |line|
      line
    end
  end
  
  def parse_line(line)
    key, method, value = line.match(/(.*?)(#.*)? (.*)/)[1..3]
    key    = key.to_sym
    method = method.sub(/^#/, '').to_sym
    value  = parse_value(value)
    {
      :key => key,
      :method => method,
      :value => value
    }
  end
  
  # Allows user to enter hashes or array
  def parse_value(value)
    case value.slice(0..0)
    when '[': parse_array(value)
    end
  end
  
  def parse_array(value)
    array = value.gsub(/[\[\]]/, '').split(",")
    array.collect{ |t| 
      if t =~ /^\d+$/
        t.to_i
      else
        # remove beginning and ending quotes
        t.sub(/^['"]/, '').sub(/['"$]/, '')
      end
    }
  end
end