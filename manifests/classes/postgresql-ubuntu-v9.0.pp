/*

==Class: postgresql::ubuntu::v9-0

Parameters:
 $postgresql_data_dir:
    set the data directory path, which is used to store all the databases

Requires:
 - Class["apt::preferences"]
 - A Class["apt::ppa"] defining the launchpad ppa ppa:pitti/postgresql

Ubuntu Lucid, Maverick and Natty required a backported PostgreSQL 9.0,
available from Martin Pitt''s PPA:
https://launchpad.net/~pitti/+archive/postgresql

*/
class postgresql::ubuntu::v9-0 {

  $version = "9.0"

  case $lsbdistcodename {
    "lucid", "maverick", "natty": {

      include postgresql::debian::base

      service {"postgresql":
        ensure    => running,
        enable    => true,
        hasstatus => true,
        start     => "/etc/init.d/postgresql start ${version}",
        status    => "/etc/init.d/postgresql status ${version}",
        stop      => "/etc/init.d/postgresql stop ${version}",
        restart   => "/etc/init.d/postgresql restart ${version}",
        require   => Package["postgresql-common"],
      }

      apt::preferences {[
        "libpq-dev",
        "libpq5",
        "postgresql-${version}",
        "postgresql-client-${version}",
        "postgresql-common", 
        "postgresql-client-common",
        "postgresql-contrib-${version}"
        ]:
        pin      => "release a=${lsbdistcodename},o=LP-PPA-pitti-postgresql",
        priority => "1100",
        before   => Package[
          "libpq-dev",
          "libpq5",
          "postgresql-client-${version}",
          "postgresql-common",
          "postgresql-client-common",
          "postgresql-contrib-${version}"
        ],
        require => Apt::Ppa["pitti/postgresql"]
      }
    }

    default: {
      fail "${name} not available for ${operatingsystem}/${lsbdistcodename}"
    }
  }
}
