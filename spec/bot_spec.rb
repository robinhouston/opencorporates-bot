# encoding: UTF-8
require_relative 'spec_helper'
require_relative '../lib/opencorporates-bot'

describe MyModule do

  it "should extend with OpencBot methods" do
    MyModule.should respond_to :save_data
  end

end
