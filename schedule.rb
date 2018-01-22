# frozen_string_literal: true

require_relative 'lib/tournament'
Tournament.new(filename: 'data/multigroup.yml').schedule
