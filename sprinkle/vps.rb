require File.join(File.dirname(__FILE__), "packages")

policy :base, :roles => :app do
  requires :build_essential
  requires :wget
  requires :mysql
  requires :sqlite3
  requires :ruby
  requires :rubygems
  requires :rails
  requires :merb
  requires :apache
  requires :passenger
  requires :git
end

deployment do
  delivery :capistrano do
    recipes "deploy"
  end
  
  source do
    prefix "/usr/local"
    archives "/usr/local/sources"
    builds "/usr/local/build"
  end
end