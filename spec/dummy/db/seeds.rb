services = Array.new(10){ Faker::Internet.domain_word }
service_suffixes = %w{app worker}
environments = %w{development qa production}
event_types = %w{info exception warning}

def random_el(arr)
  arr[rand(arr.count)]
end

def random_hash(depth)
  h = {}
  (rand(10) + 3).times {
    h[Faker::Lorem.words(1).first] = random_value(depth)
  }
  h
end

def random_value(depth)
  if depth == 3
    Faker::Lorem.words(1).first
  else
    new_depth = depth + 1
    case rand(3)
    when 0 then random_hash(new_depth)
    when 1 then random_array(new_depth)
    else
      Faker::Lorem.words(1).first
    end
  end
end

def random_array(depth)
  Array.new(rand(8) + 1){ random_value(depth) }
end

100.times { |event_group_i|
  puts event_group_i
  message = Faker::Lorem.sentence
  service = "#{random_el(services)}.#{random_el(service_suffixes)}"
  event_type = random_el(event_types)
  environment = random_el(environments)
  rand(40).times {
    Whoops::NewEvent.new(
      :message => message,
      :details => random_hash(0),
      :service => service,
      :environment => environment,
      :event_type => event_type,
      :event_group_identifier => event_group_i
      ).record!
  }
}
