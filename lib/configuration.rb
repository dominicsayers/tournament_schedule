# frozen_string_literal: true

class Configuration
  def clubs
    @clubs ||= begin
      club_data = data['clubs']
      club_data.is_a?(Hash) ? club_data : auto_generate_clubs(club_data)
    end
  end

  def groups
    @groups ||= begin
      clubs.each_with_object({}) do |(club, entrants), a|
        entrants.each do |e|
          group_name, entrant_name = e.is_a?(String) ? ['default', e] : [e['group'], e['name']]

          a[group_name] ||= {
            entrants: {},
            locations: group_data(group_name)['locations'],
            times: group_data(group_name)['times']
          }

          a[group_name][:entrants][entrant_name] = club
        end
      end
    end
  end

  def group_names
    @group_names ||= groups.keys
  end

  def group_data(group_name)
    data.dig('groups', group_name) || {}
  end

  def to_s
    <<~CONFIGURATION
      Groups:

      #{group_names.sort.map { |group_name| Group.new(groups[group_name], group_name) }.join("\n")}
    CONFIGURATION
  end

  private

  attr_reader :data

  def initialize(filename:)
    @data = YAML.load_file(filename)
  end

  GROUPS = ('A'..'Z').to_a

  def auto_generate_clubs(count)
    group_size = count.modulo(6).zero? && !count == 30 ? 6 : 5
    group_count = count / group_size
    data = { 'Auto' => [] }
    Array.new(count) { |index| data["Auto"] << { 'name' => index.to_s, 'group' => GROUPS[index.modulo(group_count)] } }
    data
  end
end
