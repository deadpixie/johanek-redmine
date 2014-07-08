# Class redmine::install
class redmine::install {

  Exec {
    cwd  => '/usr/src',
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ]
  }
  
  # Install dependencies
  
  $generic_packages = [ 'wget', 'tar', 'make', 'gcc' ]
  $debian_packages = [ 'libmysql++-dev', 'libmysqlclient-dev', 'libmagickcore-dev', 'libmagickwand-dev' ]
  $redhat_packages = [ 'mysql-devel', 'postgresql-devel', 'sqlite-devel', 'ImageMagick-devel' ]

  case $::osfamily {
    'Debian':   { $packages = concat($generic_packages, $debian_packages) }
    default:    { $packages = concat($generic_packages, $redhat_packages) }
  }
  
  ensure_packages($packages)
  
  package { 'bundler':
    ensure    => present,
    provider  => gem
  } ->
  
  # Install redmine from source

  exec { 'redmine_source':
    command => "wget ${redmine::params::download_url}",
    creates => "/usr/src/redmine-${redmine::version}.tar.gz",
    require => Package['wget'],
    timeout => 0,
  } ->

  exec { 'extract_redmine':
    command => "/bin/tar xvzf redmine-${redmine::version}.tar.gz",
    creates => "/usr/src/redmine-${redmine::version}",
    require => Package['tar'],
     timeout => 0,
  } ->

  exec { 'bundle_redmine':
    command => "bundle install --gemfile /usr/src/redmine-${redmine::version}/Gemfile --without development test sqlite && touch .bundle_done",
    creates => "/usr/src/redmine-${redmine::version}/.bundle_done",
    require => [ Package['bundler'], Package['make'], Package['gcc'] ],
    timeout => 0,
  }
}
