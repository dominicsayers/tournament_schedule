# frozen_string_literal: true

require_relative 'exception'
require_relative 'metrics'

class Schedule
  attr_reader :metrics, :group

  def better_than?(other_schedule)
    metrics.better_than? other_schedule
  end

  def to_s
    "#{to_s_header}\n#{to_s_body}\n\n#{metrics}"
  end

  def to_csv(csv)
    csv << ['Time'] + (1..(metrics.locations_required || 1)).map { |i| location_name(i - 1) }

    schedule.each do |time_string, matchups|
      csv << [time_string] + matchups.map { |m| m.join(' v ') }
    end
  end

  def schedule
    @schedule ||= {}
  end

  private

  def initialize(group, permutation, entrant_names)
    @group = group
    permutation.each { |matchup| register(matchup) }
  rescue InvalidPermutation
    @schedule = nil
  ensure
    @metrics = Metrics.new(schedule, entrant_names)
  end

  def register(matchup)
    time_list = time_lists.find { |_, players_at_time| (players_at_time & matchup).empty? }
    raise InvalidPermutation unless time_list

    time_string = time_list[0]
    time_lists[time_string] |= matchup

    schedule[time_string] ||= []
    schedule[time_string] << matchup
  end

  def time_lists
    @time_lists ||= group.time_strings.map { |time_string| [time_string, []] }.to_h
  end

  def to_s_header
    "\t" + (1..(metrics.locations_required || 1)).map { |i| location_name(i - 1) }.join("\t")
  end

  def to_s_body
    schedule.map do |time_string, matchups|
      "#{time_string}\t#{matchups.map { |m| m.join(' v ') }.join("\t")}"
    end.join("\n")
  end

  def location_name(index)
    "Pitch #{group.locations[index] || 'undefined'}"
  end
end
