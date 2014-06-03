# Add support for postinstall file and script:
class postinstall(
  $file     = undef,
  $recurse  = false,
  $command,
) {

  case $::osfamily {
    'Windows': {
      $exec_provider = powershell
    }
    default: {
      $exec_provider = undef
    }
  }

  $vardir  = $::puppet_vardir,

  if $file {
    $staging = "${vardir}/staging"
    file { $staging:
      ensure => directory,
      mode   => 755,
    }

    file { "${staging}/${file}":
      source  => "puppet:///modules/postinstall/${file}",
      recurse => $recurse,
      before  => Exec[$name],
    }
  }

  $path = "${vardir}:${vardir}/${file}:${::path}"

  $exec_result = "${::puppet_vardir}/postinstall"

  exec { postinstall:
    command   => $command,
    path      => $path,
    creates   => $exec_result,
    logoutput => true,
    provider  => $exec_provider,
  }

  file { $exec_result:
    ensure  => file,
    require => Exec[$name],
  }
}
