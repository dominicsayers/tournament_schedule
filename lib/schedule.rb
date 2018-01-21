# frozen_string_literal: true

require_relative 'exception'
require_relative 'metrics'

class Schedule
  attr_reader :metrics

  def better_than?(other_schedule)
    metrics.better_than? other_schedule
  end

  def to_s
    "#{to_s_header}\n#{to_s_body}\n\n#{metrics}"
  end

  def schedule
    @schedule ||= {}
  end

  private

  attr_reader :data

  def initialize(data, permutation)
    @data = data
    permutation.each { |matchup| register(matchup) }
  rescue InvalidPermutation
    @schedule = nil
  ensure
    @metrics = Metrics.new(schedule)
  end

  def register(matchup)
    time_list = time_lists.find { |_time_string, players_at_time| (players_at_time & matchup).empty? }
    raise InvalidPermutation unless time_list

    time_string = time_list[0]
    time_lists[time_string] |= matchup

    schedule[time_string] ||= []
    schedule[time_string] << matchup
  end

  def time_lists
    @time_lists ||= data.time_strings.map { |time_string| [time_string, []] }.to_h
  end

  def to_s_header
    "\t" + (1..metrics.locations_required).map { |i| data.locations[i - 1] || 'undefined' }.join("\t")
  end

  def to_s_body
    schedule.map do |time_string, matchups|
      "#{time_string}\t#{matchups.map { |m| m.join(' v ') }.join("\t")}"
    end.join("\n")
  end
end
