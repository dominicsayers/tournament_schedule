# frozen_string_literal: true

class Metrics
  # We try to minimise all criteria
  CRITERIA = {
    locations_required: 'locations required',
    time_slots_used: 'time slots used',
    games_per_entrant_differential: 'games per entrant (max - min)',
    longest_wait: 'longest wait between games',
    consecutive_matchups: 'most consecutive games for an entrant',
    same_club_matchups: 'games between members of same club'
  }.freeze

  INTERESTING = {
    max_games_per_entrant: 'maximum games per entrant',
    min_games_per_entrant: 'minimum games per entrant'
  }.merge(CRITERIA)

  def better_than?(other_schedule)
    return false unless valid?
    return true unless other_schedule

    other_metrics = other_schedule.metrics

    CRITERIA.each_key do |criterion|
      this_metric = send(criterion)
      other_metric = other_metrics.send(criterion)

      return true unless other_metric
      return false if this_metric > other_metric
      return true  if this_metric < other_metric
      # continue to next priority if these metrics are equal
    end

    false
  end

  def valid?
    !schedule.empty?
  end

  def to_s
    INTERESTING.keys.map { |criterion| "#{INTERESTING[criterion]}: #{send(criterion)}" }.join("\n")
  end

  def locations_required
    @locations_required ||= schedule.values.map(&:length).max
  end

  def time_slots_used
    @time_slots_used ||= schedule.keys.length
  end

  def max_games_per_entrant
    @max_games_per_entrant ||= games_per_entrant_values.max
  end

  def min_games_per_entrant
    @min_games_per_entrant ||= games_per_entrant_values.min
  end

  def games_per_entrant_differential
    @games_per_entrant_differential ||= 0 # max_games_per_entrant_values - min_games_per_entrant_values
  end

  def longest_wait
    @longest_wait ||= begin
      longest = 0
      time_slot = 0
      entrant_latest_time_slot = {}

      schedule.each_value do |matchups|
        time_slot += 1

        matchups.each do |matchup|
          matchup.each do |entrant|
            latest_time_slot = entrant_latest_time_slot[entrant]
            wait = time_slot - (latest_time_slot || 0)
            longest = wait if wait > longest
            entrant_latest_time_slot[entrant] = time_slot
          end
        end
      end

      longest
    end
  end

  def consecutive_matchups
    @consecutive_matchups ||= 0 # begin
=begin
      longest_run = 0
      runs = {}
      time_slot = 0

      schedule.each_value do |matchups|
        time_slot += 1
        time_slot_entrants = matchups.flatten

        @entrant_names.map do |entrant|
          if time_slot_entrants.include?(entrant)
            runs[entrant] ||= 0
            runs[entrant] += 1
          else
            runs[entrant] = 0
          end
        end

        longest_current_run = runs.values.max
        longest_run = [longest_run, longest_current_run].max
      end

      longest_run
    end
=end
  end

  def same_club_matchups
    @same_club_matchups ||= 0
  end

  private

  attr_reader :schedule

  def initialize(schedule, entrant_names)
    @schedule = schedule
    @entrant_names = entrant_names
  end

  def games_per_entrant_values
    games_per_entrant.values
  end

  def games_per_entrant
    games_per_entrant = {}

    schedule.each_value do |matchups|
      matchups.each do |matchup|
        matchup.each do |entrant|
          games_per_entrant[entrant] ||= 0
          games_per_entrant[entrant] += 1
        end
      end
    end

    games_per_entrant
  end
end
