param ($ports = (8000, 9000, 3000), $listenaddress = '0.0.0.0', $connectaddress, [switch]$show, [switch]$reset, [switch]$help)

# #[Ports]
# #All the ports you want to forward separated by coma
# $ports=@(8081, 3333);

if ( $help ) {
  write-host "Parameters:"
  write-host "show => show all portproxys configured."
  write-host "reset => reset all portproxys configured."
  write-host "ports (-ports 8000,9000,3000)"
  write-host "listenaddress (-listenaddress 127.0.0.1)"
  write-host "connectaddress (-connectaddress 127.0.0.1)"
  exit;
}

if ( $show ) {
  netsh interface portproxy show all
  exit;
}

if ( $reset ) {
  netsh interface portproxy reset
  exit;
}

$remoteaddreess = bash.exe -c "ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"
$found = $remoteaddreess -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if ( $found ) {
  $remoteaddreess = $matches[0];
}
else {
  write-host "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

if ( $connectaddress ) {
  $remoteaddreess = $connectaddress
}

for ( $i = 0; $i -lt $ports.length; $i++ ) {
  $port = $ports[$i];
  Invoke-Expression "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$listenaddress";
  Invoke-Expression "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$listenaddress connectport=$port connectaddress=$remoteaddreess";
  write-host "Port $port configured: `nListen address: $listenaddress`nConnect address: $remoteaddreess"
}

# write-host "====================================================="
netsh interface portproxy show all
