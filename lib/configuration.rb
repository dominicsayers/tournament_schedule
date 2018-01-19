class Configuration
  def times
    @times ||= data['times']
  end

  def locations
    @locations ||= data['locations']
  end

  def clubs
    @clubs ||= data['clubs']
  end

  def locations_count
    @locations_count ||= locations.length
  end

  def time_slots
    @time_slots ||= times.length
  end

  private

  attr_reader :data

  def initialize(filename:)
    @data = YAML.load_file(filename)
  end
end
