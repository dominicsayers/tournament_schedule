class Permutation
  def assess
    times.each do |time_value|
      time = Time.at(time_value).strftime('%H:%M')
      players_at_time = []
      locations_at_time = 0

      locations.each do |schedule_location|
        location_matchups = schedule[schedule_location]
        puts "time: #{time}, location: #{schedule_location}, location_matchups: #{location_matchups}"
        next unless location_matchups && !location_matchups.empty?

        locations_at_time += 1

        # Ensure player isn't in two places at once
        matchup = location_matchups[time]

        unless (players_at_time & matchup).empty?
          puts "#{time} clash for #{players_at_time} and #{matchup}"
          valid = false
        end

        players_at_time |= matchup
      end

      locations_at_time = time.length
      max_locations = locations_at_time if locations_at_time > max_locations
    end

    score = valid ? locations_count - max_locations : 0

    puts "score: #{score}, valid: #{valid}, max_locations: #{max_locations}"
    raise if valid
  end

  private

  def initialize(permutation)
    @permutation = permutation
  end

  def schedule
    @schedule ||= Tournament.new(permutation).build
  end

  def max_locations
    @max_locations ||= 0
  end

  def valid
    @valid ||= true
  end
end
