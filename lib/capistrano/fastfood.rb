require 'fastfood'
require 'fastfood/dsl'

include Fastfood::DSL

# Automatically load all core tasks
Fastfood.load_tasks "core/**/*.rake"