Gem::Specification.new do |s|
  # About the gem
  s.name        = 'scuttlebutt'
  s.version     = '0.0.1a'
  s.date        = '2013-08-20'
  s.summary     = 'Web scraping for linguistic purposes'
  s.description = 'A tool to construct comment corpora from websites'
  s.author      = 'Stephen Wattam'
  s.email       = 'stephenwattam@gmail.com'
  s.homepage    = 'http://stephenwattam.com/projects/Scuttlebutt'
  s.required_ruby_version =  ::Gem::Requirement.new(">= 2.0")
  s.license     = 'CC-BY-NC-SA 3.0' # Creative commons by-nc-sa 3
  
  # Files + Resources
  s.files         = ["LICENSE"] + 
                    Dir.glob("lib/*.rb") +  
                    Dir.glob("lib/**/*.rb") +
                    Dir.glob("scripts/**/*.sbs") 
  s.require_paths = ['lib']
  
  # Executables
  s.bindir      = 'bin'
  s.executables << 'sb'

  # Documentation
  s.has_rdoc         = false

  # Deps
  s.add_runtime_dependency 'selenium-webdriver',          '~> 2.35'
  s.add_runtime_dependency 'pry',                         '~> 0.9'
  # s.add_runtime_dependency 'simplerpc',                   '~> 0.2'

  # Misc
end


