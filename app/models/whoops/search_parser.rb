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
    
    key = key.to_sym
    method = method.sub(/^#/, '').to_sym
    value = parse_value(value)
    {
      :key => key,
      :method => method,
      :value => value
    }
  end
  
  # Allows user to enter hashes or array
  def parse_value(value)
    value = value.strip
    value = "!ruby/regexp \"#{value}\"" if value =~ /^\/.*\/$/
    return YAML.load(value)
  end
end