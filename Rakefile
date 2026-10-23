BOOTSTRAP_SCSS = File.join(Gem::Specification.find_by_name('bootstrap-sass').gem_dir, 'assets/stylesheets')
SASS_ARGS = "--load-path=#{BOOTSTRAP_SCSS} --style=compressed --no-source-map --quiet-deps --silence-deprecation=import scss/app.scss:stylesheets/app.css"

task :update do |t|
  sh "git pull --rebase origin master"
end

task :css do |t|
  sh "bundle exec sass #{SASS_ARGS}"
end

task :css_watch do |t|
  sh "bundle exec sass --watch #{SASS_ARGS}"
end

task :build => [:css] do |t|
  sh "bundle exec jekyll build"
end

task :upload => [:build] do
  sh "aws s3 sync _site/ s3://tildedave-com"
  sh "aws cloudfront create-invalidation --distribution-id E6AU6QQZ1NAOI --paths \"/*\""
end

task :install => [:build] do |t|
  sh "cp -r _site/* /var/www/html"
end

task :run do |t|
  sh "/usr/sbin/apachectl -D FOREGROUND"
end
