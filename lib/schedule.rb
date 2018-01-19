class Schedule
  def build
    @permutation.each { |matchup| add(matchup) }
    @schedule
  end

  private

  attr_reader :data

  def initialize(data, permutation)
    @data = data
    @permutation = permutation
  end

  def schedule
    @schedule ||= {}
  end

  def add(matchup)
    register(matchup)
    next_slot
  end

  def next_slot
    @time_index += 1
    return unless time_index >= data.time_slots

    @time_index = 0
    @location_index += 1
    @location = nil
  end

  def register(matchup)
    schedule[location] ||= {}
    schedule[location][time] = matchup
  end

  def time_index
    @time_index ||= 0
  end

  def time
    Time.at(data.times[time_index]).strftime('%H:%M')
  end

  def location_index
    @location_index ||= 0
  end

  def location
    @location ||= begin
      extra = location_index - data.locations_count
      extra < 0 ? data.locations[location_index] : "Extra location #{extra + 1}"
    end
  end
end
