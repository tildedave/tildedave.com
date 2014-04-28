task :update do |t|
  sh "git pull --rebase origin master"
end

task :build do |t|
  sh "compass compile --force"
  sh "jekyll build"
end

task :install => [:build] do |t|
  sh "cp -r _site/* /var/www/html"
end
