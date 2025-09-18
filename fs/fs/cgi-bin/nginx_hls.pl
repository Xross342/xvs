#!/usr/bin/perl
use strict;
use lib '.';
use XFSConfig;
use Crypt::HCE_MD5;

my $hce = Crypt::HCE_MD5->new($c->{dl_key},"XVideoSharing");

my $data;
open FF, "/usr/local/nginx/logs/xvs_hls.txt";

my $hh;
while(<FF>)
{
  my ($h,$sent) = $_=~/^(\w{24,})\|(\d+)$/;

  next unless $sent && $h;

  # skip if sent bytes < 16KB
  next if $sent < 16*1024;

  $hh->{$h}+=$sent;
}

for(keys %$hh)
{
    my $sent = $hh->{$_};
#print"($_)($sent)\n";

    my $l;
    tr|a-z2-7|\0-\37|;
    $_=unpack('B*',$_);
    s/000(.....)/$1/g;
    $l=length;
    $_=substr($_,0,$l & ~7) if $l & 7;
    $_=pack('B*',$_);
    
    my ($srv_id,$disk_id,$file_id,$usr_id,$dx,$id,$dmode,$speed,$i1,$i2,$i3,$i4,$expire,$flags) = unpack("SCLLSA12ASC4LC", $hce->hce_block_decrypt($_) );
  my $ip2 = unpack('N',pack('C4', $i1,$i2,$i3,$i4 ));
  $data.=join('|', $file_id, $usr_id, $dmode, $ip2, $flags, $sent )."\n";
}
close FF;

print $data,"\n";
#exit;

if($data)
{
   require LWP::UserAgent;
   print"Sending stats...\n";
   my $size = length $data;
   my $ua = LWP::UserAgent->new(agent => $c->{user_agent},timeout => 300);
   my $res = $ua->post("$c->{site_cgi}/fs.cgi",
                       {op           => 'stats',
                        dl_key       => $c->{dl_key},
                        data         => $data,
                       }
                      )->content;
   print"Sent($size):$res\n";
}
