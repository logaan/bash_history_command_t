#!/usr/bin/env ruby

QUIT_CODE = "\u0003"
NEXT_CODE = "\x0E"
PREV_CODE = "\x10"

HISTORY = File.read("/Users/logaan/.bash_history").split("\n")

BLUE_BACKGROUND   = `tput setab 4`
WHILE_FOREGROUND  = `tput setaf 7`
YELLOW_FOREGROUND = `tput setaf 3`

SELECT    = BLUE_BACKGROUND
UNSELECT  = `tput sgr0`
HIGHLIGHT = YELLOW_FOREGROUND
RESET     = WHILE_FOREGROUND

def getkey
  begin
    system("stty raw -echo")
    key = STDIN.getc
  ensure
    system("stty -raw echo")
  end
  key
end

def display_results(query, results, selected_line)
  uniqued   = results.uniq
  ordered   = uniqued.reverse
  formatted = ordered.map{|l| format_line(query, l) }
  trimmed   = formatted.to_a[0..10]

  trimmed[selected_line] = SELECT + trimmed[selected_line] + UNSELECT

  print "[H[J"
  puts query
  puts
  puts trimmed
end

def format_line(query, line)
  line = line[0...80]
  line = line.gsub(fuzz(query), HIGHLIGHT + '\0' + RESET)
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
selected_line = 0

while key = getkey
  case key
  when QUIT_CODE
    exit
  when NEXT_CODE
    selected_line += 1
  when PREV_CODE
    selected_line -= 1
  else
    query = add_key_to_query(key, query)
  end

  display_results(query, HISTORY.grep(fuzz(query)), selected_line)
end

