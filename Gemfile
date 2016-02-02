source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'rake', '~> 10.4.0',      :require => false
end

group :development do
  gem 'puppet-syntax',     :require => false
  gem 'puppet-blacksmith', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '~> 3.7.0', :require => false
end
