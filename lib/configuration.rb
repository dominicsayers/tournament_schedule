class Configuration
  def times
    @times ||= data['times']
  end

  def time_strings
    @time_strings ||= times.map { |time| Time.at(time).strftime('%H:%M') }
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

  def time_string(time)
  end

  private

  attr_reader :data

  def initialize(filename:)
    @data = YAML.load_file(filename)
  end
end
