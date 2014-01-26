# encoding: UTF-8
require 'simple_openc_bot'

# you may need to require other libraries here
# require 'nokogiri'
# require 'mechanize'

class Opencorporates-botRecord < SimpleOpencBot::BaseLicenceRecord
  # The JSON schema to use to validate records; correspond with files
  # in `schema/*-schema.json`
  schema :licence

  # Fields you define here will be persisted to a local database when
  # 'fetch_records' (see below) is run.
  store_fields :name, :type, :reporting_date

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
        jurisdiction: "xx",
      },
      source_url: "xx",
      data: [{
        data_type: :licence,
        properties: {
          jurisdiction_code: "xx",
          category: 'Financial',
          jurisdiction_classification: [type],
        }
      }]
    }
  end

end

class Opencorporates-bot < SimpleOpencBot

  # the class that `fetch_records` yields. Must be defined.
  yields Opencorporates-botRecord

  # This method should yield Records. It must be defined.
  def fetch_all_records(opts={})
    data = [{:name => "A", :type => "B"}]
    data.each do |datum|
      yield Opencorporates-botRecord.new(
        datum.merge(:reporting_date => Time.now.iso8601(2)))
    end
  end
end
