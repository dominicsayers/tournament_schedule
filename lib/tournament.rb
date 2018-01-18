# frozen_string_literal: true

require 'yaml'

class Tournament
  def schedule
    group_names.each { |group_name| puts schedule_group(group_name) }
  end

  private

  def initialize(filename:)
    @filename = filename
  end

  def data
    @data ||= YAML.load_file(@filename)
  end

  def times
    @times ||= data['times']
  end

  def time_slots
    @time_slots ||= times.length
  end

  def locations
    @locations ||= data['locations']
  end

  def locations_count
    @locations_count ||= locations.length
  end

  def clubs
    @clubs ||= data['clubs']
  end

  def groups
    @groups ||= begin
      clubs.each_with_object({}) do |(k, v), a|
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
    Group.new(groups[group_name]).schedule
  end

