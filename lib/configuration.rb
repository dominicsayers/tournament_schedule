# frozen_string_literal: true

class Configuration
  def times
    @times ||= data['times']
  end

  def time_strings
    @time_strings ||= times.map { |time| time_string(time) }
  end

  def locations
    @locations ||= data['locations'] || []
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
      clubs.each_with_object({}) do |(club, entrants), a|
        entrants.each do |e|
          group, name = e.is_a?(String) ? ['default', e] : [e['group'], e['name']]

          # puts "loading #{name} from #{club} into #{group} (#{e})"

          a[group] ||= {}
          a[group][name] = club
        end
      end
    end
  end

  def group_names
    @group_names ||= groups.keys.shuffle
  end

  def time_string(time)
    Time.at(time).strftime('%H:%M')
  end

  def to_s
    <<~CONFIGURATION
      Locations: #{locations_count.zero? ? 'none defined' : locations.join(', ')}
      Times: #{time_strings.join(', ')}
      Groups:

      #{group_names.map { |group_name| Group.new(self, group_name) }.join("\n")}
    CONFIGURATION
  end

  private

  attr_reader :data

  def initialize(filename:)
    @data = YAML.load_file(filename)
  end
end
