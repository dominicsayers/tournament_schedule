# frozen_string_literal: true

require 'yaml'

data = YAML.load_file('data.yml')

times = data['times']
time_slots = times.length

locations = data['locations']
locations_count = locations.length

clubs = data['clubs']

puts times
puts locations

groups = clubs.each_with_object({}) do |(k, v), a|
  v.each do |e|
    group = e['group']
    a[group] ||= {}
    a[group][e['name']] = k
  end
end

group_names = groups.keys.shuffle

group_names.each do |group_name|
  entrants = groups[group_name]
  entrant_names = entrants.keys

  matchups = entrant_names.combination(2).to_a.shuffle

  puts group_name

  favourite_permutation = {}
  favourite_permutation_score = 0

  matchups.permutation.each do |permutation|
    tournament = {}
    time_index = 0
    location_index = 0
    location = locations[location_index]

    # build tournament
    permutation.each do |matchup|
      tournament[location] ||= {}

      time = times[time_index].to_s
      tournament[location][time] = matchup

      time_index += 1
      next unless time_index > time_slots

      time_index = 0
      location_index += 1
      location = locations[location_index]
    end

    puts tournament

    # score tournament
    max_locations = 0
    valid = true

    times.each do |time_value|
      time = time_value.to_s
      players_at_time = []
      locations_at_time = 0

      locations.each do |tournament_location|
        matchups = tournament[tournament_location]
        next unless matchups && !matchups.empty?

        locations_at_time += 1

        # Ensure player isn't in two places at once
        matchup = matchups[time]

        unless (players_at_time & matchup).empty?
          puts "#{time} clash for #{players_at_time} and #{matchup}"
          break valid = false
        end

        players_at_time |= matchup
      end

      break unless valid

      locations_at_time = time.length
      max_locations = locations_at_time if locations_at_time > max_locations
    end

    score = valid ? locations_count - max_locations : 0

    if score > favourite_permutation_score
      favourite_permutation = permutation
      favourite_permutation_score = score
    end

    puts "score: #{score}, valid: #{valid}, max_locations: #{max_locations}"
    raise if valid
  end
end
