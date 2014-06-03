# Add support for postinstall file and script:
class postinstall(
  $windows_share = undef,
  $file          = undef,
  $recurse       = false,
  $command,
  $arguments     = undef,
) {

  case $::osfamily {
    'Windows': {
      $exec_provider = powershell
      if $windows_share {
        $path = $windows_share
      } else {
        $path = $::path
      }
    }
    default: {
      $exec_provider = undef
      $path = "${vardir}/staging:${vardir}/staging/${file}:${::path}"
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

  $exec_result = "${::puppet_vardir}/postinstall"

  exec { postinstall:
    command   => "${command} ${arguments}",
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
