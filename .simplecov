# frozen_string_literal: true

SimpleCov.start do
  add_filter '/test/'
  add_filter '/lib/cyber_trackr_client/' # Generated code
  add_filter '/scripts/'
  add_filter '/examples/'

  add_group 'Helper', 'lib/cyber_trackr_helper'
  add_group 'RuboCop', 'lib/rubocop'

  track_files 'lib/**/*.rb'
end
