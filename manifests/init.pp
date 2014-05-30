# Add support for postinstall file and script:
class postinstall(
  $command,
  $mod_name = 'postinstall',
  $file     = undef,
  $recurse  = false,
  $path     = $::path,
  $vardir   = $::puppet_vardir,
) {

  case $::osfamily {
    'Windows': {
      $exec_provider = powershell
    }
    default: {
      $exec_provider = undef
    }
  }

  if $file {
    staging::file { $name:
      source  => "puppet:///modules/${mod_name}/${file}",
      # TODO: add recurse,
      # recurse => $recurse,
      before  => Exec[$name],
    }
  }

  $exec_result = "${::puppet_vardir}/${name}"

  exec { $name:
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
