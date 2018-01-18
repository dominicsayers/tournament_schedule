class Schedule
  def build
    permutation.each { |matchup| add(matchup) }
  end

  private

  def initialize(permutation)
    @permutation = permutation
  end

  def schedule
    @schedule ||= {}
  end

  def add(matchup)
    register(matchup, time)
    next_slot
  end

  def next_slot
    @time_index += 1
    next unless time_index >= time_slots

    @time_index = 0
    @location_index += 1
    @location = nil
  end

  def register(matchup, time)
    schedule[location] ||= {}
    schedule[location][time] = matchup
  end

  def time_index
    @time_index ||= 0
  end

  def time
    @time ||= Time.at(times[time_index]).strftime('%H:%M')
  end

  def location_index
    @location_index ||= 0
  end

  def location
    @location ||= locations[location_index]
  end
