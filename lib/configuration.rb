# frozen_string_literal: true

class Configuration
  def clubs
    @clubs ||= data['clubs']
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
end
