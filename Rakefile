SASS_ARGS = "--style=compressed --no-source-map scss/app.scss:stylesheets/app.css"

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
