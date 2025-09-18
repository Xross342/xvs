#!/usr/bin/perl
use strict;
use lib '.';
use warnings;
use XFileConfig;
use diagnostics;

BEGIN {
	my $ok	  = "<b style='background:#1a1;color:#fff;padding:2px;'>OK</b>";
	my $err	 = "<b>Fail</b>";
	my @modules =
	(                                                   
		{module=>'CGI', file=>'CGI.pm', redhat=>'perl-CGI', debian=>'libcgi-pm-perl'}, 
		{module=>'DBI', file=>'DBI.pm', redhat=>'perl-DBI', debian=>'libdbi-perl'}, 
		{module=>'DBD::mysql', file=>'DBD/mysql.pm', redhat=>'perl-DBD-MySQL', debian=>'libdbd-mysql-perl'}, 
		{module=>'Digest::SHA', file=>'Digest/SHA.pm', redhat=>'perl-Digest-SHA', debian=>'libdigest-sha-perl'},
		{module=>'LWP', file=>'LWP/UserAgent.pm', redhat=>'perl-libwww-perl', debian=>'libwww-perl'},
		{module=>'LWP::Protocol::https', file=>'LWP/Protocol/https.pm', redhat=>'perl-LWP-Protocol-https', debian=>'liblwp-protocol-https-perl'},
		{module=>'Time::HiRes', file=>'Time/HiRes.pm', redhat=>'perl-Time-HiRes', debian=>''},
	);
	my @failed_modules = grep { !eval { require $_->{file} } && $@ } @modules;
	my %is_failed = map { $_->{module} => 1 } @failed_modules;
	if (@failed_modules) {
		my @redhat_pkgs;
		my @debian_pkgs;
		if (-e '/usr/bin/yum') {
			@redhat_pkgs = map { $_->{redhat} } @failed_modules;
		}
		if (-e '/usr/bin/apt-get') {
			@debian_pkgs = map { $_->{debian} } @failed_modules
		}
		print "Content-type: text/html\n\n";
		print "Testing modules...<br><br>\n";
		print "<table style='width: 320px'>\n";
		for (@modules) {
			my $status = $is_failed{ $_->{module} } ? $err : $ok;
			print "<tr><td><b>$_->{module}...</b></td><td>$status</td></tr>\n";
		}
		print "</table><br><br>\n";
		print "It looks like there are some Perl modules are missing.<br>\n";
		if (@redhat_pkgs || @debian_pkgs) {
			print "You can install all of them at once by issuing the following command from root SSH console:<br><br>\n";
		}
		if (@redhat_pkgs) {
			printf("<font style='font-family: monospace'>yum install %s</font>", join(' ', @redhat_pkgs));
		}
		if (@debian_pkgs) {
			printf("<font style='font-family: monospace'>apt-get install %s</font>", join(' ', @debian_pkgs));
		}
		exit();
	}
}

use Session;
use XUtils;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my $ok = "<br><b style='background:#1a1;color:#fff;padding:2px;'>OK</b>";

my $ses = Session->new();
$ses->setCookie('no_lng_sql', 1);
$c->{no_lng_sql} = 1;
my $f = $ses->f;

if ($f->{site_settings}) {
	my @fields = qw(site_url site_cgi cgi_path cgi_dir htdocs_dir);

	$f->{temp_dir}	   = "$f->{cgi_path}/temp";
	$f->{upload_dir}	 = "$f->{cgi_path}/uploads";
	$f->{htdocs_dir}	 = $f->{site_path};
	$f->{htdocs_tmp_dir} = "$f->{site_path}/tmp";
	$f->{cgi_dir}		= $f->{cgi_path};

	mkdir("$f->{cgi_dir}/logs");

	my $conf;
	open(F, "XFSConfig.pm") || $ses->message("Can't read XFSConfig");
	$conf .= $_ while <F>;
	close F;

	for my $x (@fields) {
		my $val = $f->{$x};
		$conf =~ s/$x\s*=>\s*(\S+)\s*,/"$x => '$val',"/e;
	}

	if (!open(F, ">XFSConfig.pm")) {
		$ses->message("Can't write XFSConfig - (maybe because you need to execute the command: setenforce 0)");
	}
	print F $conf;
	close F;
}

if ($f->{save_sql_settings} || $f->{site_settings}) {
	my @fields = $f->{save_sql_settings} ? qw(db_host db_login db_passwd db_name pasword_salt dl_key) : qw(site_url site_cgi site_path cgi_path license_key);

	for (@fields) {
		$f->{$_} =~ s/\s+$//g;
	}
	for (@fields) {
		$f->{$_} =~ s/^\s+//g;
	}

	my $conf;
	if (!open(F, "XFileConfig.pm")) {
		$ses->message("Can't read XFileConfig");
	}
	$conf .= $_ while <F>;
	close F;

	$f->{pasword_salt} = $c->{pasword_salt} || $ses->randchar(12);
	$f->{dl_key}	   = $c->{dl_key}	   || $ses->randchar(16);


	my $folder = "$c->{cgi_path}/XFSConfig.pm";
	if (-f  $folder) {
		`perl -pi -e "s/dl_key => ''/dl_key => '$f->{dl_key}'/g" $folder`
	}

	my $domain = ($c->{domain}||$ENV{"HTTP_HOST"});
	if (-f  '/usr/local/nginx/conf/sites/hls_http.conf') {
		`perl -pi -e 's/default ""/default "$domain"/g' /usr/local/nginx/conf/sites/hls_http.conf`
	}


	require Crypt::CipherSaber;
	my $b8gl = Crypt::CipherSaber->new(qq[\x49\x72\x32\x36\x66\x57\x59\x78\x48\x4e\x52\x5f\x6d\x46\x57\x42\x44\x2d\x6a\x50]);
	$f->{license_key} = (
		sub {
			$_ = shift;
			my ($e0p4, $j3nf);
			$_ = unpack('B*', $_);
			s/(.....)/000$1/g;
			$e0p4 = length;
			if ($e0p4 & 7) {
				$j3nf = substr($_, $e0p4 & ~7);
				$_ = substr($_, 0, $e0p4 & ~7);
				$_ .= "000$j3nf" . '0' x (5 - length $j3nf);
			}
			$_ = pack('B*', $_);
			tr|\0-\37|A-Z2-7|;
			lc($_);
		}
	)->(
		$b8gl->encrypt(qq[\x78\x76\x73\x7C].($c->{domain}||$ENV{"HTTP_HOST"}).qq[\x7C\x6D\x76\x64\x74\x73\x32\x79\x74\x66\x72\x6A\x6B\x7C\x33\x35\x36\x37\x38\x39\x61\x62\x64\x65\x66\x68\x69\x6A\x67\x6B\x6C\x6D\x6E\x6F\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A])
	);

	for my $x (@fields) {
		my $val = $f->{$x};
		$conf =~ s/$x\s*=>\s*.+?\s*,/"$x => '$val',"/e;
	}

	if (!open(F, ">XFileConfig.pm")) {
		$ses->message("Can't write XFileConfig - (maybe because you need to execute the command: setenforce 0)");
	}
	print F $conf;
	close F;

	$ses->redirect('install.cgi');
}

if ($f->{create_sql}) {
	my $domain = ($c->{domain}||$ENV{"HTTP_HOST"});
	if (-f  '/usr/local/nginx/conf/sites/xvs-fs.conf') {
		`perl -pi -e 's/default ""/default "$c->{dl_key}"/g' /usr/local/nginx/conf/sites/xvs-fs.conf`
	}
	if (-f  '/usr/local/nginx/conf/sites/xvs-fs.conf') {
		`perl -pi -e 's/xxxx.com/$domain/g' /usr/local/nginx/conf/sites/xvs-fs.conf`
	}

	my $db = $ses->db;

	my $db_login = $c->{db_login};
	my $db_passwd = $c->{db_passwd};
	my $db_name = $c->{db_name};
	$db_login =~ s/"/\\"/g;
	$db_passwd =~ s/"/\\"/g;
	$db_name =~ s/"/\\"/g;
	system "mysql -u\"$db_login\" -p\"$db_passwd\" \"$db_name\" < install.sql";

	$db->Exec("INSERT INTO Users SET usr_lastlogin=NOW(), usr_password_changed=CURDATE(), usr_notes='', usr_adm=1, usr_login=?, usr_password=?, usr_email=?,usr_created=NOW(), usr_premium_expire=NOW()+INTERVAL ? DAY",  $f->{usr_login}, $ses->genPasswdHash( $f->{usr_password} ), $f->{usr_email}, 365);

	$ses->redirect('install.cgi');
}

if ($f->{remove_install}) {
	print "Content-type:text/html\n\n";

	unlink('install.cgi');
	if (-e 'install.cgi') {
		print "Can't delete <u>install.cgi</u>, remove it manually<br><br>";
	}

	unlink('install.sql');
	if (-e 'install.sql') {
		print "Can't delete <u>install.sql</u>, remove it manually<br><br>";
	}

	unlink('fixperms.sh');
	if (-e 'fixperms.sh') {
		print "Can't delete <u>fixperms.sh</u>, remove it manually<br><br>";
	}

	print qq[<br><input type='button' value='Go to Login page' onClick="window.location='$c->{site_url}/?op=login&redirect=$c->{site_url}';">];

	my $subdir;
	if ($ENV{REQUEST_URI} =~ /^(.*)\/cgi-bin\/install.cgi/) {
		$subdir = $1;
	}

	if ($subdir) {
		my $htaccess;
		open( FILE, "$c->{site_path}/.htaccess" );
		$htaccess .= $_ while <FILE>;
		close FILE;
		$htaccess =~ s/\/cgi-bin/$subdir\/cgi-bin/;
		open( FILE, ">$c->{site_path}/.htaccess" );
		print FILE $htaccess;
		close FILE;
		print "<br>Installed in subdirectory: $subdir/\n";
	}
	exit;
}

#######
print "Content-type:text/html\n\n";
print
"<HTML><BODY style='font:13px Arial;'><h2>XVideosharing Installation Script</h2>";
############
print "<hr>";
############

print "<b>1) Permissions Check</b><br><br>";
my $perms = {
	"logs"										  => 0777,
	"temp"										  => 0777,
	"uploads"									   => 0777,
	"Templates/static"							  => 0777,
	"Templates/static/categories.html"			=> 0777,
	"Templates/static/categories_all.html"		=> 0777,
	"Templates/static/list_data_adult.html"		=> 0777,
	"Templates/static/list_data_artist.html"	 => 0777,
	"Templates/static/list_data_year.html"		=> 0777,
	"Templates/static/list_menu.html"			=> 0777,
	"Templates/static/tags.html"				=> 0777,
	"Templates/static/videos_featured.html"		=> 0777,
	"Templates/static/videos_just_added.html"	=> 0777,
	"Templates/static/videos_live.html"			 => 0777,
	"Templates/static/videos_most_rated.html"	  => 0777,
	"Templates/static/videos_most_viewed.html"	  => 0777,
	"$c->{site_path}/captchas"					  => 0777,
	"$c->{site_path}/i"							 => 0777,
	"$c->{site_path}/upload-data"				   => 0777,
	"ffmpeg"										=> 0777,
	"ffprobe"									   => 0777,
	"install.cgi"								   => 0777,
	"atop.pl"									   => 0777,
	"xapi.cgi"									   => 0777,
	"cron.pl"									   => 0777,
	"cron_cleanup.pl"							   => 0777,
	"cron_cmd.pl"								 => 0777,
	"cron_daily.pl"								 => 0777,
	"cron_delete.pl"								=> 0777,
	"cron_expire.pl"								=> 0777,
	"cron_parse_views.pl"						   => 0777,
	"cron_static_update.pl"						 => 0777,
	"cron_temp_db.pl"							   => 0777,
	"daemon_email.pl"							   => 0777,
	"enc.pl"										=> 0777,
	"file2db.pl"									=> 0777,
	"install_extra_hdds.pl"						 => 0777,
	"nginx_hls.pl"								  => 0777,
	"nginx_hls2.pl"								 => 0777,
	"nginx_http.pl"								 => 0777,
	"transfer.pl"								   => 0777,
	"url_upload.pl"								 => 0777,
	"logs/ipwhite.dat"							  => 0777,
	"adm.cgi"									   => 0777,
	"api.cgi"									   => 0777,
	"fs.cgi"										=> 0777,
	"index.cgi"									 => 0777,
	"index_dl.cgi"								  => 0777,
	"ipn.cgi"									   => 0777,
	"upload.cgi"									=> 0777,
	"upload_torrent.cgi"							=> 0777,
	"vod.cgi"									   => 0777,
	"fs.fcgi"									   => 0777,
	"index.fcgi"									=> 0777,
	"index_dl.fcgi"								 => 0777,
	"ipn_log.txt"								   => 0666,
	"logs.txt"									  => 0666,
	"XFileConfig.pm"								=> 0666,
	"XFSConfig.pm"								  => 0666,
	"logs/emails.log"							   => 0666,
	"logs/emails.pid"							   => 0666,
	"logs/enc.txt"								  => 0666,
	"logs/fs.log"								   => 0666,
	"logs/idl.log"								  => 0666,
	"logs/ipwhite.dat"							  => 0666,
	"logs/upload.txt"							   => 0666,
	"logs/url_upload.txt"						   => 0666,
	"$c->{site_path}/emb.html"					  => 0666,
	"fs.fcgi"									   => 0644,
	"fs.pm"										 => 0644,
	"GeoLite2-Country.mmdb"						 => 0644,
	"index.fcgi"									=> 0644,
	"index.pm"									  => 0644,
	"index_dl.fcgi"								 => 0644,
	"index_dl.pm"								   => 0644,
	"$c->{site_path}/upload-data/.htaccess"		 => 0644,
	"$c->{site_path}/upload-data/sitemap0.txt.gz"   => 0644,
	"$c->{site_path}/upload-data/sitemap_index.xml" => 0644,
	"$c->{site_path}/error_expired.html"			=> 0644,
	"$c->{site_path}/error_nofile.html"			 => 0644,
	"$c->{site_path}/error_too_many_conn.html"	  => 0644,
	"$c->{site_path}/error_wrong_ip.html"		   => 0644,
	"$c->{site_path}/expired.mp4"				   => 0644,
	"$c->{site_path}/favicon.ico"				   => 0644,
	"$c->{site_path}/index.html"					=> 0644,
	"$c->{site_path}/robots.txt"					=> 0644,
	"$c->{site_path}/wrong_ip.mp4"				  => 0644,
	"$c->{site_path}/.htaccess"					 => 0644,
	"$c->{site_path}/404.html"					  => 0644,
	"$c->{site_path}/503.html"					  => 0644,
	"$c->{site_path}/50x.html"					  => 0644,
	"$c->{site_path}/blank.html"					=> 0644,
	"$c->{site_path}/channel.html"				  => 0644,
	"$c->{site_path}/crossdomain.xml"			   => 0644,
	"$c->{site_path}/404.html"					  => 0644
};

my @arr;
for (sort keys %{$perms}) {
	next unless -e $_;
	next if /^\/\w+$/;
	chmod $perms->{$_}, $_;
	my $chmod = (stat($_))[2] & 07777;
	my $chmod_txt = sprintf("%04o", $chmod);
	if ($chmod != $perms->{$_}) {
		push @arr, "<b>$_</b> : $chmod_txt : <u>ERROR: should be " . sprintf( "%04o", $perms->{$_} ) . "</u>";
	}
}

if (-f "$c->{site_path}/.htaccess") {
	chmod 0666, "$c->{site_path}/.htaccess";
}

print join '<br>', @arr;
if (grep { /ERROR/ } @arr) {
	print "<br><br><font color='red'>Fix permissions above and refresh this page</font><br>";
	print "Or Fix permissions by set the permission 777 to the file <font style='font-family: monospace'>fixperms.sh</font> and issuing the following command from root SSH console:<br>";
	use File::Basename;
	print "<font style='font-family: monospace'>" . ($c->{cgi_path} || dirname($ENV{'SCRIPT_FILENAME'})) . "/fixperms.sh</font>";
}
else {
	print "All permissions are correct.$ok";
}

############
print "<hr>";
############

print "<b>2) Site URL / Path Settings / License Key</b><br><br>";

if ($c->{site_url} && $c->{site_cgi} && $c->{site_path} && $c->{cgi_path}) {
	print "Settings are correct.$ok";
}
else {
	my $path	  = $ENV{DOCUMENT_ROOT};
	my ($cgipath) = $ENV{SCRIPT_FILENAME} =~ /^(.+)\//;
	my $url_cgi   = 'http://' . $ENV{HTTP_HOST} . $ENV{REQUEST_URI};
	$url_cgi =~ s/\/[^\/]+$//;
	my $url = 'http://' . $ENV{HTTP_HOST};
	$url	 = $c->{site_url}  || $url;
	$url_cgi = $c->{site_cgi}  || $url_cgi;
	$path	= $c->{site_path} || $path;
	$path =~ s/\/$//;
	print<<EOP
<form method="POST">
<input type="hidden" name="site_settings" value="1">
Site URL:<br>
<input type="text" name="site_url" value="$url" size=48> <small>No trailing slash</small><br>
cgi-bin URL:<br>
<input type="text" name="site_cgi" value="$url_cgi" size=48> <small>No trailing slash</small><br>
cgi-bin disk path:<br>
<input type="text" name="cgi_path" value="$cgipath" size=48> <small>No trailing slash</small><br>
htdocs(public_html) disk path:<br>
<input type="text" name="site_path" value="$path" size=48> <small>No trailing slash</small><br>
License Key:<br>
<input type="text" name="license_key" value="[Nulled Edition]" size=48 disabled><br>
<br>
<input type="submit" value="Save site settings">
</form>
EOP
;
}

############
print "<hr>";
############

print "<b>3) MySQL Settings</b><br><br>";

my $dbh;
if ($c->{db_name} && $c->{db_host}) {
	$dbh = DBI->connect("DBI:mysql:database=$c->{db_name};host=$c->{db_host}", $c->{db_login}, $c->{db_passwd});
}

if ($dbh) {
	print "MySQL Settings are correct. Can connect to DB.$ok";
}
else {
	print<<EOP
<font color="red">Can't connect to DB with current settings. $DBI::errstr</font><br><br>
<Form method="POST">
<input type="hidden" name="save_sql_settings" value="1">
MySQL Host:<br>
<input type="text" name="db_host" value="$c->{db_host}"><br>
MySQL DB Name:<br>
<input type="text" name="db_name" value="$c->{db_name}"><br>
MySQL DB Username:<br>
<input type="text" name="db_login" value="$c->{db_login}"><br>
MySQL DB Password:<br>
<input type="text" name="db_passwd" value="$c->{db_passwd}"><br><br>
<input type="submit" value="Save MySQL Settings">
</Form>
EOP
;
}

############
print "<hr>";
############

print "<b>4) MySQL tables create & Admin account</b><br><br>";

if (!$dbh) {
	print "<font color=red>Fix MySQL settings above first.</font>";
}
else {
	my $sth = $dbh->prepare("DESC Files");
	my $rc  = $sth->execute();
	if ($rc) {
		print "Tables created successfully.$ok";
	}
	else {
		print<<EOP
<form method="POST">
<input type="hidden" name="create_sql" value="1">
Admin login:<br><input type="text" name="usr_login"><br>
Admin password:<br><input type="text" name="usr_password"><br>
Admin E-mail:<br><input type="text" name="usr_email"><br><br>
<input type="submit" value="Create MySQL Tables & Admin Account">
</form>
EOP
;
	}
}

############
print "<hr>";
############

print<<EOP
5) Clean install
<form method="POST">
<input type="hidden" name="remove_install" value="1">
<input type="submit" value="Remove install files">
</form>
EOP
;

