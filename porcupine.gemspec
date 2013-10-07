# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "porcupine"
  spec.version       = "0.2.0"
  spec.authors       = ["Mike Ragalie"]
  spec.email         = ["ragalie@gmail.com"]
  spec.summary       = "JRuby wrapper for Hystrix"
  spec.homepage      = "https://github.com/ragalie/porcupine"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.requirements << "jar 'com.netflix.hystrix:hystrix-core', '1.3.5'"
  spec.requirements << "jar 'org.slf4j:slf4j-simple', '1.7.5'"

  spec.add_dependency "jbundler"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.0"
end
