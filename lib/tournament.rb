# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'pathname'
require 'yaml'
require_relative 'group'
require_relative 'configuration'

class Tournament
  def schedule
    puts data

    threads = data.group_names.map do |group_name|
      Thread.new { Group.new(data.groups[group_name], group_name).schedule }
    end

    @schedules = threads.map do |thread|
      thread_schedule = thread.join.value
      [thread_schedule.group.group_name, thread_schedule]
    end.to_h

    puts to_s
    to_csv
    nil
  end

  private

  attr_reader :data

  def initialize(filename:)
    @data ||= Configuration.new(filename: filename)
    @tournament_name = Pathname.new(filename).basename('.*').to_s
    @schedules = {}
  end

  def to_s
    @schedules.keys.sort.map do |group_name|
      <<~SCHEDULE

        Group: #{group_name}

        #{@schedules[group_name]}

        #{'-' * 80}
      SCHEDULE
    end.join"\n"
  end

  def to_csv
    @schedules.keys.sort.each do |group_name|
      filepath = Pathname.new File.join("schedules", @tournament_name, "#{group_name}.csv")
      FileUtils.mkdir_p filepath.dirname
      CSV.open(filepath, "wb") { |csv| @schedules[group_name].to_csv(csv) }
    end
  end
end
