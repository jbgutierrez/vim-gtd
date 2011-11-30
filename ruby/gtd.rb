contents = STDIN.read
archive  = ARGV[0] == 'true'

buckets = {}
names = [:inbox, :today, :next, :someday, :archived]
names.each { |name| buckets[name] = []}

bucket, task = nil, nil
contents.each_line do |line|
  case line
  when /^\s+$/
    next
  when /^\w+$/
    # puts "Bucket: #{line.chomp.downcase.to_sym}"
    bucket = buckets[line.chomp.downcase.to_sym]
  when /^  .*\[today\]/
    task = line.sub('[today] ', '')
    buckets[:today] << task
  when /^  .*\[next\]/
    task = line.sub('[next] ', '')
    buckets[:next] << task
  when /^  .*\[someday\]/
    task = line.sub('[someday] ', '')
    buckets[:someday] << task
  when /^  [^ ]/
    # puts "Task: #{line}"
    task = line
    if archive && line =~ /^  \d{8}/
      buckets[:archived] << task
    else
      bucket << task
    end
  else
    # puts "Note: #{line}"
    task << line
  end
end

raise "Formato incorrecto" if buckets.size != 5

names.each_with_index do |name, idx|
  tasks = buckets[name]

  tasks.sort! do |a,b|
    a_weight, b_weight = 0, 0
    a_weight += 2 if a =~ /urgent/
    b_weight += 2 if b =~ /urgent/
    a_weight += 1 if a =~ /important/
    b_weight += 1 if b =~ /important/
    a_weight = -1 if a =~ /^  \d{8}/
    b_weight = -1 if b =~ /^  \d{8}/
    if a_weight == b_weight
      a_weight == -1 ? b <=> a : a <=> b
    else
      a_weight < b_weight ? 1 : -1
    end
  end

  (idx + 1).upto(4) do |idx|
    outter_bucket = names[idx]
    tasks.reject! { |t|
      pattern = t.strip.gsub(/\(.*/, '')
      pattern = /#{pattern}/
      buckets[outter_bucket].any?{ |it| it =~ pattern}
    }
  end

  tasks.reject! { |t|
    idx = tasks.find_index(t)
    pattern = t.strip.gsub(/\(.*/, '')
    pattern = /#{pattern}/
    range = (idx + 1) .. (tasks.length - 1)
    tasks[range].any?{ |it| it =~ pattern}
  }

end

names.each do |name|
  puts name.to_s.upcase
  buckets[name].each do |task|
    puts task.to_s
  end
  puts "\n"
end
