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
    group_size, group_count = begin
      if count.modulo(10).zero?
        [5, count / 5]
      elsif count > 36
        [6, 7]
      elsif count >= 30
        [5, 6]
      elsif count >= 24
        [4, 6]
      elsif count > 20
        [4, 5]
      elsif count >= 16
        [4, 4]
      elsif count >= 12
        [4, 3]
      else
        [6, 2]
      end
    end

    # s = count.modulo(6).zero? ? 6 : 5
    # [count / s, s]

    data = { 'Auto' => [] }
    Array.new(count) { |index| data["Auto"] << { 'name' => index.to_s, 'group' => GROUPS[index.modulo(group_count)] } }
    data
  end
end
