# encoding: utf-8

require "bundler"
require "bundler/gem_tasks"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "redcarpet"
require_relative "spec/rspec_renderer"

def render_markdown(renderer_class, task)
  puts "Rendering file: #{task.name}"
  markdown = Redcarpet::Markdown.new(renderer_class, fenced_code_blocks: true)

  string = markdown.render(File.read(task.prerequisites[0]))
  File.write(task.name, string)
end

renderer = "spec/rspec_renderer.rb"

file "spec/builtins_spec.rb" => ["spec/builtins_spec.md", renderer] do |t|
  render_markdown(RSpecRenderer, t)
end

file "spec/builtins_spec.html" => ["spec/builtins_spec.md", renderer] do |t|
  render_markdown(Redcarpet::Render::HTML, t)
end
desc "Render the specification to HTML locally"
task html: ["spec/builtins_spec.html"]

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)
task spec: ["spec/builtins_spec.rb"]

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop)

task default: [:spec, :rubocop]
