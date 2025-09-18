#!/usr/bin/perl
use strict;
use lib '.';
use XFileConfig;
use Session;
use CGI::Carp qw(fatalsToBrowser);

my $ses = Session->new();
my $f = $ses->f;
my $db= $ses->db;
sendBack("111") if $ENV && $ENV{REQUEST_METHOD} ne 'POST';
sendBack("222") if $f->{dl_key} ne $c->{dl_key};

sub sendBack
{
	print"Content-type:text/html\n\n".shift;
	exit;
}
sub logg
{
	my $msg = shift;
	return unless $c->{fs_logs_on};
	open(FILE,">>logs/fs.log")||return;
	print FILE "$msg\n";
	close FILE;
}

$|++;
print"Content-type:text/html\n\n";
my ($bandwidth_sum,$views_sum,$downloads_sum,$views_adb_sum,$money_sum,$iphash,$bwhash);

my $list = $db->SelectARefCached("SELECT DISTINCT host_ip FROM Hosts");
my $srvip;
$srvip->{$_->{host_ip}}=1 for @$list;

my $gi;

for(split(/\n/,$f->{data}))
{
	$_=~s/[\n\r]+//g;
	#logg($_);
	my ($file_real,$file_id,$mode,$ip,$bandwidth,$ip2);

	( $file_id, $file_real, $mode, $ip2, $bandwidth ) = split(/\|/,$_);
	$ip = unpack('N',pack('C4', split('\.',$ip2) ));

	next unless $ip;

	next if $srvip->{$ip2};
	#my ($flag_dl,$flag_embed) = ( $flags & 1, $flags & 2 );
	#logg("FLAGS: dl:$flag_dl embed:$flag_embed");

	$bandwidth_sum+=$bandwidth;
	$iphash->{$ip}->{traffic}+=$bandwidth;

	#next if $c->{views_tracking_mode2} && $flags != 128;

	next if $mode eq 'p';

	my $file=$db->SelectRowCached("SELECT *
									FROM Files f, Users u
									WHERE f.file_id=?
									AND f.usr_id=u.usr_id",$file_id);

	next unless $file;
	next if $file_real && $file->{file_real} ne $file_real; # file_id to not match file_real, fake
	$bwhash->{$file->{file_id}} += $bandwidth;

	my $view = $db->SelectRow("SELECT * FROM Views WHERE file_id=? AND ip=?", $file->{file_id}, $ip );

  unless($view)
  {
      next;
      #logg("No View record. Creating.");
      # $db->Exec("INSERT INTO Views 
      #            SET file_id=?, 
      #                usr_id=?, 
      #                owner_id=?,
      #                ip=?",
      #                $file->{file_id},
      #                0,
      #                $file->{usr_id}||0,
      #                $ip
      #          );
      # $view = $db->SelectRow("SELECT * FROM Views WHERE ip=? AND file_id=?",$ip,$file->{file_id});
  }

  $view->{size} += $bandwidth;
  

  my $video_size = $file->{"file_size_$mode"}||1;
  my $watched = int( $file->{file_length} * $bandwidth/$video_size ) if $video_size;
  
  $view->{watch_sec} += $watched;
  logg("Mode:$mode Downloaded:$bandwidth of $video_size Watched now: $watched Total watched:$view->{watch_sec} of $file->{file_length}");

  #if( $view->{size} >= $video_size*$c->{track_views_percent}/100 && !$view->{finished})
  if( $view->{watch_sec} >= $file->{file_length}*$c->{track_views_percent}/100 && !$view->{finished})
  {
      my ($length_id,$money);
      #my $secs = $file->{file_length} * $view->{size}/$video_size;
      my @ss = split(/\|/,$c->{tier_sizes});
      if($c->{tier_factor} eq 'size')
      {
          for(0..9){$length_id=$_ if defined $ss[$_] && $video_size>=$ss[$_]*1024*1024;}
      }
      else
      {
          for(0..9){$length_id=$_ if defined $ss[$_] && $file->{file_length}>=$ss[$_]*60;}
      }
      logg("Complete! LengthID:$length_id");

      next unless $view->{country} || -e "$c->{cgi_path}/GeoLite2-Country.mmdb";
      unless($view->{country})
      {
      	require Geo::IP2;
			$gi ||= Geo::IP2->new("$c->{cgi_path}/GeoLite2-Country.mmdb");
			$view->{country} = $gi->country_code_by_addr($ip2);
      }
      
      my $country = $view->{country} || 'YY';
      my $money_code=0;
      if($c->{views_profit_on} && defined $length_id)
      {
		my $tier_money = $c->{tier5_money};
		if   ($c->{tier1_countries} && $country=~/^($c->{tier1_countries})$/i){ $tier_money = $c->{tier1_money}; }
		elsif($c->{tier2_countries} && $country=~/^($c->{tier2_countries})$/i){ $tier_money = $c->{tier2_money}; }
		elsif($c->{tier3_countries} && $country=~/^($c->{tier3_countries})$/i){ $tier_money = $c->{tier3_money}; }
		elsif($c->{tier4_countries} && $country=~/^($c->{tier4_countries})$/i){ $tier_money = $c->{tier4_money}; }
		my @mm = split(/\|/,$tier_money);
		$money = $mm[$length_id||0];
      	logg("m1"),$money=0 if $money>0 && $c->{max_money_last24} && $db->SelectOne("SELECT money FROM StatsIP WHERE day=CURDATE() AND ip=?",$ip)+$iphash->{$ip}->{money} >= $c->{max_money_last24};
		logg("m2"),$money=0 if $money>0 && $c->{max_money_x_limit} && $c->{max_money_x_days} && $db->SelectOne("SELECT money FROM StatsIP WHERE day>=CURDATE()-INTERVAL ? DAY AND ip=?",$c->{max_money_x_days},$ip)+$iphash->{$ip}->{money} >= $c->{max_money_x_limit};
		logg("m3"),$money=0 if $money>0 && $c->{max_complete_views_daily} && $db->SelectOne("SELECT views FROM StatsIP WHERE day=CURDATE() AND ip=?",$ip)+$iphash->{$ip}->{view} >= $c->{max_complete_views_daily};
		logg("m4"),$money=0 if $money>0 && $file->{file_ip} eq $ip;
		logg("m5"),$money=0 if $money>0 && $view->{adb} && $c->{adb_no_money};
		logg("m6"),$money=0 if $money>0 && $view->{premium} && $c->{premium_no_money};
        logg("m7"),$money=0 if $money>0 && $c->{no_referer_no_money} && !$view->{referer};
        $money = $money * $c->{embeds_money_percent}/100 if $view->{embed};
        $money = $money * $c->{downloads_money_percent}/100 if $view->{download};
		if($money>0 && $c->{m_7} && ($c->{m_7_money_noserver}||$c->{m_7_money_noproxy}||$c->{m_7_money_notor}))
		{
	   		require XUtils;
	   		my $is_server = XUtils::getIPBlockedStatus( $db, 'ipserver',$ip2 ) if $c->{m_7_money_noserver};
	   		my $is_proxy  = XUtils::getIPBlockedStatus( $db, 'ipproxy', $ip2 ) if $c->{m_7_money_noproxy} && !$is_server;
	   		my $is_tor    = XUtils::getIPBlockedStatus( $db, 'iptor',	$ip2 ) if $c->{m_7_money_notor} && !$is_server && !$is_proxy;
	   		my $is_black  = XUtils::getIPBlockedStatus( $db, 'ipblack',	$ip2 ) if !$is_server && !$is_proxy && !$is_tor;
	   		#$is_server=1;$money||=3;
	   		if( $is_server || $is_proxy || $is_tor || $is_black )
	   		{
	   			#logg("xxx: $ip2 : $is_server , $is_proxy , $is_tor = $c->{m_7_money_percent} ($money)");
	   			my $is_white = XUtils::getIPBlockedStatus( $db, 'ipwhite', $ip2 );
	   			unless($is_white)
	   			{
	   				my $money_saved = 100000*sprintf("%.05f", $money*(100-$c->{m_7_money_percent})/100 / ($c->{tier_views_number}||1000) ) if $c->{m_7_stats};
	   				$money*=$c->{m_7_money_percent}/100;
	   				$db->Exec("INSERT INTO StatsMisc
				              SET usr_id=0, day=CURDATE(), name='ipblock_money_saved', value=?
				              ON DUPLICATE KEY 
				              UPDATE value=value+?",$money_saved,$money_saved) if $c->{m_7_stats} && $money_saved>0;
	   			}
	   		}
	   	}
		if($money>0 && $c->{alt_ads_mode})
		{
			my $amode = $db->SelectOne("SELECT value FROM UserData WHERE usr_id=? AND name='usr_ads_mode'",$file->{usr_id})||0;
			$money*=$c->{"alt_ads_percent$amode"}/100;
		}
      }

      $money = sprintf("%.05f",$money / ($c->{tier_views_number}||1000) );
      logg("IP=$ip2 Country=$country Money=$money Size=$view->{size}");
      
      $iphash->{$ip}->{money}+=$money;
      my $viewok=1;

      if($c->{m_c} && $money>0)
      {
          my $shave;
          if($c->{m_c_views_rate2} && $file->{file_views}>$c->{m_c_views_num2})
          {
              $shave=1 if int(rand(100)) < $c->{m_c_views_rate2};
          }
          elsif($c->{m_c_views_rate1} && $file->{file_views}>$c->{m_c_views_num1})
          {
              $shave=1 if int(rand(100)) < $c->{m_c_views_rate1};
          }
          if($shave)
          {
              logg("Money shaved out: \$$money from usr_id=$file->{usr_id}. Views=$file->{file_views}");
              $db->Exec("INSERT INTO TmpUsers
                         SET usr_id=?, money=?
                 	     ON DUPLICATE KEY UPDATE money=money+?
                        ",$c->{m_c_views_user},$money,$money) if $c->{m_c_views_user};
              $money=0;
              $viewok=0 if $c->{m_c_views_skip};
          }
      }
      
      #$views_sum++;
      $money_sum+=$money;

      my ($views,$views_prem)= $view->{premium} ? (0,$viewok) : ($viewok,0);
      my $views_adb = $view->{adb} && $c->{adb_no_money} ? $viewok : 0;
      my $downloads=0;

      if($view->{download}){
      	$downloads_sum++;
      	$views=$views_prem=$views_adb=0;
      	$downloads=1;
      } elsif($view->{adb}){
      	$views_adb_sum++;
      } else {
      	$views_sum++;
      }

      $db->Exec("UPDATE Views 
                 SET size=?,
                 	 watch_sec=?,
                     finished=1,
                     money=?
                 WHERE file_id=? 
                 AND   ip=?
                    LIMIT 1",
                 $view->{size},
                 $view->{watch_sec},
                 $money,
                 $view->{file_id},
                 $view->{ip},
                 );

      $db->Exec("INSERT INTO TmpFiles
                 SET file_id=?, views_full=?, money=?, downloads=?
                 ON DUPLICATE KEY UPDATE views_full=views_full+?, money=money+?, downloads=downloads+?
                ", $file->{file_id}, $viewok,$money,$downloads, $viewok,$money,$downloads );

      $db->Exec("INSERT INTO TmpUsers
                 SET usr_id=?, money=?
                 ON DUPLICATE KEY UPDATE money=money+?
                ",$file->{usr_id},$money,$money) if $file->{usr_id} && $money>0;

      

      $iphash->{$ip}->{view}+=$viewok;

      $db->Exec("INSERT INTO TmpStats2
                 SET usr_id=?,
                     views=$views,
                     views_prem=$views_prem,
                     views_adb=$views_adb,
                     downloads=$downloads,
                     profit_views=?
                 ON DUPLICATE KEY UPDATE
                     views=views+$views,
                     views_prem=views_prem+$views_prem,
                     views_adb=views_adb+$views_adb,
                     downloads=downloads+$downloads,
                     profit_views=profit_views+?
                ",$file->{usr_id},$money,$money) if $file->{usr_id};

      if($file->{usr_id} && $c->{referral_aff_percent} && $money)
      {
         my $aff_id = $db->SelectOne("SELECT usr_aff_id FROM Users WHERE usr_id=?",$file->{usr_id});
         my $money_ref = sprintf("%.05f",$money*$c->{referral_aff_percent}/100);
         if($aff_id && $money_ref>0)
         {
            logg("Aff2 usr_id:$aff_id Money2:$money_ref");
            $money_sum+=$money_ref;
            $db->Exec("INSERT INTO TmpUsers
                 SET usr_id=?, money=?
                 ON DUPLICATE KEY UPDATE money=money+?
                ", $aff_id, $money_ref, $money_ref );

              $db->Exec("INSERT INTO TmpStats2
                 SET usr_id=?,
                     profit_refs=?
                 ON DUPLICATE KEY UPDATE
                     profit_refs=profit_refs+?
                ", $aff_id, $money_ref, $money_ref );
         }
      }

      if($viewok && $country)
      {
           $db->Exec("INSERT INTO StatsCountry
                 SET usr_id=?,
                     day=CURDATE(),
                     country=?,
                     views=1,
                     money=?
                 ON DUPLICATE KEY UPDATE
                     views=views+1,
                     money=money+?
                ",$file->{usr_id},$country,$money,$money);
      }
      
  } # end of if-finished
  else
  {
    $db->Exec("UPDATE Views 
    			SET size=?, watch_sec=? 
    			WHERE file_id=? AND ip=?",
    			$view->{size},
    			$view->{watch_sec},
    			$view->{file_id},
    			$view->{ip});
  }

}

$views_sum||=0;
$downloads_sum||=0;
$views_adb_sum||=0;
$money_sum||=0;
logg("SUM: bandwidth=$bandwidth_sum, views=$views_sum, views_adb=$views_adb_sum, downloads_sum=$downloads_sum");
$db->Exec("INSERT INTO Stats
          SET day=CURDATE(), 
          	bandwidth=$bandwidth_sum, 
          	views=$views_sum, 
          	views_adb=$views_adb_sum, 
          	downloads=$downloads_sum, 
          	profit=$money_sum
          ON DUPLICATE KEY 
          UPDATE 
          bandwidth=bandwidth+$bandwidth_sum, 
          views=views+$views_sum, 
          views_adb=views_adb+$views_adb_sum, 
          downloads=downloads+$downloads_sum, 
          profit=profit+$money_sum") if $bandwidth_sum;

for(keys %$iphash)
{
  my $tt = sprintf("%.0f",$iphash->{$_}->{traffic}/1048576)||0;
  my $mm = $iphash->{$_}->{money}||0;
  my $vv = $iphash->{$_}->{view}||0;
  $db->Exec("INSERT INTO StatsIP
             SET day=CURDATE(), ip=?, traffic=$tt, money=$mm, views=$vv
             ON DUPLICATE KEY 
             UPDATE traffic=traffic+$tt, money=money+$mm, views=views+$vv",$_) if $tt>0 || $mm>0;
}

for(keys %$bwhash)
{
  $db->Exec("INSERT INTO TmpFiles
             SET file_id=?, bandwidth=?
             ON DUPLICATE KEY UPDATE bandwidth=bandwidth+?
            ",$_, int($bwhash->{$_}/1024), int($bwhash->{$_}/1024) );
}

if($c->{m_r} && $f->{host_id})
{
		$db->Exec("UPDATE Hosts SET host_cache_rate=? WHERE host_id=?",$f->{cache_rate},$f->{host_id});
}

print"OK";