# frozen_string_literal: true

require 'yaml'
require_relative 'group'
require_relative 'configuration'

class Tournament
  def schedule
    puts data
    data.group_names.each { |group_name| Group.new(data, group_name).schedule }
    nil
  end

  private

  attr_reader :data

  def initialize(filename:)
    @data ||= Configuration.new(filename: filename)
  end
end
