# -*- coding: utf-8 -*-
require 'rubygems/platform'

require_relative 'version'

Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "Converts a Mind Map (FreeMind) to multiple formats"
  gem.description = <<-EOF 
Convers a FreeMind mind map to other formats.  For now, it only converts to Taskjuggler.
EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/mm_converter/wiki'
  gem.license = 'GPL'

  gem.add_dependency('mail', '>= 2.4.3')
  gem.add_dependency('term-ansicolor', '>= 1.0.7')
  gem.platform = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 1.9.3'

  # gem.add_dependency('taskjuggler')
  # gem.add_development_dependency('kramdown', [">= 1.0.1"])

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', 'version.rb', 'config.rb', '{lib,test}/**/*.rb', 'test/**/*.csv',
                  'test/**/*.xlsx',
                  '{bin,doc,spec,vendor,target}/**/*', 
                  'README*', 'LICENSE*'] # & `git ls-files -z`.split("\0")

  gem.test_files = Dir['test/*.rb']

  # gem.platform='java'

end
