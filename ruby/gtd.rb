contents = STDIN.read
raise "Cambia espacios por tabulaciones" if contents =~ /\t/

buckets = {
  inbox:     [],
  today:     [],
  next:      [],
  someday:   [],
  archived:  []
}

SORTING_RE   = %r{^  \[(#{buckets.keys.join('|')})\]}
archive      = ARGV[0] == 'true'
bucket, task = nil, nil

contents.each_line do |line|
  case line
  when /^$/ then next
  when /^\w+/
    # puts "Bucket: #{line.chomp.downcase.to_sym}"
    bucket = buckets[line.chomp.downcase.to_sym]
  when SORTING_RE
    bucket_name = $1.to_sym
    task = line.sub("[#{bucket_name}] ", '')
    buckets[bucket_name] << task
  when /^  \S/
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

WEIGH_RE = %r{\((.*)\)}
weigh =->(t) {
  return -1 if t =~ /^  \d{8}/
  labels = t.lines.first.chomp.scan(WEIGH_RE)[0][0].split(", ") rescue []
  labels.inject(0) do |w, l|
    w += {
      # 'hard'      => -0.5,
      'important' => 1,
      'urgent'    => 2
    }[l] || 0
  end
}

buckets.each_pair do |name, tasks|
  tasks.sort! do |t1,t2|
    t1_weight = weigh.(t1)
    t2_wight = weigh.(t2)

    if t1_weight == t2_wight
      t1_weight == -1 ? t2 <=> t1 : t1 <=> t2
    else
      t1_weight < t2_wight ? 1 : -1
    end
  end

  puts name.to_s.upcase
  tasks.each { |t| puts t }
  puts
end
