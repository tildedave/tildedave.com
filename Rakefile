task :update do |t|
  sh "git pull --rebase origin master"
end

task :build do |t|
  sh "compass compile --force"
  sh "jekyll build"
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
