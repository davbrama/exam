# Class: exam
# ===========================
#
# Full description of class exam here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'exam':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class exam {
  include apache
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::proxy_balancer
  
  apache::balancer { 'hw':
    proxy_set => { 'stickysession' => 'JSESSIONID' },
  }
  
  apache::balancermember { "exam.example.com":
    balancer_cluster	=> 'hw',
    url			=> "http://exam.example.com:8080/sample",
  }

  $proxy_pass = [
    { 'path' => '/', 'url' => 'balancer://hw/' },
    { 'path' => '/*', 'url' => 'balancer://hw' },
  ]
 
  apache::vhost {'exam.example.com hw host':
    servername => 'exam.example.com',
    port => 80,
    docroot => '/var/www',
    log_level	=> 'debug',
    proxy_pass => $proxy_pass,
  }

  class { 'java': }

  file { 'apps_dir':
    ensure	=> directory,
    path	=> '/opt/tomcat/apps_available',
    owner	=> 'tomcat',
  }

  file { 'tomcat_sample':
    ensure	=> file,
    path	=> '/opt/tomcat/apps_available/sample.war',
    owner	=> 'tomcat',
    source	=> 'puppet:///modules/exam/sample.war',
  }

  tomcat::install { '/opt/tomcat':
    source_url	=> 'http://apache.spd.co.il/tomcat/tomcat-9/v9.0.0.M26/bin/apache-tomcat-9.0.0.M26.tar.gz',
  }

  tomcat::instance { 'default':
    catalina_home	=> '/opt/tomcat',
    catalina_base	=> '/opt/tomcat',
  }

  tomcat::war { 'sample.war':
    catalina_base	=> '/opt/tomcat',
    war_source		=> '/opt/tomcat/apps_available/sample.war',
  }


}
