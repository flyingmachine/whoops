# Parses text to create corresponding mongoid conditions.
# See README for details on syntax.
class Whoops::MongoidSearchParser
  attr_accessor :query
  def initialize(query)
    self.query = query
  end
  
  def conditions
    self.query.split("\n").inject({}) do |conditions, line|
      line.strip!
      next(conditions) if line.empty?
      
      parsed = parse_line(line)
      key = parsed[:method] ? parsed[:key].send(parsed[:method]) : parsed[:key]
      
      conditions[key] = parsed[:value]
      conditions
    end
  end
  
  def parse_line(line)
    key, method, value = line.match(/([^\s]*?)(#[^\s]*)? ([^#]*)/)[1..3]
    
    key = key.sub(/:$/, '').to_sym
    method = method.gsub(/(^#|:$)/, '').to_sym if method
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
    # value = "!ruby/regexp \"#{value}\"" if value =~ /^\/.*\/$/
    value.gsub!(/!r(\/.*?\/)/, %Q{!ruby/regexp "\\1"})
    return YAML.load(value)
  end
end
