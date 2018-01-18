# frozen_string_literal: true

require 'yaml'

class Tournament
  def schedule
    group_names.each { |group_name| schedule_group(group_name) }
    favourite_permutation
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
    entrants = groups[group_name]
    entrant_names = entrants.keys

    matchups = entrant_names.combination(2).to_a.shuffle

    puts group_name

    favourite_permutation = {}
    favourite_permutation_score = 0

    matchups.permutation.each do |variation|
      tournament = {}
      time_index = 0
      location_index = 0
      location = locations[location_index]

      # build tournament
      variation.each do |matchup|
        tournament[location] ||= {}

        time = Time.at(times[time_index]).strftime('%H:%M')
        tournament[location][time] = matchup

        time_index += 1
        next unless time_index >= time_slots

        time_index = 0
        location_index += 1
        location = locations[location_index]
      end

      puts variation.inspect
      puts tournament

      # score tournament
      max_locations = 0
      valid = true

      times.each do |time_value|
        time = Time.at(time_value).strftime('%H:%M')
        players_at_time = []
        locations_at_time = 0

        locations.each do |tournament_location|
          location_matchups = tournament[tournament_location]
          puts "time: #{time}, location: #{tournament_location}, location_matchups: #{location_matchups}"
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

      if score > favourite_permutation_score
        favourite_permutation = permutation
        favourite_permutation_score = score
      end

      puts "score: #{score}, valid: #{valid}, max_locations: #{max_locations}"
      raise if valid
    end
  end
end