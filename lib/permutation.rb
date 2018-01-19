require_relative 'schedule'

class Permutation
  def assess
    data.time_strings.each { |time| score(time) }

    score = @valid ? data.locations_count - @max_locations : 0
    # puts "score: #{score}, valid: #{@valid}, max_locations: #{@max_locations}" # debug
    score
  end

  def score(time)
    players_at_time = []
    locations_at_time = 0

    @schedule.keys.each do |schedule_location|
      # Ensure player isn't in two places at once
      matchup = @schedule[schedule_location][time]
      next unless matchup

      locations_at_time += 1

      unless (players_at_time & matchup).empty?
        # puts "#{time} clash for #{players_at_time} and #{matchup}" # debug
        @valid = false
        return
      end

      players_at_time |= matchup
    end

    @max_locations = locations_at_time if locations_at_time > @max_locations
  end

  private

  attr_reader :data

  def initialize(data, permutation)
    @data = data
    @permutation = permutation
    @schedule = Schedule.new(data, @permutation).build

    @max_locations = 0
    @valid = true
  end
end
