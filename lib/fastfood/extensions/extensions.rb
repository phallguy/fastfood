# Helpful extensions to ruby and capistrano classes.
module Fastfood::Extensions
  autoload :DirtyTrackingHash, "fastfood/extensions/dirty_tracking_hash"
end

require 'fastfood/extensions/server'