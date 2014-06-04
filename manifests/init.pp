# Add support for postinstall file and script:
class windows_postinstall(
  $share                = undef,
  $install_command      = undef,
  $upload_file          = undef,
  $upload_recurse       = false,
  $execute_file_command = undef,
) {

  if $::osfamily != 'Windows' {
    fail('This module is only for Windows')
  }

  $exec_provider = powershell
  $vardir  = $::puppet_vardir
  $exec_lck = "${vardir}/postinstall.lck"

  if $share {
    $install_path = $share
  } else {
    $install_path = $::path
  }

  if $install_command {
    exec { install_command: 
      command   => $install_command,
      path      => $install_path,
      creates   => $exec_lck,
      logoutput => true,
      provider  => $exec_provider,
    }
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

    if $upload_recursive {
      $cwd = "${staging}/${file}"
    } else {
      $cwd = $staging
    }
  }

  $path = "${vardir}/staging:${vardir}/staging/${file}:${::path}"

  exec { postinstall:
    command   => "${command} ${arguments}",
    path      => $path,
    cwd       => $cwd,
    creates   => $exec_lck,
    logoutput => true,
    provider  => $exec_provider,
  }

  file { $exec_result:
    ensure  => file,
    require => Exec[$name],
  }
}
