source 'https://rubygems.org'
ruby '2.4.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'derailed_benchmarks', group: :development
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.5'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# Using pundit for scoping properties
gem "pundit"
# Using sidekiq to handle job queues
gem 'sidekiq'
gem 'sidekiq-failures', '~> 1.0'

# Using fuzzy match, amatch, ruby ngrams and pg_search for deduplication and matching
gem 'fuzzy_match', '~> 2.1'
gem 'amatch', '~> 0.3.0'
gem 'ruby_ngrams', '~> 0.0.6'
gem 'pg_search'

# Geocoding listings with google geocoder gem
gem "geocoder"

# Using Figaro for secrets
gem 'figaro'

# Using user Devise for authentification
gem 'devise'

# Using Forest for back office
gem 'forest_liana'

# Mailing
gem "letter_opener", group: :development
gem 'postmark-rails'

group :development, :test do
  gem 'pry-byebug'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
