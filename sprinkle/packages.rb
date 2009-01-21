package :build_essential do
  description 'Build tools'
  apt 'build-essential' do
    pre :install, 'apt-get update'
    pre :install, 'apt-get dist-upgrade'
  end
end

package :wget do
  description 'wget, used for downloading source'
  apt 'wget'
end

package :mysql do
  description 'MySQL Database'
  apt %w( mysql-server mysql-client libmysqlclient15-dev )
end

package :mysql_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql'
end

package :sqlite3 do
  description 'Sqlite3 Database'
  version '3.6.6.2'
  source "http://www.sqlite.org/sqlite-#{version}.tar.gz"
end

package :ruby do
  description 'Ruby Virtual Machine'
  version '1.8.6'
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}-p111.tar.gz"
  requires :ruby_dependencies
end

package :ruby_dependencies do
  description 'Ruby Virtual Machine Build Dependencies'
  apt %w( bison zlib1g-dev libssl-dev libreadline5-dev libncurses5-dev file )
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.3.1'
  source "http://rubyforge.org/frs/download.php/45905/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
end

package :rails do
  description 'Ruby on Rails'
  gem 'rails'
  version '2.2.2'
end

package :merb do
  description 'Merb'
  gem 'merb'
  version '1.0.7'
end

package :apache do
  description 'Apache 2 HTTP Server'
  apt %w( apache2-mpm-prefork apache2-prefork-dev )
  post :install, 'install -m 755 support/apachectl /etc/init.d/apache2', 'update-rc.d -f apache2 defaults'
  requires :apache_dependencies
end

package :apache_dependencies do
  description 'Apache 2 HTTP Server Build Dependencies'
  apt %w( openssl libtool mawk zlib1g-dev libssl-dev )
end

package :passenger do
  description 'Passenger'
  gem 'passenger'
  version '2.0.5'
end

package :git, :providers => :scm do
  description 'Git Distributed Version Control'
  apt 'git-core'
end