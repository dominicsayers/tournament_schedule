# frozen_string_literal: true

require 'yaml'
require_relative 'group'
require_relative 'configuration'

class Tournament
  def schedule
    group_names.each { |group_name| puts schedule_group(group_name) }
  end

  private

  def initialize(filename:)
    @filename = filename
  end

  def data
    @data ||= Configuration.new(filename: @filename)
  end

  def groups
    @groups ||= begin
      data.clubs.each_with_object({}) do |(k, v), a|
        v.each do |e|
          group = e['group']
          a[group] ||= {}
          a[group][e['name']] = k
        end
      end
    end
  end

  def group_names
    @group_names ||= groups.keys.shuffle
  end

  def schedule_group(group_name)
    Group.new(data, groups[group_name]).schedule
  end
end
