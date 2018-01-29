# frozen_string_literal: true

require_relative 'schedule'

class Group
  attr_reader :group_name

  def schedule
    puts "\nAssessing #{permutation_count_pretty} permutations for group #{group_name}"
    matchups.permutation.each do |permutation|
      assess(permutation)

      metrics = @best_schedule.metrics
      next unless metrics.valid?
      break if entrant_count > [5, metrics.time_slots_used].max
    end

    @best_schedule
  end

  def to_s
    <<~GROUP
      Group #{group_name}
      Locations: #{locations_count.zero? ? 'none defined' : locations.join(', ')}
      Times: #{time_strings.join(', ')}

      #{@entrants.map { |name, club| '  ' + name + ' (' + club + ')' }.join("\n")}
    GROUP
  end

  def times
    @times ||= data[:times] || []
  end

  def time_strings
    @time_strings ||= times.map { |time| time_string(time) }
  end

  def locations
    @locations ||= data[:locations] || []
  end

  def locations_count
    @locations_count ||= locations.length
  end

  def time_slots
    @time_slots ||= times.length
  end

  private

  attr_reader :data

  def initialize(data, group_name)
    @data = data
    @group_name = group_name
    @entrants = data[:entrants]

    @best_schedule = Schedule.new(self, matchups, entrant_names)

    @index = 0
    @completeness = 0
  end

  def entrant_names
    @entrant_names ||= @entrants.keys
  end

  def entrant_count
    @entrant_count ||= entrant_names.length
  end

  def matchups
    @matchups ||= entrant_names.combination(2).to_a.shuffle
  end

  def permutation_count
    @permutation_count ||= (1..matchups.length).reduce(:*) || 1
  end

  def permutation_count_pretty
    @permutation_count_pretty ||= permutation_count.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse
  end

  def assess(permutation)
    show_progress
    schedule = Schedule.new(self, permutation, entrant_names)
    return unless schedule.better_than? @best_schedule

    puts "\nNew favourite for group #{group_name}"
    puts schedule.to_s
    @best_schedule = schedule
  end

  def progress_denominator
    @progress_denominator ||= entrant_count > 5 ? 1_000_000 : 100
  end

  def progress_denominator_symbol
    @progress_denominator_symbol ||= progress_denominator == 1_000_000 ? '‰' : '%'
  end

  def show_progress
    @index += 1
    completeness = progress_denominator * @index / permutation_count

    return unless completeness > @completeness

    @completeness = completeness
    print "#{completeness}#{progress_denominator_symbol} "
  end

  def time_string(time)
    Time.at(time).utc.strftime('%H:%M')
  end
end
