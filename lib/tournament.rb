# frozen_string_literal: true

require 'yaml'
require_relative 'group'
require_relative 'configuration'

class Tournament
  def schedule
    puts data
    schedules = data.group_names.map { |group_name| [group_name, Group.new(data, group_name).schedule] }.to_h

    schedules.each do |group_name, schedule|
      puts <<~SCHEDULE

        Group: #{group_name}

        #{schedule}

        #{'-' * 80}
      SCHEDULE
    end

    nil
  end

  private

  attr_reader :data

  def initialize(filename:)
    @data ||= Configuration.new(filename: filename)
  end
end
