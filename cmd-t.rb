#!/usr/bin/env ruby

QUIT_CODE = "\u0003"

HISTORY = File.read("/Users/logaan/.bash_history").split("\n")
BOLD = `tput smso`
OFFBOLD = `tput rmso`

def getkey
  begin
    system("stty raw -echo")
    key = STDIN.getc
  ensure
    system("stty -raw echo")
  end
  key
end

def display_results(query, results)
  formatted = results.uniq.reverse.map{|l| format_line(query, l) }.to_a[0..10]

  print "[H[J"
  puts query
  puts
  puts formatted
end

def format_line(query, line)
  line = line[0...80]
  line = line.gsub(fuzz(query), BOLD + '\0' + OFFBOLD)
  line
end

def fuzz(query)
  pattern = Regexp.new(query.each_char.to_a.join(".*?"))
  pattern
end

def add_key_to_query(key, query)
  if key == "\x7F"
    query[0...-1]
  else
    query + key
  end
end

query = ""
while key = getkey
  exit if key == QUIT_CODE
  query = add_key_to_query(key, query)
  display_results(query, HISTORY.grep(fuzz(query)))
end

