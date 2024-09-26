Gem::Specification.new do |spec|
  spec.name          = 'awtrix_control'
  spec.version       = '0.0.2'
  spec.required_ruby_version = '>= 3.3'
  spec.authors       = ['Francois Gaspard']
  spec.email         = ['fr@ncois.email']
  spec.summary       = 'Control AWTRIX 3 devices'
  spec.description   = 'A gem to control AWTRIX 3 devices from Ruby'
  spec.homepage      = 'https://github.com/Francois-gaspard/awtrix'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.0'
end
