require 'mechanize'

URL = "http://www.bvifsc.vg/en-au/regulatedentities.aspx"
ROW_RE = %r{\A\s*<tr>\s*<td>\s*<a id="dnn_ctr1025_Default_gvSearchResult[^>]+>([^<]+)</a>\s*</td>\s*<td>\s*<a\s[^>]*>([^<]+)}

def print_company_names(page)
  page.search("table.fsc-grid > tr")[1..-2].map(&:to_s).each do |row|
    match = ROW_RE.match(row)
    if match.nil?
      $stderr.puts "No match: #{row}"
    else
      puts match[1], match[2], ""
    end
  end
end

def process_next_page(page, n)
  next_page = page.form_with(:name => "Form") do |f|
    f["__EVENTTARGET"] = "dnn$ctr1025$Default$gvSearchResult"
    f["__EVENTARGUMENT"] = "Page$#{n+1}"
  end.submit
  process_page(next_page, n+1)
end

def process_page(page, n)
  puts "Processing page #{n}..."
  print_company_names(page)
  process_next_page(page, n)
end

def start()
  a = Mechanize.new
  a.get(URL) do |page|
    process_page(page, 1)
  end
end

start
