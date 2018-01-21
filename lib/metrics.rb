# frozen_string_literal: true

class Metrics
  # We try to minimise all criteria
  CRITERIA = {
    locations_required: 'locations required',
    games_per_entrant_differential: 'games per entrant (max - min)',
    longest_wait: 'longest wait between games',
    consecutive_matchups: 'most consecutive games for an entrant',
    same_club_matchups: 'games between members of same club'
  }.freeze

  def better_than?(other_schedule)
    return false unless valid?
    return true unless other_schedule

    other_metrics = other_schedule.metrics

    CRITERIA.each_key do |criterion|
      this_metric = send(criterion)
      other_metric = other_metrics.send(criterion)

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
    CRITERIA.keys.map { |criterion| "#{CRITERIA[criterion]}: #{send(criterion)}" }.join("\n")
  end

  def locations_required
    @locations_required ||= schedule.map(&:length).max
  end

  def games_per_entrant_differential
    @games_per_entrant_differential ||= games_per_entrant_values.max -
                                        games_per_entrant_values.min
  end

  def longest_wait
    @longest_wait ||= 0
  end

  def consecutive_matchups
    @consecutive_matchups ||= 0
  end

  def same_club_matchups
    @same_club_matchups ||= 0
  end

  private

  attr_reader :schedule

  def initialize(schedule)
    @schedule = schedule
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
