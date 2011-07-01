class zeroconf::install {

    case $operatingsystem {
        Debian,Ubuntu: {
    		$zeroconfpackages =  ['avahi-daemon'] 
            package { $zeroconfpackages:
                ensure => present,
            }
        }
        CentOS,RedHat: {
    		$zeroconfpackages =  ['avahi'] 
            package { $zeroconfpackages:
                ensure => present,
            }
        }
        default: {
            fail ("zeroconf is not yet implemented on $operatingsystem")
        }
    }
}

class zeroconf::service {

    service { "avahi-daemon":
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => Class["zeroconf::install"],
    }
}

class zeroconf {

    include zeroconf::install
    include zeroconf::service

    File {
        owner   => root,
        group   => root,
        mode    => 0644,
    }

    define config ( $source = '' , $content = '' ) {

        # Debian/Ubuntu/Centos/Redhat are all using the same config file, it's zomg incredible
        $configfile = "/etc/avahi/avahi-daemon.conf"

        if($source != '') and ($content == '' ) {
            file { "$configfile":
                source => $source,
                require => Class["zeroconf::install"],
                notify  => Service["avahi-daemon"],
            }
        } 
        if($content != '') and ($source == '' ) {
            file { "$configfile":
                content => $content,
                require => Class["zeroconf::install"],
                notify  => Service["avahi-daemon"],
            }
        } 
    }

    define service_config ( $source = '' , $content = '' ) {

        # Debian/Ubuntu/Centos/Redhat are all using the same config file, double zomg incredible
        $pathprefix = "/etc/avahi/services"

        if($source != '') and ($content == '' ) {
            file { "$pathprefix/$name.service":
                source => $source,
                require => Class["zeroconf::install"],
                notify  => Service["avahi-daemon"],
            }
        } 
        if($content != '') and ($source == '' ) {
            file { "$pathprefix/$name.service":
                content => $content,
                require => Class["zeroconf::install"],
                notify  => Service["avahi-daemon"],
            }
        } 
    }
}

