#!/usr/bin/perl
use strict;
use lib '.';
use XFSConfig;

my $data;
open FF, "/usr/local/nginx/logs/xvs_mp4.txt";
while(<FF>)
{
  # file_id, usr_id, mode, ip, bytes_sent, out_code
  my @d = split(/\|/);

  # skip if invalid file_id,usr_id
  next unless $d[0]=~/^\d+$/ && $d[1]=~/^\d+$/;

  # skip if limit error
  next if $d[$#d] =~/^503/;

  # skip if sent bytes < 16KB
  next if $d[5] < 16*1024;

  # pack IP
  $d[3] = unpack('N',pack('C4', split('\.',$d[3]) ));

  # remove status code
  pop(@d);

  $data.=join('|',@d)."\n";
}
close FF;

print $data,"\n";

if($data)
{
   require LWP::UserAgent;
   print"Sending stats...\n";
   my $size = length $data;
   my $ua = LWP::UserAgent->new(agent => $c->{user_agent},timeout => 180);
   my $res = $ua->post("$c->{site_cgi}/logs.cgi",
                       {op           => 'stats',
                        dl_key       => $c->{dl_key},
                        data         => $data,
                       }
                      )->content;
   print"Sent($size):$res\n";
}
