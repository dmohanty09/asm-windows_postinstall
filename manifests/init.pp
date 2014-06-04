# Add support for postinstall file and script:
class windows_postinstall(
  $windows_share = undef,
  $file          = undef,
  $recurse       = false,
  $command,
  $arguments     = undef,
) {

  if $::osfamily != 'Windows' {
    fail('This module is only for Windows')
  }

  $exec_provider = powershell
  $vardir  = $::puppet_vardir

  if $windows_share {
    $path = $windows_share
  } else {
    $path = $::path
    $path = "${vardir}/staging:${vardir}/staging/${file}:${::path}"
  }

  if $file {
    $staging = "${vardir}/staging"
    file { $staging:
      ensure => directory,
      mode   => 755,
    }

    file { "${staging}/${file}":
      source  => "puppet:///modules/windows_postinstall/${file}",
      recurse => $recurse,
      before  => Exec[postinstall],
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
