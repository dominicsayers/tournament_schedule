class Schedule
  def build
    @permutation.each { |matchup| add(matchup) }
    # puts @schedule.inspect # debug
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
    data.time_strings[time_index]
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
