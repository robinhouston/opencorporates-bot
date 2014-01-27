# encoding: UTF-8
require 'simple_openc_bot'

require 'mechanize'


JURISDICTION = "vg"
URL = "http://www.bvifsc.vg/en-au/regulatedentities.aspx"
ROW_RE = %r{\A\s*<tr>\s*<td>\s*<a id="dnn_ctr1025_Default_gvSearchResult[^>]+>([^<]+)</a>\s*</td>\s*<td>\s*<a\s[^>]*>([^<]+)}


class OpencorporatesBotRecord < SimpleOpencBot::BaseLicenceRecord
  # The JSON schema to use to validate records; correspond with files
  # in `schema/*-schema.json`
  schema :licence

  # Fields you define here will be persisted to a local database when
  # 'fetch_records' (see below) is run.
  store_fields :name, :license_type, :reporting_date

  # This is the field(s) which will uniquely define a record (think
  # primary key in a database).
  unique_fields :name

  # This must be defined, and should return a timestamp in ISO8601
  # format. Its value should change when something about the record
  # has changed. It doesn't have to be a method - it can also be a
  # member of `store_fields`, above.
  def last_updated_at
    reporting_date
  end

  # This method must be defined. You can test that you're outputting
  # in the right format with `bin/verify_data`, which will validate
  # any data you've fetched against the relevant schema. See
  # `doc/SCHEMA.md` for documentation.
  def to_pipeline
    {
      sample_date: last_updated_at,
      company: {
        name: name,
        jurisdiction: JURISDICTION,
      },
      source_url: URL,
      data: [{
        data_type: :licence,
        properties: {
          jurisdiction_code: JURISDICTION,
          category: 'Financial',
          jurisdiction_classification: [license_type],
        }
      }]
    }
  end

end

class NoMoreData < StandardError
end

class OpencorporatesBot < SimpleOpencBot
  # the class that `fetch_records` yields. Must be defined.
  yields OpencorporatesBotRecord
  
  def process_page(initial_index_page, page_number)
    puts "Processing page #{page_number}"
    if page_number == 1
      index_page = initial_index_page
    else
      index_page = initial_index_page.form_with(:name => "Form") do |f|
        f["__EVENTTARGET"] = "dnn$ctr1025$Default$gvSearchResult"
        f["__EVENTARGUMENT"] = "Page$#{page_number}"
      end.submit
    end
    
    rows = index_page.search("table.fsc-grid > tr")[1..-2]
    if rows.nil?
      raise NoMoreData
    end
    rows.map(&:to_s).each do |row|
      match = ROW_RE.match(row)
      if match.nil?
        puts "Failed to parse row: #{row}"
      else
        yield index_page, match[1].gsub("&amp;", "&"), match[2]
      end
    end
  end

  # This method should yield Records. It must be defined.
  def fetch_all_records(opts={})
    a = Mechanize.new
    
    # Fetch the initial index page, which contains the form data we need
    # to request index pages by number
    a.get(URL) do |initial_index_page|
    
      page_number = 1
      index_page = initial_index_page
      while true do
        begin
          process_page(index_page, page_number) do |new_index_page, name, license_type|
            puts "  name=#{name}, license_type=#{license_type}"
            yield OpencorporatesBotRecord.new(
              :name => name,
              :license_type => license_type,
              :reporting_date => Time.now.utc.iso8601(2)
            )
            index_page = new_index_page
          end
          page_number += 1
        rescue NoMoreData
          break
        end
      end
    end
  end
end
