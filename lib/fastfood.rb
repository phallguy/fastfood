require 'pry'
module Fastfood
  module_function

  def fastfood_tasks_path
    @fastfood_tasks_path ||= File.expand_path( "../capistrano/tasks", __FILE__ )
  end

  def load_task( path )
    load_task_from_file File.join( fastfood_tasks_path, path )
  end

  def load_tasks( path )
    Dir[ File.join( fastfood_tasks_path, path ) ].each do |file|
      load_task_from_file file
    end
  end

  def load_task_from_file( file )
    file = "#{file}.rake" unless file =~ /\.rake$/i
    load file
  end

  # Finds versions of the given file looking in the project folder and default
  # fast food folders.
  def find_files( path )
    file_paths.each_with_object([]) do |search_path,obj|
      found = File.join( search_path, path )
      obj << found if File.exist? found
    end.reverse.uniq
  end

  # Finds versions of the given file looking in the project folder and default
  # fast food folders.
  def find_file( path )
    find_files( path ).first
  end

  # @return [Array<String>] paths to search when looking for templates and repo
  #   data.
  @file_paths = [
    File.expand_path("..",ENV["BUNDLE_GEMFILE"]),
    File.expand_path( "../..", __FILE__ ),
  ]
  def file_paths; @file_paths end

end

require 'fastfood/version'
require 'fastfood/dsl'
require 'fastfood/franchises'
require 'fastfood/services'
