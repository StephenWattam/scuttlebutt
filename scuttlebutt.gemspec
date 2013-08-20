Gem::Specification.new do |s|
  # About the gem
  s.name        = 'Scuttlebutt'
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
                    Dir.glob("lib/**/*.rb") 
  s.require_paths = ['lib']
  
  # Executables
  s.bindir      = 'bin'
  s.executables << 'sb'

  # Documentation
  s.has_rdoc         = false

  # Deps
  s.add_runtime_dependency 'mechanize',          '~> 2.7'
  # s.add_runtime_dependency 'sqlite3',       '~> 1.3'
  # s.add_runtime_dependency 'mysql2',        '~> 0.3'

  # Misc
end


