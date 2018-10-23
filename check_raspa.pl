#!/usr/bin/env perl


my ($sec,$min,$hour,$mday,$curMonth,$curYear,$wday,$yday,$isdst)=localtime();
$curYear += 1900;
$curMonth += 1;
$curMonth > 9 or $curMonth = "0".$curMonth;
$mday > 9 or $mday = '0'.$mday;
$min > 9 or $min = '0'.$min;
$hour > 9 or $hour = '0'.$hour;
$sec > 9 or $sec = '0'.$sec;

my $timestamp = $curYear."/".$curMonth."/".$mday." ".$hour.":".$min.":".$sec;

my $NUMBER_OF_PINGS=5;

print "$timestamp\t";

my $iwconfig = checkIwconfig();
print "$iwconfig->{essid}\t$iwconfig->{bitRate}\t$iwconfig->{txPower}\t$iwconfig->{linkQuality}\t$iwconfig->{signalLevel}\t";

print checkPing("www.google.com")."\t";
print checkPing("192.168.1.1")."\t";
print checkPing("192.168.1.11")."\t";
print checkSSH("localhost","22")."\t";
print checkHTTP("localhost","8081")."\t";
print getVoltage()."\t";
print getTemperature()."\t";
print "\n";

exit(0);

###############################################################################################

sub checkPing {
  my $host = shift;
  my $statusOutput = `ping -q -c $NUMBER_OF_PINGS $host`;
  my $avgPing;
  foreach my $line (split('\n',$statusOutput)) {
    ($avgPing) = $line =~ /rtt min.+ = [\d\.]+\/([\d\.]+)\/.+/ if ($line =~ /rtt min/);
  }
  return $avgPing;
}

sub checkIwconfig {
  my $statusOutput = `/sbin/iwconfig wlan0`;
  $statusOutput =~ s/  +/\n/g;
  my $data;
  foreach my $line (split('\n',$statusOutput)) {
    ($data->{essid}) = $line =~/ESSID:"(\w+?)"/ if ($line =~/ESSID/);
    ($data->{bitRate}) = $line =~/Bit Rate[=:](.+)/ if ($line =~/Bit Rate/);
    ($data->{txPower}) = $line =~ /Tx-Power=(.+)/ if ($line =~/Tx-Power/);
    ($data->{linkQuality}) = $line =~/Link Quality=(.+)/ if ($line =~/Link Quality/);
    ($data->{signalLevel}) = $line =~/Signal level=(.+)/ if ($line =~/Signal level/);
  }
  return $data;
}

sub checkSSH {
  my $host = shift;
  my $port = shift;
  my $output = `ssh -p$port $host 'echo 1'`;
  return 1 if ($output =~ /1/);
  return 0;
}

sub checkHTTP {
  my $host = shift;
  my $port = shift;
  my $output = `curl -s -I http://$host:$port`;
  return 1 if ($output =~ /200 OK/);
  return 0;
}

sub getVoltage {
  my $voltsCore = `vcgencmd measure_volts core`;
  ($voltsCore) = $voltsCore =~ /=(.+)/;
  return $voltsCore;
}

sub getTemperature {
  my $coretemp = `vcgencmd measure_temp`;
  ($coretemp) = $coretemp =~ /=(.+)/;
  return $coretemp;
}
