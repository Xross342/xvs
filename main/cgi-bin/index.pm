package index;

### SibSoft.net ###
use strict;
use utf8;
use lib '.';
#use CGI::Carp qw(fatalsToBrowser);
use XFileConfig;
use Session;
use XUtils;

my ($ses,$f,$db,$ipt,$utype);
$c->{ip_not_allowed}=~s/\./\\./g;

sub run
{
	my ($query,$dbc) = @_;

	$ses = Session->new($query,$dbc);

	$ses->{fast_cgi} = $c->{fast_cgi};

	if($c->{ip_not_allowed} && $ses->getIP=~/$c->{ip_not_allowed}/)
	{
		return sendBack("Your IP was banned by administrator");
	}
#require "Templates/static/XEnglish.pm";
#die $XEnglish::ttt->{lng_buywith_premium_days};

	$f = $ses->f;
	$f->{op}||='';
	my $op = $f->{op};
	$db ||= $ses->db;

	if($c->{banned_countries})
	{
		 my $country=$ses->getMyCountry;
		 return $ses->message("Your country is not allowed on this site") if $country=~/^($c->{banned_countries})$/i;
	}

	if($f->{design}=~/^(\d+)$/)
	{
		$ses->setCookie("design",$1,'+300d');
		my $ref=$ENV{HTTP_REFERER};
		$ref=~s/design=\d+//;
		return $ses->redirect($ref||$c->{site_url});
	}
	&ChangeLanguage if $f->{lang};

my $db = $ses->db;
$ses->CheckAuth() unless $f->{op} eq 'login';
return if $ses->{returning};
return $ses->message($c->{maintenance_full_msg}||"The website is under maintenance.","Site maintenance") if $c->{maintenance_full} && $f->{op}!~/^(admin_|login)/i;

$ses->loadUserData();

if($ses->getUser && $ses->getUser->{usr_allowed_ips} && $f->{op} ne 'logout')
{
	my $pass;
	for my $ip (split(/,\s*/,$ses->getUser->{usr_allowed_ips}))
	{
		$ip=~s/\.\*//g;
		$ip=~s/\./\\\./g;
		$pass=1 if $ses->getIP =~ /^$ip/;
	}
	unless($pass)
	{
		$ses->setCookie($ses->{auth_cook},"");
		$ses->{user}={};
		return $ses->message("You can't login from this IP.");
	}
}

$utype = $ses->getUser ? ($ses->getUser->{premium} ? 'prem' : 'reg') : 'anon';

$c->{$_}=$c->{"$_\_$utype"} for qw(	max_upload_files
									disk_space
									max_upload_filesize
									max_upload_files
									download_countdown
									captcha
									ads
									bw_limit
									remote_url
									direct_links
									down_speed
									add_download_delay
									max_download_filesize
									torrent_dl_slots
									video_embed
									download
									max_watch_time
									fullscreen
									pre_download
									queue_url
									queue_url_max
									upload_enabled
									max_folders_limit
									);

RegisterExternal('twitter')	  if $f->{tid} && $f->{tname} && $f->{op} eq 'register_ext';

my $sub={
	login			=> \&LoginPage,
	news			=> \&News,
	news_details	=> \&NewsDetails,
	contact			=> \&Contact,
	registration	=> \&Register,
	register_save	=> \&RegisterSave,
	register_ext	=> \&RegisterExternal,
	resend_activation => \&ResendActivationCode,
	upload_result	=> \&UploadResult,
	page			=> \&Page,
	page_static		=> \&PageStatic,
	forgot_pass		=> \&ForgotPass,
	contact_send	=> \&ContactSend,
	payments		=> \&Payments,
	checkfiles		=> \&CheckFiles,
	search			=> \&Search,
	change_lang		=> \&ChangeLanguage,
	report_file		=> \&ReportFile,
	api_get_limits	=> \&APIGetLimits,
	comment_add		=> \&CommentAdd,
	cmt_del			=> \&CommentDel,
	del_file		=> \&DelFile,
	links			=> \&Links,
	video_embed		=> \&VideoEmbed,
	unsubscribe		=> \&EmailUnsubscribe,
	api_reseller	=> \&APIReseller,
	make_money		=> \&MakeMoneyPage,
	upload_srt		=> \&UploadSRT,
	vote			=> \&Vote,
	api_reference	=> \&APIReference,
	x1				=> \&X1,
	msg				=> \&Msg,
	}->{ $f->{op} };

return &$sub if $sub;

return PaymentComplete($1) if $ENV{QUERY_STRING}=~/payment_complete=(.+)/;
return PaymentComplete($1) if $ENV{QUERY_STRING}=~/lr_merchant_ref=(\d+)/;

return RegisterConfirm() if $f->{confirm_account};

$sub={
	upload				=> \&Upload,
	upload_file			=> \&UploadFile,
	upload_url			=> \&UploadURL,
	upload_torrent		=> \&UploadTorrent,
	upload_clone		=> \&UploadClone,
	upload_ftp			=> \&UploadFTP,
	upload_tus			=> \&UploadTUS,
	my_account			=> \&MyAccount,
	my_password			=> \&MyPassword,
	my_email			=> \&MyEmail,
	my_referrals		=> \&MyReferrals,
	my_files			=> \&MyFiles,
	my_files_deleted	=> \&MyFilesDeleted,
	my_files_export		=> \&MyFilesExport,
	my_files_dmca		=> \&MyFilesDMCA,
	my_files_dmca_renamed => \&MyFilesDMCARenamed,
	my_views			=> \&MyViews,
	my_reports			=> \&MyReports,
	my_reports_day		=> \&MyReportsDay,
	my_torrents			=> \&MyTorrents,
	my_reseller			=> \&MyReseller,
	my_watermark		=> \&MyWatermark,
	my_snapshot			=> \&MySnapshot,
	my_playlists		=> \&MyPlaylists,
	my_playlist_files	=> \&MyPlaylistFiles,
	my_domains			=> \&MyDomains,
	my_ads				=> \&MyAds,
	my_ads_form			=> \&MyAdsForm,
	file_edit			=> \&FileEdit,
	fld_edit			=> \&FolderEdit,
	request_money		=> \&RequestMoney,
	add_to_playlist		=> \&AddToPlaylist,
	moderator_files		=> \&ModeratorFiles,
	moderator_files_approve => \&ModeratorFilesApprove,
	moderator_reports	=> \&ModeratorReports,
	moderator_comments	=> \&ModeratorComments,
	moderator_files_featured => \&ModeratorFilesFeatured,
	folder_search		=> \&FolderSearch,
	legal_tool			=> \&LegalTool,
	ajax_new_folder		=> \&AjaxNewFolder,
	stream_form			=> \&StreamForm,
	stream_save			=> \&StreamSave,
	my_streams			=> \&MyStreams,
	login_code			=> \&LoginCode,
	ajax_find_copies	=> \&AjaxFindCopies,
	ticket_create		=> \&TicketCreate,
	ticket_list			=> \&TicketList,
	ticket_view			=> \&TicketView,
	ticket_reply		=> \&TicketReply,
	admin_ticket_list	=> \&AdminTicketList,
	admin_ticket_view	=> \&AdminTicketView,
	admin_ticket_reply	=> \&AdminTicketReply,
	logout				=> sub{$ses->Logout},
	}->{ $f->{op} };

if($ENV{HTTP_REFERER} && $sub && !$ses->{ref_ok})
{
	my ($dm)=$ENV{HTTP_REFERER}=~/\/\/([^\/]+)/;
	$dm=~s/^(www|main|srt)\.//;
	$dm=~s/:.*$//;
	my $pass = 1 if $ses->{domain} eq $dm;
	$pass = 1 if !$pass && $db->SelectOne("SELECT srv_id FROM Servers WHERE srv_cgi_url LIKE CONCAT('https://',?,'%')",$dm);
	$pass=1 if $ENV{HTTP_REFERER} eq 'https://www.facebook.com/' && $ENV{REQUEST_URI}=~/my_account/; # social login fix
	print("Content-type:text/html\n\nGo to <a href='$ENV{REQUEST_URI}'>http://$ses->{domain}$ENV{REQUEST_URI}</a>"),return unless $pass;
}

if($sub && $ses->getUser)
{
	#return $ses->message("Access denied") if $f->{op}=~/^admin_/i && !$ses->getUser->{usr_adm} && $f->{op}!~/^(admin_reports|admin_comments)$/i;
	&$sub;
}
elsif($sub)
{
	$f->{redirect}=$ENV{REQUEST_URI};
	LoginPage();
}
else
{
	IndexPage();
}

}

sub X1
{
  return $ses->message("IP:".$ses->getIP." Country:".$ses->getMyCountry);
  #return $ses->message("Country:".$ses->getCountryCode('1.2.3.4'));
}

sub sendBack
{
	 print"Content-type:text/html\n\n".shift;
}

sub LoginPage
{
	if($f->{login} || $f->{method})
	{
		my $user = Login();
		unless($user)
	  {
		  $db->Exec("INSERT INTO LoginProtect SET usr_id=?, ip=INET6_ATON(?)", $ses->{user}->{usr_id}||0, $ses->getIP);
		  $f->{msg}=$ses->{lang}->{lng_login_incorrect_username_or_password};
		  delete $ses->{user};
	  }
	}
	$f->{login}||=$ses->getCookie('login');
	$f->{redirect}=~s/[\0\"\'\<\>]+//g;
	$f->{login}=~s/[\0\"\'\<\>]+//g;
	my $recaptcha=$ses->genRecaptcha if $c->{login_captcha} || $f->{ca} || $db->SelectOne("SELECT COUNT(*) FROM LoginProtect WHERE ip=INET6_ATON(?) AND created>NOW()-INTERVAL ? HOUR",$ses->getIP,$c->{login_fail_last_hours}) > $c->{login_fail_max_attemps};
	$recaptcha='' unless $c->{recaptcha_pub_key} && $c->{recaptcha_pri_key};
	$ses->PrintTemplate("login.html",
								msg=>$f->{msg},
								login=>$f->{login},
								redirect=>$f->{redirect},
								'external_sites_login'	=> $c->{m_l},
								recaptcha => $recaptcha,
								%$c,
							 );
}

sub Login
{
  my ($no_redirect,$instant) = @_;

  if($f->{method} && !($f->{login} && $f->{password}))
  {
	 # Login through the external plugins
	 my $url = $ses->getPlugins('Login')->get_auth_url($f);
	 return $ses->message("Login failed") if !$url;
	 return $ses->redirect($url);
  }

  #($f->{login}, $f->{password}) = split(':',$ses->decode_base64($ENV{HTTP_CGI_AUTHORIZATION})) if $instant;
  #$f->{login}=~s/[^\w\-\_]+//g;
  #my $usr_id = $db->SelectOneCached("SELECT usr_id FROM Users WHERE usr_login=?",$f->{login}) || 0;

  $f->{login}=~s/[^\w\.\@\-\_]+//gi;
		  
  $ses->{user} = $db->SelectRow("SELECT *, UNIX_TIMESTAMP(usr_premium_expire)-UNIX_TIMESTAMP() as exp_sec 
											FROM Users 
											WHERE usr_login=?", $f->{login} );

  return 0 unless $ses->{user};

  my $captcha_required=1 if $c->{login_fail_max_attemps} && $c->{login_fail_last_hours} && $c->{recaptcha_pub_key} && $c->{recaptcha_pri_key} &&
		  $db->SelectOne("SELECT COUNT(*) FROM LoginProtect 
							WHERE (ip=INET6_ATON(?) OR usr_id=?)
							AND created>NOW()-INTERVAL ? HOUR", $ses->getIP, $ses->{user}->{usr_id}, $c->{login_fail_last_hours}) > $c->{login_fail_max_attemps};
	$captcha_required=1 if $c->{login_captcha} && !$f->{method};
	$captcha_required=0 unless $c->{recaptcha_pub_key} && $c->{recaptcha_pri_key};
	return $ses->redirect_msg("?op=login&ca=1","Captcha required") if $captcha_required && !$ses->checkRecaptcha;

	if($ses->{user}->{hashedpass})
	{
		return 0 unless $ses->{user}->{usr_password} eq $f->{password};
	}
	else
	{
		return 0 unless $ses->checkPasswdHash( $f->{password} );
	}

	$db->Exec("DELETE FROM LoginProtect WHERE ip=INET6_ATON(?) AND created>NOW()-INTERVAL ? HOUR", $ses->getIP, $c->{login_fail_last_hours});
  
  
	$ses->{user}->{premium}=1 if $ses->{user}->{exp_sec}>0;
	if($ses->{user}->{usr_status} eq 'PENDING')
	{
		my $id = $ses->{user}->{usr_id}."-".$ses->{user}->{usr_login};
		delete $ses->{user};
		return $ses->message("$ses->{lang}->{lng_login_account_not_confirmed_yet}<br><a href='?op=resend_activation&d=$id'>$ses->{lang}->{lng_login_resend_me_activation_email}</a>");
	}
	if($ses->{user}->{usr_status} eq 'BANNED')
	{
		delete $ses->{user};
		return $ses->redirect_msg('login.html', $ses->{lang}->{lng_login_your_account_banned} );
	}
	return if $instant;

	if($c->{login_limit1_ips} && $c->{login_limit1_hours})
	{
		my $ip = $ses->getIP;
		#my $filter_ip = $c->{login_limit1_subnets} ? "AND (ip<INET_ATON('$ip')-65792 OR ip>INET_ATON('$ip')+65792)" : "AND ip<>INET_ATON('$ip')";
		my $diff_ips = $db->SelectOne("SELECT COUNT(distinct ip)
												 FROM LoginHistory
												 WHERE usr_id=?
												 AND created>NOW()-INTERVAL ? HOUR
												",$ses->{user}->{usr_id},$c->{login_limit1_hours});

		return $ses->redirect_msg('login.html',"You've logged from $c->{login_limit1_ips} different IPs last $c->{login_limit1_hours} hours.<br>Do not share your account details with others.<br>Try to login again in a few minutes.") if $diff_ips>=$c->{login_limit1_ips};
	}
	if($c->{login_limit2_max} && $c->{login_limit2_hours})
	{
		my $logins = $db->SelectOne("SELECT COUNT(*) FROM LoginHistory WHERE usr_id=? AND created>NOW()-INTERVAL ? HOUR",$ses->{user}->{usr_id},$c->{login_limit2_hours});
		return $ses->redirect_msg('login.html',"You've logged in over $c->{login_limit2_max} times last $c->{login_limit2_hours} hours.<br>Login to your account blocked for some time.<br>Try to login again in a few minutes.") if $logins>=$c->{login_limit2_max};
	}

	$ses->loadUserData();

	if($ses->{user}->{usr_logout_sessions})
	{
		$db->Exec("DELETE FROM Sessions WHERE usr_id=?",$ses->{user}->{usr_id});
	}
	if($ses->{user}->{usr_email_newip})
	{
		if($db->SelectOne("SELECT COUNT(*) FROM LoginHistory WHERE usr_id=? AND created>NOW()-INTERVAL 24 HOUR AND ip<>INET6_ATON(?)", $ses->{user}->{usr_id}, $ses->getIP ) > 0)
		{
			my $t = $ses->CreateTemplate("login_email_newip.html");
			$t->param( 'ip'=>$ses->getIP, agent => $ENV{HTTP_USER_AGENT} );
			$ses->SendMailQueue($ses->{user}->{usr_email}, $c->{email_from}, "$c->{site_name}: account logged in from new IP", $t->output);
		}
	}

	my $sess_id = $ses->randchar(16);
	#$db->Exec("DELETE FROM Sessions WHERE last_time + INTERVAL 5 DAY < NOW()");
	$db->Exec("INSERT INTO Sessions SET session_id=?, usr_id=?, ip=INET6_ATON(?), last_time=NOW()",$sess_id,$ses->{user}->{usr_id},$ses->getIP);
	$db->Exec("UPDATE Users SET usr_lastlogin=NOW(), usr_lastip=INET6_ATON(?) WHERE usr_id=?", $ses->getIP, $ses->{user}->{usr_id} );
	$db->Exec("INSERT INTO LoginHistory SET usr_id=?, ip=INET6_ATON(?), agent=?", $ses->{user}->{usr_id}, $ses->getIP, $ENV{HTTP_USER_AGENT}||'');
	$ses->setCookie( $ses->{auth_cook} , $sess_id, '+30d' );
	$ses->setCookie('login',$f->{login},'+6M');

	if( $c->{email_validation_code}==2 || 
		($c->{email_validation_code}==1 && $ses->{user}->{usr_adm}) || 
		($c->{email_validation_code}==3 && $ses->{user}->{usr_notes}=~/LOGINEMAILVALIDATE/i)
	)
	{
		my $t = $ses->CreateTemplate("login_email_code.html");
		my $login_code = $ses->randchar(10);
		$db->Exec("UPDATE Users SET usr_login_code=? WHERE usr_id=?",$login_code,$ses->{user}->{usr_id});
		$t->param( 'ip'=>$ses->getIP, agent => $ses->getBrowser, login_code => $login_code );
		$ses->SendMailQueue($ses->{user}->{usr_email},$c->{email_from},"$c->{site_name}: login security code",$t->output);
		#return $ses->message($t->output);
	}

	return $ses->redirect( $f->{redirect} ) if $f->{redirect} && $f->{redirect}!~/login\.html$/i;
	return $ses->redirect( "$c->{site_url}/?op=my_account" ) unless $no_redirect;

	return $ses->{user};
}

sub LoginCode
{
	if($f->{code} eq $db->SelectOne("SELECT usr_login_code FROM Users WHERE usr_id=?",$ses->getUserId))
	{
		$db->Exec("UPDATE Users SET usr_login_code='' WHERE usr_id=?",$ses->getUserId);
		$db->PurgeCache( "ses".$ses->getCookie( $ses->{auth_cook} ) );
		return $ses->redirect("/?op=my_account");
	}
	else
	{
		return $ses->redirect_msg("/?op=my_account","Invalid code");
	}
}

sub Register
{
	my ($msg) = @_;
	return $ses->message("Registrations disabled.") if !$c->{enabled_reg} || $ses->iPlg('0');
	$msg='' if ref($msg) eq 'CGI::Fast';
	#$msg='' if ref $msg ne 'SCALAR';
	my %secure = $ses->SecSave( 'register', 5, 'captcha' );
	$f->{$_}=$ses->SecureStr($f->{$_}) for qw(usr_login usr_email usr_pay_email);
	my $aff=$1 if $f->{aff_id}=~/^(\d+)$/;
	return $ses->message("Error: $ses->{lang}->{lng_registration_max_lim_reached}") if $ses->{"\x70"."\x6C\x67"}->{1} && $db->SelectOne("SELECT COUNT(*) FROM Users")>=100;
	my @payout_list = map{ {name=>$_} } split(/\s*\,\s*/,$c->{payout_systems});
	my @extra = map{ {name=>$_,field=>'usr_extra_'.lc($_)} } split(/\s*\,\s*/,$c->{extra_user_fields});
	$ses->PrintTemplate("registration.html",
							  #%captcha,
							  #'rand' => $rand,
							  %secure,
							  'usr_login' => $f->{usr_login},
							  'usr_email' => $f->{usr_email},
							  'usr_pay_email' => $f->{usr_pay_email},
							  "pay_type_$f->{usr_pay_type}"  => 1,
							  'msg'			  => $f->{msg}||$msg,
							  'payout_list'	=> \@payout_list,
							  'external_sites_login'	=> $c->{m_l},
							  %$c,
							  'extra_fields'			  => \@extra,
							  aff			 => $aff,
							 );
}

sub RegisterSave
{
	return $ses->redirect($c->{site_url}) unless $ENV{REQUEST_METHOD} eq 'POST';
	return Register() unless $ses->SecCheck( $f->{'rand'}, 'register', $f->{code}, 'captcha' );
	return Register("Error: $ses->{lang}->{lng_registration_username_too_short}") if length($f->{usr_login})<4;
	return Register("Error: $ses->{lang}->{lng_registration_username_too_long}") if length($f->{usr_login})>32;
	return Register("Error: Invalid login: reserved word") if $f->{usr_login}=~/^(admin|images|captchas|files)$/;
	return Register("Error: $ses->{lang}->{lng_registration_invalid_username}") unless $f->{usr_login}=~/^[\w\-\_]+$/;
	return Register("Error: Password contain bad symbols") if $f->{usr_password}=~/[<>"]/;
	return Register("Error: Password contain bad symbols!") if $ses->iPlg('0');
	return Register("Error: $ses->{lang}->{lng_registration_password_too_short}") if length($f->{usr_password})<4;
	return Register("Error: $ses->{lang}->{lng_registration_password_too_long}") if length($f->{usr_password})>32;
	return Register("Error: $ses->{lang}->{lng_registration_passwords_dont_match}") if $f->{usr_password} ne $f->{usr_password2};
	return Register("Error: $ses->{lang}->{lng_registration_email_invalid}") unless $f->{usr_email}=~/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	return Register("Error: $ses->{lang}->{lng_registration_mail_server_banned}") if $c->{mailhosts_not_allowed} && $f->{usr_email}=~/\@$c->{mailhosts_not_allowed}/i;
	return Register("Error: $ses->{lang}->{lng_registration_username_already_used}")  if $db->SelectOne("SELECT usr_id FROM Users WHERE usr_login=?",$f->{usr_login});
	return Register("Error: $ses->{lang}->{lng_registration_email_already_used}") if $db->SelectOne("SELECT usr_id FROM Users WHERE usr_email=?",$f->{usr_email});
	my $confirm_key = $ses->randchar(8) if $c->{registration_confirm_email};
	my $usr_status = $confirm_key ? 'PENDING' : 'OK';
	my $premium_days=0;
	$f->{coupon_code} = lc $f->{coupon_code};
	my $aff = $ses->getCookie('aff')||0;
	$f->{usr_pay_email}=~s/[^\w\-\_\.\@]+//g;
	$f->{usr_pay_type}=~s/[^\w\-\_]+//g;

	if($c->{coupons} && $f->{coupon_code})
	{
		my $hh;
		for(split(/\|/,$c->{coupons}))
		{
			$hh->{lc($1)}=$2 if /^(.+?)=(\d+)$/;
		}
		$premium_days = $hh->{$f->{coupon_code}};
		return Register("Invalid coupon code") unless $premium_days;
	}

	my $passwd_hash = $ses->genPasswdHash( $f->{usr_password} );
	
	$db->Exec("INSERT INTO Users 
				  SET usr_login=?, 
						usr_email=?, 
						usr_password=?,
						usr_created=NOW(),
						usr_password_changed=CURDATE(),
						usr_premium_expire=NOW()+INTERVAL ? DAY,
						usr_security_lock=?,
						usr_status=?,
						usr_aff_id=?,
						usr_pay_email=?, 
						usr_pay_type=?",$f->{usr_login},
											  $f->{usr_email},
											  $passwd_hash,
											  $premium_days,
											  $confirm_key||'',
											  $usr_status,
											  $aff,
											  $f->{usr_pay_email}||'',
											  $f->{usr_pay_type}||'');
	my $usr_id=$db->getLastInsertId;
	$db->Exec("INSERT INTO Stats SET day=CURDATE(), registered=1 ON DUPLICATE KEY UPDATE registered=registered+1");
	if($c->{extra_user_fields})
	{
		for(split(/\s*\,\s*/,$c->{extra_user_fields}))
		{
			 my $name = 'usr_extra_'.lc($_);
			 #$db->Exec("INSERT INTO UserData SET usr_id=?, name=?, value=?", $usr_id, $name, $f->{$name}) if $f->{$name};
			 $ses->saveUserData($name,$f->{$name},$usr_id);
		}
	}
	if($confirm_key)
	{
		my $t = $ses->CreateTemplate("registration_email.html");
		$t->param( 'usr_login'=>$f->{usr_login}, 'usr_password'=>$f->{usr_password}, 'confirm_id'=>"$usr_id-$confirm_key" );
		$ses->SendMailQueue($f->{usr_email}, $c->{email_from}, "$c->{site_name} $ses->{lang}->{lng_registration_email_title_registration_confirmation}", $t->output);
		#return $ses->message($ses->{lang}->{lng_registration_msg_account_created});
		return $ses->PrintTemplate("registration_success_checkmail.html");
	}
	elsif($aff)
	{
		 $db->Exec("INSERT INTO Stats2
						SET usr_id=?, day=CURDATE(),
							 refs=1
						ON DUPLICATE KEY UPDATE
							 refs=refs+1
					  ",$aff);
	}

	#my $err = $ses->ApplyPlugins('user_new', $f->{usr_login}, $f->{usr_password}, $f->{usr_email});
	#return $ses->message("Registration complete but there were plugin errors:<br><br>$err") if $err;
	registerPostprocess();

	$f->{login}	 = $f->{usr_login};
	$f->{password} = $f->{usr_password};
	Login();

	return $ses->redirect( $c->{site_url} );
}

sub RegisterConfirm
{
	my ($usr_id,$confirm_key)=split('-',$f->{confirm_account});
	#my $user = $db->SelectRow("SELECT * FROM Users WHERE usr_id=? AND usr_security_lock=?",$usr_id,$confirm_key);
	my $user = $db->SelectRow("SELECT * FROM Users WHERE usr_id=?",$usr_id);
	unless($user)
	{
		return $ses->message("Invalid confirm code!");
	}
	if($user->{usr_status} eq 'OK')
	{
		return $ses->redirect_msg( '/login.html', 'Account confirmed' );
	}
	if($user->{usr_security_lock} ne $confirm_key)
	{
		return $ses->message("Invalid confirm code.");
	}
	return $ses->message("Account already confirmed") if $user->{usr_status} ne 'PENDING';
	$db->Exec("UPDATE Users SET usr_status='OK', usr_security_lock='' WHERE usr_id=?",$user->{usr_id});
	
	registerPostprocess();

	if($user->{usr_aff_id})
	{
		 $db->Exec("INSERT INTO Stats2
						SET usr_id=?, day=CURDATE(),
							 refs=1
						ON DUPLICATE KEY UPDATE
							 refs=refs+1
					  ",$user->{usr_aff_id});
	}
	$ses->setCookie('login',$user->{usr_login},'+6M');

	return $ses->redirect_msg( '/login.html', 'Account confirmed' );
}

sub RegisterExternal
{
	 my ($method) = @_;
	 $method ||= $f->{method};
	 $ses->{ref_ok}=1; # hack to avoid REFERER security
	 my ($id,$provider,$email,$image_url,$name);

	 my $ret = $ses->getPlugins('Login')->finish($f) || return $ses->message("Auth failed");

	 my $pre = {
					 'vk'		  => 'vk',
					 'facebook'  => 'fb',
					 'twitter'	=> 'tw',
					 'google'	 => 'go',
				  }->{lc($f->{method})} || substr($f->{method},0,2);
	 my $sid = $pre.$ret->{usr_social_id};
	 $sid=~s/^vkvk/vk/;
	 $email = $ret->{usr_email};
	 return $ses->message("Something wrong with login") unless $ret->{usr_social_id};
	 my $user = $db->SelectRow("SELECT *, usr_password as password FROM Users WHERE usr_social_id=?",$sid);
	 $f->{redirect} = '?op=my_account';
	 if($user)
	 {
		  $f->{login} = $user->{usr_login};
		  $f->{password} = $user->{password};
		  $ses->{user}->{hashedpass}=1;
		  Login();
	 }
	 else
	 {
		  my $login = $ret->{usr_login}||$sid;
		  $login=~s/[^\w\-\_]+//g;
		  my $password = $ses->randchar(6);
		  my $aff = $ses->getCookie('aff')||0;
		  $db->Exec("INSERT INTO Users 
						 SET usr_login=?, 
							  usr_social_id=?,
							  usr_email=?, 
							  usr_password=?,
							  usr_created=NOW(),
							  usr_premium_expire=NOW()+INTERVAL ? DAY,
							  usr_security_lock=?,
							  usr_status=?,
							  usr_aff_id=?",	
						$login,
						$sid,
						$email||'',
						$ses->genPasswdHash( $password ),
						0,
						'',
						'OK',
						$aff,
					  );
		  $f->{login} = $login;
		  $f->{password} = $password;
		  registerPostprocess();
		  Login();
	 }
}

sub registerPostprocess
{
	 if($c->{m_f} && $c->{m_f_update_on_reg})
	 {
		  $ses->syncFTPUsers();
	 }
}

sub ResendActivationCode
{
	my ($adm_mode) = @_;
	($f->{usr_id},$f->{usr_login}) = split(/-/,$f->{d});
	my $user = $db->SelectRow("SELECT usr_id,usr_login,usr_email,usr_security_lock,DECODE(usr_password,?) as usr_password
										FROM Users
										WHERE usr_id=?
										AND usr_login=?",
										$c->{pasword_salt},$f->{usr_id},$f->{usr_login});
	return $ses->message("Invalid ID") unless $user;

	my $t = $ses->CreateTemplate("registration_email.html");
	$t->param( 'usr_login'=>$user->{usr_login}, 'usr_password'=>$user->{usr_password}, 'confirm_id'=>"$user->{usr_id}-$user->{usr_security_lock}" );
	$ses->SendMailQueue($user->{usr_email}, $c->{email_from}, "$c->{site_name} registration confirmation", $t->output);
	return $ses->redirect_msg("?op=admin_users","Activation email sent") if $adm_mode;
	return $ses->message("Activation email just resent.<br>To activate it follow the activation link sent to your e-mail.");
}

sub ForgotPass
{
	if($f->{usr_login} && $ENV{REQUEST_METHOD} eq 'POST')
	{
		return $ses->redirect_msg('?op=forgot_pass','Invalid captcha '.$ses->{form}->{msg}) unless $ses->SecCheck( $f->{'rand'}, 'forgotpass', $f->{code}, 'captcha' );
		my $user = $db->SelectRow("SELECT * 
									FROM Users 
									WHERE usr_login=? 
									OR usr_email=?",$f->{usr_login},$f->{usr_login});
		unless($user)
		{
			#return $ses->redirect_msg('?op=forgot_pass',$ses->{lang}->{lng_forgotpassword_no_user_found});
			return $ses->message($ses->{lang}->{lng_forgotpassword_reminder_sent});
		}

		return $ses->message("Security Lock active! Can't reset password.") if $user->{usr_security_lock};

		my $sess_id = $ses->randchar(16);
		$db->Exec( "INSERT INTO Sessions (session_id,usr_id,last_time) VALUES (?,?,NOW())", $sess_id, $user->{usr_id} );

		my $t = $ses->CreateTemplate($c->{email_html} ? "forgot_pass_email.html" : "forgot_pass_email.txt");
		$t->param( 'usr_login'=>$user->{usr_login}, 'sess_id'=>$sess_id, ip=>$ses->getIP );
		$ses->SendMailQueue( $user->{usr_email}, $c->{email_from}, "$c->{site_name}: $ses->{lang}->{lng_forgotpassword_title}", $t->output );
		return $ses->message($ses->{lang}->{lng_forgotpassword_reminder_sent});
	}
	elsif($f->{sess_id} && $f->{password} && $f->{password2})
	{
		return $ses->message("Passwords do not match!") unless $f->{password} eq $f->{password2};
		my $usr_id = $db->SelectOne("SELECT usr_id FROM Sessions WHERE session_id=?",$f->{sess_id});
		return $ses->message("Invalid session id") unless $usr_id;
		my $passwd_hash = $ses->genPasswdHash( $f->{password} );
		$db->Exec("UPDATE Users SET usr_password=? WHERE usr_id=?", $passwd_hash, $usr_id );
		$db->Exec("DELETE FROM Sessions WHERE session_id=? LIMIT 1",$f->{sess_id});
		return $ses->redirect_msg('?op=login',"Your password was updated successfully.");
	}
	elsif($f->{sess_id})
	{
		return $ses->PrintTemplate("forgot_pass_reset.html", sess_id=>$f->{sess_id});
	}
	my %secure = $ses->SecSave( 'forgotpass', 2, 'captcha' );
	$ses->PrintTemplate("forgot_pass.html",%secure);
}

sub Upload
{
	 return $ses->redirect('?op=upload_url')		if $ses->getCookie('upload_mode') eq 'url';
	 return $ses->redirect('?op=upload_torrent')  if $ses->getCookie('upload_mode') eq 'torrent';
	 return $ses->redirect('?op=upload_clone')	 if $ses->getCookie('upload_mode') eq 'clone';
	 return $ses->redirect('?op=upload_ftp')		if $ses->getCookie('upload_mode') eq 'ftp';
	 return $ses->redirect('?op=upload_file');
}

sub UploadFile
{
	return $ses->message($c->{maintenance_upload_msg}||"Uploads are temporarily disabled due to site maintenance","Site maintenance") if $c->{maintenance_upload};
	$ses->setCookie('upload_mode','file');
	if($c->{uploads_selected_only})
	{
		 return $ses->message("You are not allowed to upload files") unless $ses->getUser->{usr_uploads_on};
	}
	else
	{
		 return $ses->message("You are not allowed to upload files") unless $c->{upload_enabled};
	}

	return $ses->message("You've exceeded max uploads daily limit: $c->{max_upload_files} files") if $c->{max_upload_files} && $db->SelectOne("SELECT COUNT(*) FROM Files WHERE usr_id=? AND file_created>NOW()-INTERVAL 24 HOUR",$ses->getUserId) >= $c->{max_upload_files};

	my $filter_type = $utype eq 'prem' ? "AND srv_allow_premium=1" : "AND srv_allow_regular=1";
	my $filter_load = "AND host_out <= host_net_speed*0.9" if $c->{overload_no_upload};
	my $logic = {'space'=>'srv_disk','round'=>'srv_last_upload','random'=>'RAND()'}->{$c->{next_upload_server_logic}};
	my $extra1;
	my $uploader_priority=3;
	if($c->{next_upload_server_logic} eq 'encodings')
	{
		  $extra1.=",(SELECT COUNT(*) FROM QueueEncoding q, Servers ss WHERE q.srv_id=ss.srv_id AND q.status='PENDING' AND q.error='' AND ss.host_id=h.host_id GROUP BY h.host_id) as eq";
		  $logic="eq, RAND()";
		  $uploader_priority=2 if $c->{skip_uploader_priority} && 
		  	$db->SelectOne("SELECT COUNT(*) as num 
							FROM QueueEncoding q, Servers s 
							WHERE q.status='PENDING' 
							AND q.srv_id=s.srv_id 
							AND s.srv_type='STORAGE' 
							AND s.srv_status='ON' 
							AND s.srv_encode=1 
							AND s.srv_disk <= s.srv_disk_max 
							GROUP BY s.host_id 
							ORDER BY num 
							LIMIT 1") < $c->{skip_uploader_priority};
	}
	my $server;
	my $usr_id=$ses->getUserId;
	$server = $db->SelectRow("SELECT s.*, h.*,
										  CASE srv_type WHEN 'UPLOADER' THEN 3 WHEN 'STORAGE' THEN 2 END as type
										  $extra1
										  FROM Servers s, Hosts h
										  WHERE srv_status='ON' 
										  AND s.host_id=h.host_id
										  AND srv_disk <= srv_disk_max
										  AND srv_users_only LIKE '%,$usr_id,%'
										  ORDER BY type DESC, $logic 
										  LIMIT 1");
	my $country=$ses->getMyCountry;
	$server = $db->SelectRow("SELECT s.*, h.*,
										  CASE srv_type WHEN 'UPLOADER' THEN 3 WHEN 'STORAGE' THEN 2 END as type
										  $extra1
										  FROM Servers s, Hosts h
										  WHERE srv_status='ON' 
										  AND s.host_id=h.host_id
										  AND srv_disk <= srv_disk_max
										  $filter_type
										  $filter_load
										  AND srv_countries_only LIKE '%,$country,%'
										  ORDER BY type DESC, $logic 
										  LIMIT 1") if $country && !$server;

	$server = $db->SelectRow("SELECT s.*, h.*,
							CASE srv_type WHEN 'UPLOADER' THEN $uploader_priority WHEN 'STORAGE' THEN 2 END as type
							$extra1
							FROM Servers s, Hosts h
							WHERE s.srv_status='ON' 
							AND s.host_id=h.host_id
							AND s.srv_disk <= srv_disk_max
							$filter_type
							$filter_load
							AND srv_users_only=''
							AND srv_countries_only=''
							ORDER BY type DESC, $logic 
							LIMIT 1") unless $server;

	
	my $hh = prepareUploadData();
	$hh->{hosts} = getUploadServersSelector( $server, $usr_id, $country );

	return $ses->message("We're sorry, there are no servers available for upload at the moment.<br>Refresh this page in some minutes.") unless $server;

	

	$server->{srv_upload_url} = $server->{srv_cgi_url};
	$server->{srv_upload_url}=~s/\/cgi-bin//i;

	my $template = $f->{v}==2 ? "upload_form2.html" : "upload_form.html";

	$ses->PrintTemplate($template,
						%$server,
						%$hh,
						%$c,
						max_upload_filesize_bytes => $c->{max_upload_filesize}*1024*1024,
						sess_id		=> $ses->getCookie( $ses->{auth_cook} ),
						utype		=> $utype,
	);
}

sub UploadURL
{
	return $ses->message($c->{maintenance_upload_msg}||"Uploads are temporarily disabled due to site maintenance","Site maintenance") if $c->{maintenance_upload};
	$ses->setCookie('upload_mode','url');
	if($c->{uploads_selected_only})
	{
		return $ses->message("You are not allowed to upload files") unless $ses->getUser->{usr_uploads_on};
	}
	else
	{
		return $ses->message("URL Uploads disabled for your account type.<br><a href='premium.html'>Upgrade your account</a>") unless $c->{remote_url};
	}

	if($f->{restart_errors})
	{
		$db->Exec("UPDATE QueueUpload
					  SET status='PENDING',size_dl=0,error='',srv_id=0
					  WHERE status='ERROR'
					  AND usr_id=?
					  AND error<>''", $ses->getUserId);
		$ses->redirect('?op=upload_url');
	}
	if($f->{delete_errors})
	{
		$db->Exec("DELETE FROM QueueUpload
					  WHERE status='ERROR'
					  AND usr_id=?
					  AND error<>''", $ses->getUserId);
		$ses->redirect('?op=upload_url');
	}
	if($f->{delete_pending})
	{
		$db->Exec("DELETE FROM QueueUpload
					  WHERE status='PENDING'
					  AND usr_id=?
					  ", $ses->getUserId);
		$ses->redirect('?op=upload_url');
	}
	
	if($f->{del_id})
	{
		$db->Exec("DELETE FROM QueueUpload WHERE id=? AND usr_id=? AND NOT (status='WORKING' AND updated>NOW()-INTERVAL 3 MINUTE)",$f->{del_id},$ses->getUserId);
		return $ses->redirect("?op=upload_url");
	}

	my $used = $db->SelectOne("SELECT COUNT(*) FROM QueueUpload WHERE usr_id=?",$ses->getUserId);
	my $slots_left = $c->{queue_url_max} ? $c->{queue_url_max}-$used : 999;

	my @extras;
	for('cat_id','file_public','file_adult','tags','fld_id')
	{
		push @extras, "$_=$f->{$_}" if $f->{$_};
	}
	
	for (split /\s*\,\s*/, $c->{file_data_fields})
	{
		push @extras, "extra_$_=".$f->{"extra_$_"} if $f->{"extra_$_"};
	}

	my $added=0;
	my $skipped;
	my $premium = $ses->getUser ? $ses->getUser->{premium} : 0;
	$f->{urls} = $ses->{cgi_query}->param('urls');
	if($f->{urls})
	{
		$f->{urls}=~s/\r//g;
		for my $url (split(/\n/,$f->{urls}))
		{
			last if $slots_left==0;
			require URI::Escape;
			$url = URI::Escape::uri_unescape($url);
			require HTML::Entities;
			HTML::Entities::decode_entities($url);
			next if $url=~/[\`\|\>\<\"]+/;
			next if $url=~/\&\&/;
			#next if $url=~/(base64|xvideos|youtube)/i;
			$url=~s/^\s+//g;
			$url=~s/\s+$//g;
			$url=~s/[\0\"]+//g;
			next unless $url=~/^(https?|ftp):\/\//i;
			$skipped++,next if $db->SelectOne("SELECT url FROM QueueUpload WHERE url=?",$url);
			my $srv_id = $f->{srv_id} if $f->{srv_id} && getUploadServersSelector( {}, $ses->getUserId, $ses->getMyCountry );
			$db->Exec("INSERT INTO QueueUpload 
						SET usr_id=?, 
						srv_id=?,
						url=?,
						created=NOW(),
						ip=INET6_ATON(?), 
						premium=?,
						extras=?",
					$ses->getUserId, 
					$srv_id||0,
					$url, 
					$ses->getIP, 
					$premium||0,
					join("\n",@extras)
			);
			$added++;
			$slots_left--;
		}
		my $msg_skipped="<br>$skipped $ses->{lang}->{lng_uploadurl_urls_were_skipped}" if $skipped;
		return $ses->redirect_msg("?op=upload_url","$added URLs $ses->{lang}->{lng_uploadurl_were_added_to_queue}$msg_skipped");
	}

	my $list1 = $db->SelectARef("SELECT *, UNIX_TIMESTAMP()-UNIX_TIMESTAMP(q.updated) as updated2 
								FROM QueueUpload q
								WHERE usr_id=? 
								ORDER BY created",$ses->getUserId);
	for(@$list1)
	{
		if($_->{status} eq 'WORKING' && $_->{updated2} > 90)
		{
		 $_->{restart}=1;
		 $_->{status}='STUCK';
		}
		$_->{url} = substr($_->{url},0,46).'...' if length($_->{url})>46;
		$_->{progress} = $_->{size_full} ? sprintf("%.0f",100*$_->{size_dl}/$_->{size_full}) : 0;
		$_->{size_full} = sprintf("%.0f",$_->{size_full}/1024**2);
		$_->{size_dl}	= sprintf("%.0f",$_->{size_dl}/1024**2);
	}

	my $hh = prepareUploadData();

	$hh->{hosts} = getUploadServersSelector( {}, $ses->getUserId, $ses->getMyCountry );

	$ses->PrintTemplate("upload_url.html",
		%$hh,
		queue_url_max		  => $c->{queue_url},
		slots_left			  => $slots_left,
		max_upload_filesize  => $c->{max_upload_filesize},
		list					  => $list1,
		cat_id					=> $ses->getCookie('cat_id'),
	);
}

sub getUploadServersSelector
{
	my ($server, $usr_id, $country) = @_;

	return [] if $c->{upload_server_selection} eq '';
	return [] if $c->{upload_server_selection} eq 'admin' && !$ses->getUser->{usr_adm};
	return [] if $c->{upload_server_selection} eq 'premium' && $utype ne 'prem';

	my $filter_srv = "AND srv_id=$f->{srv_id}" if $f->{srv_id}=~/^\d+$/ && $ses->getUser;

	my $servers = $db->SelectARef("SELECT * 
									FROM Servers s, Hosts h
									WHERE s.srv_status='ON' 
									AND s.host_id=h.host_id
									AND s.srv_disk <= srv_disk_max
									AND (srv_users_only='' OR srv_users_only LIKE '%,$usr_id,%')
									AND (srv_countries_only='' OR srv_countries_only LIKE '%,$country,%')
									$filter_srv
									ORDER BY h.host_name, s.srv_id
									");
	$_->{selected} = $_->{srv_id}==$server->{srv_id} ? ' selected' : '' for @$servers;
	my $he;
	my @hosts;
	for my $x (@$servers)
	{
		next if $he->{$x->{host_id}}++;
		my $host = {host_name=>$x->{host_name}};
		$host->{in} = sprintf("%.0f",100*$x->{host_in}/$x->{host_net_speed}) if $ses->getUser->{usr_adm};
		$host->{out} = sprintf("%.0f",100*$x->{host_out}/$x->{host_net_speed}) if $ses->getUser->{usr_adm};
		@{$host->{servers}} = grep{$_->{host_id}==$x->{host_id}} @$servers;
		push @hosts, $host;
	}
	return @hosts ? \@hosts : [];
}

sub UploadClone
{
	my $hh = prepareUploadData();
	return $ses->redirect("/?op=upload_file") unless $c->{m_n};
	$ses->setCookie('upload_mode','clone');
	if($f->{urls})
	{
		 $f->{urls}=~s/\r//g;
		 my ($done,@arr);
		 for my $url (split(/\n/,$f->{urls}))
		 {
			 my ($code) = $url=~/\w\/(\w{12})(\.|\/|\n|$)/gs;
			 last if $done>=100;
			 next unless $code;
			 my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=?",$code);
			 next unless $file;
			 my ($new_id,$new_code) = $ses->cloneFile( $file, $f->{fld_id}||0 );
			 push @arr, $new_code;
			 $ses->addTagsToFile( $f->{tags}, $new_id );
			 $ses->addExtraFileData( $f,$ new_id ) if $c->{file_data_fields};
			 $done++;
		 }
		 return $ses->redirect("?op=upload_result&".join('&', map{"fn=$_&st=OK"} @arr ));
	}

	my $hh = prepareUploadData();

	$ses->PrintTemplate("upload_clone.html",
								%$hh,
							  m_n_max_links		  => $c->{m_n_max_links},
							  queue_url_max		  => $c->{queue_url},
							  cat_id					=> $ses->getCookie('cat_id'),
							 );
}

sub AjaxFindCopies
{
	return $ses->amessage("error:bad params") unless $f->{size}=~/^\d+$/ && $f->{md5} && $c->{m_n} && $c->{m_n_instant_md5_upload};
	my $file = $db->SelectRow("SELECT * FROM Files WHERE file_size=? AND file_md5=?",$f->{size},$f->{md5});
	 return $ses->amessage("not found") unless $file;
	 $file->{file_title} = $ses->SecureStr($f->{file_title});
	 $file->{file_descr} = $ses->SecureStr($f->{file_descr});
	 $f->{fld_id} = $db->SelectOne("SELECT fld_id FROM Folders WHERE fld_id=? AND usr_id=?",$f->{fld_id},$ses->getUserId) if $f->{fld_id};
	 my ($new_id,$new_code) = $ses->cloneFile($file,$f->{fld_id});
	 $ses->addTagsToFile( $f->{tags}, $new_id ) if $f->{tags};
	 return $ses->amessage("/?op=upload_result&fn=$new_code&st=OK");
}

sub UploadTorrent
{
	return $ses->message($c->{maintenance_upload_msg}||"Uploads are temporarily disabled due to site maintenance","Site maintenance") if $c->{maintenance_upload};

	my $hh = prepareUploadData();

	return $ses->redirect("/?op=upload_file") unless $c->{m_t};
	$ses->setCookie('upload_mode','torrent');

	return $ses->PrintTemplate("upload_torrent.html", %$hh, error => "Torrent Uploads disabled for your account type") unless $hh->{m_t_enabled};

	my $torrent_dl_slots = $c->{torrent_dl_slots};

	if($c->{uploads_selected_only})
	{
		return $ses->PrintTemplate("upload_torrent.html", %$hh, error => "You are not allowed to upload files") unless $ses->getUser->{usr_uploads_on};
	}

	#return $ses->message("Torrent Uploads disabled for your account type") unless $torrent_dl_slots;

	if($f->{del_torrent})
	{
		$db->Exec("DELETE FROM Torrents WHERE sid=? AND usr_id=?",$f->{del_torrent},$ses->getUserId);
		return $ses->redirect("$c->{site_url}/?op=torrent_upload");
	}

	my $slots_used = $db->SelectOne("SELECT COUNT(*) FROM Torrents WHERE usr_id=? AND status='WORKING'",$ses->getUserId);
	return $ses->PrintTemplate("upload_torrent.html", %$hh, error => "You're using all $slots_used / $torrent_dl_slots torrent slots now") 
		if $torrent_dl_slots && $slots_used >= $torrent_dl_slots;

	#my $type_filter = $utype eq 'prem' ? "AND srv_allow_premium=1" : "AND srv_allow_regular=1";
	my $host = $db->SelectRow("SELECT h.* 
							FROM Hosts h, Servers s
							WHERE h.host_torrent=1
							AND h.host_id=s.host_id
							AND srv_status IN ('ON')
							AND srv_disk <= srv_disk_max*0.99
							AND host_torrent_active>NOW()-INTERVAL 30 SECOND
							ORDER BY RAND() 
							LIMIT 1");
	
	return $ses->PrintTemplate("upload_torrent.html", %$hh, error => "No online torrent server available") unless $host;

	$ses->PrintTemplate("upload_torrent.html",
							  %$host,
							  %$hh,
							  slots_total  => $c->{torrent_dl_slots},
							  slots_used	=> $slots_used,
							  sess_id		=> $ses->getCookie( $ses->{auth_cook} ),
							 );
}

sub UploadFTP
{
	 return $ses->message($c->{maintenance_upload_msg}||"Uploads are temporarily disabled due to site maintenance","Site maintenance") if $c->{maintenance_upload};
	 return $ses->message("FTP Uploads disabled") unless $c->{m_f};
	 $ses->setCookie('upload_mode','ftp');

	 my $hh = prepareUploadData();

	 unless($hh->{m_f_enabled})
	 {
		$f->{msg}="FTP Uploads disabled for your account type";
		UploadFile();
	 }
	 $hh->{usr_ftp_password} = $db->SelectOneCached("SELECT usr_ftp_password FROM Users WHERE usr_id=?",$ses->getUserId);

	 my $server = $db->SelectRow("SELECT * 
	 							FROM Hosts h, Servers s
										  WHERE h.host_ftp=1
										  AND h.host_id=s.host_id
										  AND s.srv_status IN ('ON','READONLY')
										  AND s.srv_disk <= s.srv_disk_max*0.99
										  ORDER BY RAND() 
										  LIMIT 1");
	 return $ses->message("There are no active FTP servers available at the moment") unless $server;

	 $server->{srv_ip}=$c->{m_f_subdomain} if $c->{m_f_subdomain};

	 $ses->PrintTemplate("upload_ftp.html",
								 %$server,
								 %$hh,
								 m_f_sync_files_after => $c->{m_f_sync_files_after},
								);
}

sub UploadTUS
{
	my $hh = prepareUploadData();
	$ses->PrintTemplate("upload_tus.html",
						#%$server,
						%$hh,
	);
}

sub prepareUploadData
{
	 my $hh;

	 $hh->{categories} = genCategoriesSelect();

	 my $spc;
	 for my $mod ('m_t','m_e','m_f','m_n')
	 {
		$spc->{$mod}=1 if $ses->checkModSpecialRights($mod);
	 }
	 $hh->{"$_\_enabled"}=1 for keys %$spc;

	my @extra_data = map{{name=>$_}} split /\s*\,\s*/, $c->{file_data_fields};
	$hh->{extra_data} = \@extra_data;

	$hh->{remote_url} = $c->{remote_url};
	$hh->{category_required} = $c->{category_required};

	my $allfld = $db->SelectARefCached("SELECT * FROM Folders WHERE usr_id=? ORDER BY fld_name",$ses->getUserId);
	my $fh;
	push @{$fh->{$_->{fld_parent_id}}},$_ for map{$_->{selected}= $ses->getCookie('up_fld_id')==$_->{fld_id} ? ' selected' : 0; $_; } @$allfld;
	my @folders_tree = buildTree($fh,0,0);
	$hh->{folders_tree} = \@folders_tree;
	return $hh;
}

sub UploadResult
{
	my $fnames		= ARef($f->{'fn'});
	my $status		= ARef($f->{'st'});

	my @arr;
	
	for(my $i=0;$i<=$#$fnames;$i++)
	{
		$fnames->[$i] = $ses->SecureStr($fnames->[$i]);
		$status->[$i] = $ses->SecureStr($status->[$i]);
		unless($status->[$i] eq 'OK')
		{
			 push @arr, {file_name => $fnames->[$i],'error' => " $status->[$i]"};
			 next;
		}
		my $file = $db->SelectRow("SELECT *
											FROM Files f, Servers s
											WHERE f.file_code=?
											AND f.srv_id=s.srv_id
											AND f.file_created > NOW()-INTERVAL 15 MINUTE",$fnames->[$i]);
		next unless $file;

		$file->{usr_custom_domain} = $ses->getUser->{usr_custom_domain};
		$file->{download_link} = $ses->makeFileLink($file);

		$ses->getVideoInfo($file);

		$file->{vid_length_txt}=~s/^00:(\d\d:\d\d)$/$1/;

		if($c->{video_embed})
		{
			$file->{vid_width}||=400;
			$file->{vid_height}||=300;
			$file->{vid_height}+=24;
			$file->{video_embed_code}=1;
			$file->{embed_code} = $ses->makeEmbedCode($file);
		}
		$file->{deurl} = $ses->shortenURL($file) if $c->{m_j};
		push @arr, $file;
	}

	$ses->PrintTemplate("upload_results.html",
							  'links' => \@arr,
							 );
}

sub News
{
	my $news = $db->SelectARef("SELECT n.*, DATE_FORMAT(n.created,'%M %dth, %Y') as created_txt,
												  COUNT(c.cmt_id) as comments
										 FROM News n
										 LEFT JOIN Comments c ON c.cmt_type=2 AND c.cmt_ext_id=n.news_id
										 WHERE n.created<=NOW()
										 GROUP BY n.news_id
										 ORDER BY n.created DESC".$ses->makePagingSQLSuffix($f->{page}));
	my $total = $db->SelectOne("SELECT COUNT(*) FROM News WHERE created<NOW()");
	for(@$news)
	{
		$_->{site_url} = $c->{site_url};
		$_->{link} = "n$_->{news_id}-$_->{news_title2}.html";
		$_->{news_text} =~s/\n/<br>/gs;
		$_->{news_text} =~s/\[cut\](.+)$/"<a href='$_->{link}'>$ses->{lang}->{lng_news_read_more}<\/a>"/gse;
		$_->{enable_file_comments} = $c->{enable_file_comments};
	}
	$ses->PrintTemplate("news.html",
							  'news' => $news,
							  'paging' => $ses->makePagingLinks($f,$total),
							 );
}

sub NewsDetails
{
	my $news = $db->SelectRow("SELECT *, DATE_FORMAT(n.created,'%M %dth, %Y') as created_txt 
										FROM News n
										WHERE news_id=? AND created<=NOW()",$f->{news_id});
	return $ses->message("No such news") unless $news;
	$news->{news_text} =~s/\n?\[cut\]\n?//gs;
	$news->{news_text} =~s/\n/<br>/gs;
	my $comments = CommentsList(2,$f->{news_id});
	$ses->{page_title} = $ses->{meta_descr} = $news->{news_title};
	$ses->PrintTemplate("news_details.html",
								%{$news},
								'cmt_type'	  => 2,
								'cmt_ext_id'	=> $news->{news_id},
								'comments' => $comments,
								'enable_file_comments' => $c->{enable_file_comments},
							 );
}

sub CommentsList
{
	my ($cmt_type,$cmt_ext_id) = @_;
	my $list = $db->SelectARef("SELECT *, INET6_NTOA(cmt_ip) as ip, DATE_FORMAT(created,'%M %e, %Y at %r') as date
										 FROM Comments 
										 WHERE cmt_type=? 
										 AND cmt_ext_id=?
										 ORDER BY created",$cmt_type,$cmt_ext_id);
	for (@$list)
	{
		$_->{cmt_text}=~s/\n/<br>/gs;
		$_->{cmt_name} = "<a href='$_->{cmt_website}'>$_->{cmt_name}</a>" if $_->{cmt_website};
		if($ses->getUser && $ses->getUser->{usr_adm})
		{
			$_->{email} = $_->{cmt_email};
			$_->{adm} = 1;
		}
	}
	return $list;
}

sub ChangeLanguage
{
	$f->{lang}='English' unless -f "$c->{cgi_path}/Templates/static/X$f->{lang}.pm";
	$ses->setCookie('lang',$f->{lang});
	return $ses->redirect($ENV{HTTP_REFERER}||$c->{site_url});
}

sub Page
{
	my $tmpl = $f->{tmpl};
	my $lang_name = lc $ses->{language};
	IndexPage() unless -e "Templates/Pages/$lang_name/$tmpl.html";
	$ses->{expires}="+$c->{caching_expire}s" if $c->{caching_expire};
	$ses->PrintTemplate("Pages/$lang_name/$tmpl.html");
}

sub PageStatic
{
	my $tmpl = shift || $f->{tmpl};
	$tmpl = lc $tmpl;
	return $ses->message("Page not found") unless -e "Templates/static/$tmpl.html";
	$ses->{expires}="+$c->{caching_expire}s" if $c->{caching_expire};
	$ses->PrintTemplate("static/$tmpl.html");
}

sub Contact
{
	my %secure = $ses->SecSave( 'contact', 8, 'captcha' );
	$f->{$_}=$ses->SecureStr($f->{$_}) for keys %$f;
	$f->{email}||=$ses->getUser->{usr_email} if $ses->getUser;
	$ses->PrintTemplate("contact.html",
						name => $f->{name},
						email => $f->{email},
						message => $f->{message},
						%secure,
						);
}

sub ContactSend
{
	Contact() unless $ENV{REQUEST_METHOD} eq 'POST';
	Contact() unless $ses->SecCheck( $f->{'rand'}, 'contact', $f->{code}, 'captcha' );

	$f->{msg}.=$ses->{lang}->{lng_contact_invalid_email}."<br>" unless $f->{email} =~ /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	$f->{msg}.=$ses->{lang}->{lng_contact_message_too_short} if length($f->{message})<7;
	
	&Contact if $f->{msg};

	$f->{$_}=$ses->SecureStr($f->{$_}) for keys %$f;

	my $ip = $ses->getIP;
	$f->{message} = "You've got new message from $c->{site_name}.\n\nName: $f->{name}\nE-mail: $f->{email}\nIP: $ip\n\n$f->{message}";
	$ses->SendMailQueue($c->{contact_email}, $c->{email_from}, "New message from $c->{site_name} contact form", $f->{message},'text');
	return $ses->redirect_msg('?op=msg', $ses->{lang}->{lng_contact_message_sent_ok} );
}

sub LegalTool
{
	 return $ses->message("Access denied") unless $c->{m_d} && $ses->getUser->{usr_notes}=~/LEGAL=\d+/i;
	 my $last24 = $db->SelectOne("SELECT COUNT(*) FROM FilesTrash WHERE del_by=? AND file_deleted>NOW()-INTERVAL 24 HOUR",$ses->getUserId);
	 my ($limit) = $ses->getUser->{usr_notes}=~/LEGAL=(\d+)/i;
	 my $left = $limit - $last24;

	 if($f->{mass_delete})
	 {
		my @arr;
		$f->{mass_delete}=~s/\r//g;
		push @arr,$1 while $f->{mass_delete}=~/\/(\w{12})(\/|$|\n|\.)/gs;
		my $codes = join("','",@arr);
		my $files = $db->SelectARef("SELECT * FROM Files WHERE file_code IN ('$codes')") if $codes;
		return $ses->message("You can delete $left files only due to daily limit") if $#$files+1 > $left;
		$ses->DeleteFilesMass($files);
		return $ses->redirect_msg("$c->{site_url}/?op=legal_tool", ($#$files+1)." files were deleted successfully");
	 }
	$ses->PrintTemplate("legal_tool.html", left => $left);
}

sub ModeratorFiles
{
	return $ses->message("Access denied") if !$ses->getUser->{usr_adm} && !($c->{m_d} && $ses->getUser->{usr_mod} && $c->{m_d_f});
	if($f->{del_selected} && $f->{file_id})
	{
		return $ses->message("Not allowed in Demo mode") if $c->{demo_mode};
		my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})});
		return $ses->redirect($c->{site_url}) unless $ids;
		my $files = $db->SelectARef("SELECT * FROM Files WHERE file_id IN ($ids)");
		my $deleted24 = $db->SelectOne("SELECT COUNT(*) FROM FilesTrash WHERE del_by=? AND file_deleted>NOW()-INTERVAL 24 HOUR",$ses->getUserId);
		return $ses->message("Delete limit $c->{m_d_f_limit} files per day can't be exceeded") if $c->{m_d_f_limit} && $deleted24+$#$files+1 > $c->{m_d_f_limit};
		$_->{del_money}=$c->{del_money_file_del} for @$files;
		$ses->DeleteFilesMass($files);
		if($f->{del_info})
		{
			for(@$files)
			{
				$db->Exec("INSERT INTO DelReasons SET file_code=?, file_name=?, info=?",$_->{file_code},$_->{file_name},$f->{del_info});
			}
		}
		return $ses->redirect("$c->{site_url}/?op=moderator_files");
	}
	if($f->{featured_add} && $f->{file_id} && $c->{m_d_featured})
	{
		return $ses->message("Not allowed in Demo mode") if $c->{demo_mode};
		for(@{ARef($f->{file_id})})
		{
			$db->Exec("INSERT IGNORE INTO FilesFeatured SET file_id=?",$_);
		}
		return $ses->redirect_msg("$c->{site_url}/?op=moderator_files_featured","Files were added to list");
	}
	if(($f->{lock}||$f->{unlock}) && $f->{file_id})
	{
		return $ses->message("Not allowed in Demo mode") if $c->{demo_mode};
		my $ids = join ',', grep{/^\d+$/} @{ARef($f->{file_id})};
		my $status = $f->{lock} ? 'LOCKED' : 'OK';
		$db->Exec("UPDATE Files SET file_status='$status' WHERE file_id IN ($ids)") if $ids;
		return $ses->redirect_msg("$c->{site_url}/?op=moderator_files");
	}

	my $filter_files;
	if($f->{mass_search})
	{
		my @arr;
		$f->{mass_search}=~s/\r//g;
		push @arr,$1 while $f->{mass_search}=~/\/(\w{12})(\/|\.|$|\n)/gs;
		$filter_files = "AND file_code IN ('".join("','",@arr)."')";
	}
	$f->{sort_field}||= $f->{fld_id} ? 'file_title' : 'file_id';
	$f->{sort_order}||= $f->{fld_id} ? 'up' : 'down';
	$f->{per_page}||=$c->{items_per_page};
	$f->{usr_id}=$db->SelectOne("SELECT usr_id FROM Users WHERE usr_login=?",$f->{usr_login}) if $f->{usr_login};
	my $filter_key	 = "AND (file_name LIKE '%$f->{key}%' OR file_title LIKE '%$f->{key}%')" if $f->{key};
	my $filter_user	= "AND f.usr_id='$f->{usr_id}'" if $f->{usr_id};
	my $filter_ip	  = "AND f.file_ip=INET6_ATON('$f->{ip}')" if $f->{ip}=~/^[\d\.]+$/;
	my $filter_code	= "AND (f.file_code='$f->{code}' OR f.file_real='$f->{code}')" if $f->{code}=~/^\w{12}$/;
	my $filter_status = "AND f.file_status='$f->{file_status}'" if $f->{file_status}=~/^\w+$/i;
	my $files = $db->SelectARef("SELECT f.*,
													INET6_NTOA(file_ip) as file_ip,
													u.usr_id, u.usr_login
										  FROM Files f
										  LEFT JOIN Users u ON f.usr_id = u.usr_id
										  WHERE 1
										  $filter_files
										  $filter_key
										  $filter_user
										  $filter_ip
										  $filter_code
										  $filter_status
										  ".$ses->makeSortSQLcode($f,'file_id').$ses->makePagingSQLSuffix($f->{page},$f->{per_page}) );
	my $total = $db->SelectOne("SELECT COUNT(*) as total_count
										  FROM Files f 
										  WHERE 1 
										  $filter_files
										  $filter_key 
										  $filter_user 
										  $filter_ip
										  $filter_code
										  $filter_status
										  ");

	for(@$files)
	{
		$_->{site_url} = $c->{site_url};
		$_->{file_title_txt} = $ses->shortenString( $_->{file_title}||$_->{file_name}, $c->{display_max_filename_admin} );
		$_->{file_size2} = sprintf("%.01f Mb",$_->{file_size}/1048576);
		$_->{download_link} = $ses->makeFileLink($_);
		$_->{td_style}=' class="file_pending"' if $_->{file_status} eq 'PENDING';
		$_->{td_style}=' class="file_locked"'  if $_->{file_status} eq 'LOCKED';
		$ses->getVideoInfo($_) if $f->{thumbnail};
	}

	my %sort_hash = $ses->makeSortHash($f,['file_title','file_downloads','file_size_n','file_created','file_id']);

	$ses->PrintTemplate("admin_files_moderator.html",
							'files'	=> $files,
							'key'	=> $f->{key},
							'code'	 => $f->{code},
							'usr_id'=> $f->{usr_id},
							"per_$f->{per_page}" => ' checked',
							'paging'	=> $ses->makePagingLinks($f,$total),
							'items_per_page' => $c->{items_per_page},
							'usr_login'=> $f->{usr_login},
							'm_d_featured' => $c->{m_d_featured},
							"file_status_$f->{file_status}" => ' checked',
							'thumbnail'	 => $f->{thumbnail},
							%sort_hash,
							);
}

sub ModeratorFilesApprove
{
	return $ses->message("Access denied") if !$ses->getUser->{usr_adm} && !($c->{m_d} && $ses->getUser->{usr_mod} && $c->{m_d_file_approve});
	if($f->{approve} && $f->{file_id} && $c->{m_d_file_approve})
	{
		return $ses->message("Not allowed in Demo mode") if $c->{demo_mode};
		my $ids = join ',', grep{/^\d+$/} @{ARef($f->{file_id})};
		$db->Exec("UPDATE Files SET file_status='OK' WHERE file_id IN ($ids)");
		return $ses->redirect_msg("$c->{site_url}/?op=moderator_files_approve");
	}
	if($f->{del_selected} && $f->{file_id})
	{
		return $ses->message("Not allowed in Demo mode") if $c->{demo_mode};
		my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})});
		return $ses->redirect($c->{site_url}) unless $ids;
		my $files = $db->SelectARef("SELECT * FROM Files WHERE file_id IN ($ids)");
		$_->{del_money}=$c->{del_money_file_del} for @$files;
		$ses->DeleteFilesMass($files);
		if($f->{del_info})
		{
			for(@$files)
			{
				$db->Exec("INSERT INTO DelReasons SET file_code=?, file_name=?, info=?",$_->{file_code},$_->{file_name},$f->{del_info});
			}
		}
		return $ses->redirect("$c->{site_url}/?op=moderator_files_approve");
	}

	$f->{per_page}||=$c->{items_per_page};
	my $files = $db->SelectARef("SELECT f.*,
										INET6_NTOA(file_ip) as file_ip,
										u.usr_id, u.usr_login
								FROM Files f
								LEFT JOIN Users u ON f.usr_id = u.usr_id
								WHERE f.file_status='PENDING'
								ORDER BY file_created DESC
								".$ses->makePagingSQLSuffix($f->{page},$f->{per_page}) );
	my $total = $db->SelectOne("SELECT COUNT(*) as total_count
								FROM Files f 
								WHERE f.file_status='PENDING' 
								");

	for(@$files)
	{
		$_->{site_url} = $c->{site_url};

		$_->{file_name_txt} = $ses->shortenString($_->{file_name});

		$_->{file_size2} = sprintf("%.01f Mb",$_->{file_size}/1048576);
		$_->{download_link} = $ses->makeFileLink($_);
		$ses->getVideoInfo($_);
	}

	$ses->PrintTemplate("admin_files_moderator_approve.html",
						'files'	=> $files,
						"per_$f->{per_page}" => ' checked',
						'paging'	=> $ses->makePagingLinks($f,$total),
						'items_per_page' => $c->{items_per_page},
						);
}

sub MyReports
{
	my @d1 = $ses->getTime();
	$d1[2]='01';
	my @d2 = $ses->getTime();
	my $day1 = $f->{date1}=~/^\d\d\d\d-\d\d-\d\d$/ ? $f->{date1} : "$d1[0]-$d1[1]-$d1[2]";
	my $day2 = $f->{date2}=~/^\d\d\d\d-\d\d-\d\d$/ ? $f->{date2} : "$d2[0]-$d2[1]-$d2[2]";
	my $list2 = $db->SelectARefCached("SELECT *, DATE_FORMAT(day,'%e') as day2, (views+views_prem) as views
										FROM Stats2
										WHERE usr_id=?
										AND day>=?
										AND  day<=?
										ORDER BY day",$ses->getUserId,$day1,$day2);
	return $ses->message("Not enough reports data") if $#$list2<0;

	 my $list = $ses->getDatesList($list2,$day1,$day2);

	my %totals;
	my (@days,@profit_dl,@profit_sales,@profit_refs);
	for my $x (@$list)
	{
		$x->{profit_total} = sprintf("%.05f",$x->{profit_views}+$x->{profit_sales}+$x->{profit_refs}+$x->{profit_site});
		for(qw(profit_dl profit_sales profit_refs profit_total))
		{
			#$x->{$_}=~s/\.?0+$//;
		}
		$totals{"sum_$_"}+=$x->{$_} for qw(views views_prem views_adb downloads sales profit_views profit_sales profit_refs profit_site profit_total refs);
		$x->{$_}||=0 for qw(views uploads sales);
		$x->{$_}||='' for qw(downloads refs);
		$x->{$_}||='0.00000' for qw(profit_views profit_sales profit_refs profit_site);
	}

	# my $divlines = $#$list-1;
	# $divlines=1 if $divlines<1;

	$ses->PrintTemplate("my_reports.html",
						list => $list,
						date1 => $day1,
						date2 => $day2,
						%totals,
						m_b		=> $c->{m_b},
						);
}

sub MyReportsDay
{
	return $ses->message("Invalid day") unless $f->{day}=~/^\d\d\d\d-\d\d-\d\d$/;
	my $countries = $db->SelectARef("SELECT * FROM StatsCountry WHERE usr_id=? AND day=? ORDER BY money DESC, views DESC LIMIT 20",$ses->getUserId,$f->{day});
	$ses->PrintTemplate("my_reports_day.html",
						countries => $countries,
						day => $f->{day},
						);
}

sub MyAccount
{
	if($f->{msg})
	{
		# Purge user data cache on Save
		$db->PurgeCache( "ses".$ses->getCookie( $ses->{auth_cook} ) );
	}
	if($f->{generate_api_key})
	{
		my $key = $ses->randchar(1,'az').$ses->randchar(15);
		$db->Exec("UPDATE Users SET usr_api_key=? WHERE usr_id=?",$key,$ses->getUserId);
		return $ses->redirect_msg("?op=my_account","New API key generated");
	}
	if($f->{confirmchanges})
	{
		my $rec = $db->SelectRow("SELECT * FROM ChangeFields WHERE hash=? AND usr_id=? AND created>NOW()-INTERVAL 12 HOUR",$f->{confirmchanges},$ses->getUserId);
		return $ses->message("Invalid hash") unless $rec;
		for my $str (split /\n/, $rec->{data})
		{
			my ($field,$value) = $str=~/^([\w\_\-]+)=(.*)$/;
			$db->Exec("UPDATE Users SET `$field`=? WHERE usr_id=? LIMIT 1",$value,$ses->getUserId);
		}
		return $ses->redirect_msg('?op=my_account','Changes confirmed');
	}
	if($f->{premium_key} && $c->{m_k})
	{
		my ($key_id,$key_code) = $f->{premium_key}=~/^(\d+)(\w+)$/;
		my $key = $db->SelectRow("SELECT * FROM PremiumKeys WHERE key_id=? AND key_code=?",$key_id,$key_code);
		return $ses->redirect_msg("?op=my_account","Invalid Premium Key") unless $key;
		return $ses->redirect_msg("?op=my_account","This Premium Key already used") if $key->{usr_id_activated};
		my ($val,$m) = $key->{key_time}=~/^(\d+)(\D*)$/;
		$m||='d';
		my $int = {'h'=>'HOUR','d'=>'DAY','m'=>'MONTH'}->{$m};
		my $fromtime = $utype eq 'prem' ? 'usr_premium_expire' : 'NOW()';
		$db->Exec("UPDATE Users SET usr_premium_expire=$fromtime+INTERVAL $val $int
					  WHERE usr_id=?",$ses->getUserId);
		$db->Exec("UPDATE PremiumKeys SET key_activated=NOW(), usr_id_activated=? WHERE key_id=?",$ses->getUserId,$key->{key_id});
		$m=~s/h/ $ses->{lang}->{lng_misc_hours}/ie;
		$m=~s/d/ $ses->{lang}->{lng_misc_days}/ie;
		$m=~s/m/ $ses->{lang}->{lng_misc_mins}/ie;
		return $ses->redirect_msg("?op=my_account","$ses->{lang}->{lng_myaccount_prem_key_ok}<br>$ses->{lang}->{lng_myaccount_added_prem_time}: $val $m");
	}
	if($f->{avatar_delete} && $ses->checkToken)
	{
		unlink("$c->{site_path}/upload-data/avatar_".$ses->getUserId.".jpg");
		return $ses->redirect("?op=my_account");
	}
	if($f->{enable_lock} && $ses->checkToken)
	{
		return $ses->message("Security Lock already enabled") if $ses->getUser->{usr_security_lock};
		my $rand = $ses->randchar(8);
		$db->Exec("UPDATE Users SET usr_security_lock=? WHERE usr_id=?",$rand,$ses->getUserId);
		return $ses->redirect_msg("?op=my_account",$ses->{lang}->{lng_myaccount_lock_activated});
	}
	if($f->{disable_lock})
	{
		return $ses->message("Demo mode") if $c->{demo_mode} && $ses->getUser->{usr_login} eq 'admin';
		my $rand = $ses->getUser->{usr_security_lock};
		return $ses->message("Security Lock is not enabled") unless $rand;
		if($f->{code})
		{
			return $ses->message("Error: security code doesn't match") unless $f->{code} eq $rand;
			$db->Exec("UPDATE Users SET usr_security_lock='' WHERE usr_id=?",$ses->getUserId);
			return $ses->redirect_msg("?op=my_account",$ses->{lang}->{lng_myaccount_lock_disabled});
		}
		$ses->SendMailQueue( $ses->getUser->{usr_email}, $c->{email_from}, "$c->{site_name}: disable security lock", "To disable Security Lock for your account follow this link:\n$c->{site_url}/?op=my_account&disable_lock=1&code=$rand", 'text' );
		return $ses->redirect_msg("?op=my_account",$ses->{lang}->{lng_myaccount_lock_link_sent});
	}
	if($f->{site_add} && $f->{site_validate})
	{
		$f->{site_add}=~s/^https?:\/\///i;
		$f->{site_add}=~s/^www\.//i;
		$f->{site_add}=~s/[\/\s]+//g;

		if(my $usr_id1 = $db->SelectOne("SELECT usr_id FROM Websites WHERE domain=?",$f->{site_add}))
		{
			return $ses->message("$f->{site_add} $ses->{lang}->{lng_myaccount_domain_already_added_by} usr_id=$usr_id1");
		}

		my $site_key = lc $c->{site_url};
		$site_key=~s/^www\.//i;
		$site_key=~s/^.+\/\///;
		$site_key=~s/\W//g;

		my $reqs = $ses->checkEventRate($ses->getUserId, 'siteadd', 3 ); # 3 requests per minute limit
		return $ses->message("Too many requests from you!") if $reqs >= 3;

		require LWP::UserAgent;
		my $ua = LWP::UserAgent->new(timeout => 10, agent => $c->{lwp_user_agent} );
		#$ua->proxy(https => 'http://user:pass@proxy');
		my $res = $ua->get("http://$f->{site_add}/$site_key.txt")->content;
		$res=~s/[\r\n]+//g;
		my $ok;
		if($res=~/^\d+$/)
		{
			$ok=1 if $res == $ses->getUserId;
		}
		else
		{
			my $res = $ua->get("http://$f->{site_add}")->content;
			$ok=1 if $res=~/<meta\s+content="1"\s+name="$site_key"\s*\/?>/is;
			$ok=1 if $res=~/<meta\s+name="$site_key"\s+content="1"\s*\/?>/is;
		}
		if($ok)
		{
			$db->Exec("INSERT INTO Websites SET usr_id=?, domain=?, created=NOW()",$ses->getUserId,$f->{site_add});
			return $ses->redirect_msg("?op=my_account","$f->{site_add} $ses->{lang}->{lng_myaccount_domain_added_to_account}");
		}
		return $ses->redirect_msg("?op=my_account","$ses->{lang}->{lng_myaccount_failed_to_verify_domain} $f->{site_add}");
	}
	if($f->{site_del})
	{
		$db->Exec("DELETE FROM Websites WHERE usr_id=? AND domain=? LIMIT 1",$ses->getUserId,$f->{site_del});
		return $ses->redirect_msg("?op=my_account","$f->{site_del} $ses->{lang}->{lng_myaccount_domain_deleted}");
	}
	if($f->{site_reset})
	{
		$db->Exec("UPDATE Websites SET money_profit=0 WHERE usr_id=?",$ses->getUserId);
		return $ses->redirect_msg("?op=my_account",$ses->{lang}->{lng_myaccount_profit_counters_reset_ok});
	}
	if($f->{settings_save} && $ENV{REQUEST_METHOD} eq 'POST' && $ses->checkToken)
	{
		return $ses->message("Not allowed in Demo mode!") if $c->{demo_mode} && $ses->getUser->{usr_adm};
		my $user=$db->SelectRow("SELECT usr_login,DECODE(usr_password,?) as usr_password,usr_email FROM Users WHERE usr_id=?",$c->{pasword_salt},$ses->getUserId);
		if($f->{usr_login} && $user->{usr_login}=~/^\d+$/ && $f->{usr_login} ne $user->{usr_login})
		{
			$f->{usr_login}=$ses->SecureStr($f->{usr_login});
			return $ses->message($ses->{lang}->{lng_myaccount_msg_login_should_contain_letters}) if $f->{usr_login}=~/^\d+$/;
			return $ses->message($ses->{lang}->{lng_myaccount_msg_login_too_short}) if length($f->{usr_login})<4;
			return $ses->message($ses->{lang}->{lng_myaccount_msg_login_too_long}) if length($f->{usr_login})>32;
			return $ses->message($ses->{lang}->{lng_myaccount_msg_login_reserved_words}) if $f->{usr_login}=~/^(admin|images|captchas|files)$/;
			return $ses->message($ses->{lang}->{lng_myaccount_msg_invalid_login}) unless $f->{usr_login}=~/^[\w\-\_]+$/;
			return $ses->message($ses->{lang}->{lng_myaccount_msg_login_exist})  if $db->SelectOne("SELECT usr_id FROM Users WHERE usr_login=?",$f->{usr_login});
			$db->Exec("UPDATE Users SET usr_login=? WHERE usr_id=?",$f->{usr_login},$ses->getUserId);
		}
		# if($f->{usr_email} ne $ses->getUser->{usr_email} && !$ses->getUser->{usr_security_lock})
		# {
		#	 return $ses->message("This email already in use") if $db->SelectOne("SELECT usr_id FROM Users WHERE usr_id<>? AND usr_email=?", $ses->getUserId, $f->{usr_email} );
		#	 return $ses->message("Error: Invalid e-mail") unless $f->{usr_email}=~/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
		#	 $db->Exec("UPDATE Users SET usr_email=? WHERE usr_id=?",$f->{usr_email},$ses->getUserId);
		#	 $f->{msg}.=$ses->{lang}->{lng_myaccount_msg_email_changed_ok}.'<br>';
		#	 $user->{usr_email_new} = $f->{usr_email};
		# }
		if(!$ses->getUser->{usr_security_lock})
		{
			$db->Exec("UPDATE Users 
						  SET usr_pay_type=?,
								usr_channel_name=?,
								usr_no_file_delete=?
						  WHERE usr_id=?",
											$f->{usr_pay_type}||'',
											$f->{usr_channel_name}||'',
											$f->{usr_no_file_delete}||0,
											$ses->getUserId);

			if($ses->getUser->{usr_pay_email} ne $f->{usr_pay_email})
			{
				my $hash = $ses->randchar(10);
				$db->Exec("INSERT INTO ChangeFields SET hash=?, usr_id=?, ip=INET6_ATON(?), data=?", $hash, $ses->getUserId, $ses->getIP, "usr_pay_email=$f->{usr_pay_email}" );
				my $t = $ses->CreateTemplate("my_account_changes_email.html");
				my @arr = ({name=>'Payment Info', 'old'=>$ses->getUser->{usr_pay_email}, 'new'=>$f->{usr_pay_email}});
				$t->param( ip => $ses->getIP, agent => $ENV{HTTP_USER_AGENT}, hash => $hash, fields => \@arr );
				$ses->SendMailQueue($ses->getUser->{usr_email}, $c->{email_from}, "$c->{site_name} Payment Info change request", $t->output);
				$f->{msg}.="Payment Info update link sent to your email.<br>";
			}

			if($f->{usr_allowed_ips} ne $ses->getUser->{usr_allowed_ips})
			{
				$f->{usr_allowed_ips}=~s/\s+//g;
				return $ses->message($ses->{lang}->{lng_myaccount_msg_invalid_ip_mask}) if $f->{usr_allowed_ips} && $f->{usr_allowed_ips}!~/^[\d\.\*\,]{3,}$/;
				for(split(/,/,$f->{usr_allowed_ips}))
				{
					return $ses->message($ses->{lang}->{lng_myaccount_msg_invalid_ip_mask}) unless /^\d+\.\d+\.[\d\.\*]+$/;
				}
				my $pass;
				for my $ip (split(/,\s*/,$f->{usr_allowed_ips}))
				{
					$ip=~s/\.\*//g;
					$ip=~s/\./\\\./g;
					$pass=1 if $ses->getIP =~ /^$ip/;
				}
				return $ses->message($ses->{lang}->{lng_myaccount_msg_invalid_ip_mask2}.$ses->getIP) if $f->{usr_allowed_ips} && !$pass;
				$db->Exec("UPDATE Users SET usr_allowed_ips=? WHERE usr_id=?",$f->{usr_allowed_ips},$ses->getUserId);
			}

			if($f->{user_avatar})
			{
				my $avatarfile = "$c->{site_path}/upload-data/avatar_".$ses->getUserId.".jpg";
				my $fh = $ses->{cgi_query}->upload('user_avatar');
				return $ses->message("Error fetching avatar: ".$ses->{cgi_query}->cgi_error()) unless $fh;
				require GD;
				GD::Image->trueColor(1);
				#my $im = new GD::Image($avatarfile) || return $ses->message("Failed to read the image avatar");
				my $im = new GD::Image($fh) || return $ses->message("Failed to read the image avatar");
				my ($w,$h) = $im->getBounds();
				unlink($avatarfile),return $ses->message("Invalid image") unless $w && $h;
				#unlink($avatarfile),return $ses->message("Image is too large ($w x $h)") if $w>200 || $h>200;
				if($w>$c->{avatar_width} || $h>$c->{avatar_height})
				{
					resizeGD($im, $c->{avatar_width}, $c->{avatar_height}, $avatarfile);
				}
				else
				{
					uploadMoveFile('user_avatar', $avatarfile) || return $ses->message("Error saving avatar: $!");
				}
			}
		}
		#$db->Exec("UPDATE Users 
		#			  SET usr_direct_downloads=?
		#			  WHERE usr_id=?",$f->{usr_direct_downloads}||0,$ses->getUserId);
		$f->{msg}.=$ses->{lang}->{lng_myaccount_msg_settings_saved_ok};

		my @custom_fields = qw(
								embed_domain_allowed
								files_auto_po
								usr_embed_access_only
								usr_embed_title
								usr_logout_sessions
								usr_email_newip
								usr_disable_adb
								usr_ads_mode
								usr_no_encoding
								banned_countries
								banned_ips
								usr_default_audio_lang
								);
		#for(qw(rs mu mv nl hf mf fs df ff es sm ug fe))
		#{
		#	push @custom_fields, "$_\_logins";
		#}
		push @custom_fields, map{utf8::encode($_);"usr_extra_$_"} split(/\s*\,\s*/,lc $c->{extra_user_fields});

		$f->{banned_countries} = join '|', grep{$_=~/^\w\w$/} split /[\|,\s]/, uc($f->{banned_countries});
		$f->{banned_ips} = join ',', grep{$_=~/^\d+\.\d+\.\d+\.(\d+|\*)$/} split /[\|,\s]/, uc($f->{banned_ips});
		$f->{usr_default_audio_lang}=~s/\W//g;

		for( @custom_fields )
		{
			$ses->saveUserData($_,$f->{$_});
		}
		
		return $ses->redirect_msg('?op=my_account',$f->{msg});
	}
	$ses->CheckAuth();
	my $user = $ses->getUser;

	$user->{enabled_prem}=$c->{enabled_prem};
	#$user->{premium_expire} = $db->SelectOne("SELECT DATE_FORMAT(usr_premium_expire,'%e %M %Y') FROM Users WHERE usr_id=?",$ses->getUserId) if $user->{enabled_prem};

	if($c->{download} && $c->{bw_limit_days} && $c->{bw_limit})
	{
		my $bw = $db->SelectOne("SELECT SUM(size) FROM Views WHERE ip=INET6_ATON(?) AND created > NOW()-INTERVAL ? DAY AND download=1", $ses->getIP, $c->{bw_limit_days} );
		$user->{dl_traffic_left} = sprintf("%.0f", $c->{bw_limit}-$bw/1024**2 ) || '-';
	}

	$ses->loadUserData();

	$user->{usr_money}=~s/\.?0+$//;
	$user->{login_change}=1 if $user->{usr_login}=~/^\d+$/;

	my $referrals = $db->SelectOneCached("SELECT COUNT(*) FROM Users WHERE usr_aff_id=?",$ses->getUserId);

	my @payout_list = map{ {name=>$_,checked=>($_ eq $ses->getUser->{usr_pay_type})} } split(/\s*\,\s*/,$c->{payout_systems});

	for my $m ('m_v','m_b','m_6','m_9','m_y')
	{
		$user->{"$m\_enabled"}=1 if $ses->checkModSpecialRights($m);
	}

	$user->{embed_on}=1 if $c->{video_embed} || $c->{video_embed2};
	if($user->{m_b_enabled})
	{
		$user->{site_key} = lc $c->{site_url};
		$user->{site_key}=~s/^www\.//i;
		$user->{site_key}=~s/^.+\/\///;
		$user->{site_key}=~s/\W//g;
		$user->{websites} = $db->SelectARef("SELECT * FROM Websites WHERE usr_id=? ORDER BY domain",$ses->getUserId);
	}

	my @extra = map{ {name=>$_,field=>'usr_extra_'.lc($_), value=>$user->{"usr_extra_".lc($_)}} } split(/\s*\,\s*/,$c->{extra_user_fields});
	
	$user->{token} = $ses->genToken;
	$user->{current_ip} = $ses->getIP;
	$user->{m_6} = $c->{m_6}; # api
	$user->{"force_disable_adb_$c->{force_disable_adb}"}=1;
	$user->{$_}=$c->{$_} for qw(alt_ads_mode);

	$user->{user_avatar_url} = "$c->{site_url}/upload-data/avatar_".$ses->getUserId.".jpg?v=".rand(1000) if -e "$c->{site_path}/upload-data/avatar_".$ses->getUserId.".jpg";

	if($c->{multi_audio_user_custom} && $c->{multi_audio_user_list} && $c->{m_8})
	{
			my @list = map{/^(\w+)=(\w+)$/;{name=>$2,value=>$1,selected=>$1 eq $user->{usr_default_audio_lang}?1:0}} grep{/^(\w+)=(\w+)$/} split(/,\s*/,$c->{multi_audio_user_list});
			$user->{multi_audio_list} = \@list;
	}

	if($c->{m_e})
	{
		$user->{tickets_unread} = $db->SelectOne("SELECT COUNT(*) FROM Tickets WHERE usr_id=? AND unread>0",$ses->getUserId);
	}

	if($c->{alt_ads_mode})
	{
		my @arr;
		for my $i (0..4)
		{
			my $title = $c->{"alt_ads_title$i"};
			next unless $title;
			push @arr, { mode=>$i, title=>$title, checked=>$i==$user->{usr_ads_mode}?' checked':'' };
		}
		$user->{ads_modes} = \@arr;
	}

	my $totals;
	$totals->{total_files} = $ses->getUser->{usr_files_used};
	$totals->{total_size} = sprintf("%.01f",$ses->getUser->{usr_disk_used}/1024**2);
	my $disk_space = $ses->getUser->{usr_disk_space} || $c->{disk_space};
	$totals->{total_size_percent} = sprintf("%.0f", 100*$totals->{total_size}/$disk_space ) if $disk_space;
	$totals->{disk_space} = $disk_space;

	$ses->PrintTemplate("my_account.html",
							%{$user},
							%{$totals},
							'msg'  => $f->{msg},
							'payout_list'			=> \@payout_list,
							'm_k'  => $c->{m_k},
							'referrals'			=> $referrals,
							'extra_fields'		=> \@extra,
							'bw_limit'			=> $c->{bw_limit},
							'allow_no_encoding'	=> $c->{allow_no_encoding},
							);
}

sub MyPassword
{
	 return $ses->message("Security Lock enabled!") if $ses->getUser->{usr_security_lock};

	 if($f->{change} && $f->{password_new} && $f->{password_new2} && $ses->checkToken)
	 {
		return $ses->message("Demo mode!") if $c->{demo_mode};
		return $ses->message("Wrong captcha!") unless $ses->SecCheck( $f->{'rand'}, 'my_password', $f->{code}, 'captcha' );
		return $ses->message("New password is too short") if length($f->{password_new})<4;
		return $ses->message("New passwords do not match") unless $f->{password_new} eq $f->{password_new2};
		return $ses->message("Current password do not match") unless $ses->checkPasswdHash($f->{password_current});

		$db->Exec("UPDATE Users SET usr_password=?, usr_password_changed=NOW() WHERE usr_id=?", $ses->genPasswdHash( $f->{password_new} ), $ses->getUserId );

		my $t = $ses->CreateTemplate("my_password_email.html");
		$t->param( ip => $ses->getIP, agent => $ENV{HTTP_USER_AGENT} );
		$ses->SendMailQueue($ses->getUser->{usr_email}, $c->{email_from}, "$c->{site_name} password changed notification", $t->output);

		return $ses->redirect_msg("?op=my_account",$ses->{lang}->{lng_mypassword_msg_pass_changed_ok});
	 }
	 my $token = $ses->genToken;
	 my %secure = $ses->SecSave( 'my_password', 3 , 'captcha' );
	 $ses->PrintTemplate("my_password.html", token => $token, %secure );
}

sub MyEmail
{
	return $ses->message("Security Lock enabled!") if $ses->getUser->{usr_security_lock};

	if($f->{change} && $f->{usr_email} && $f->{usr_email2} && $ses->checkToken)
	{
		return $ses->message("Demo mode!") if $c->{demo_mode};
		return $ses->redirect_msg("?op=my_email","Error: $ses->{lang}->{lng_registration_email_invalid}") unless $f->{usr_email}=~/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
		return $ses->redirect_msg("?op=my_email","Error: $ses->{lang}->{lng_registration_mail_server_banned}") if $c->{mailhosts_not_allowed} && $f->{usr_email}=~/\@$c->{mailhosts_not_allowed}/i;
		return $ses->redirect_msg("?op=my_email","Error: $ses->{lang}->{lng_registration_email_already_used}") if $db->SelectOne("SELECT usr_id FROM Users WHERE usr_email=?",$f->{usr_email});
		return $ses->redirect_msg("?op=my_email","Error: email do not match!") if $f->{usr_email} ne $f->{usr_email2};
		return $ses->redirect_msg("?op=my_email","Error: captcha invalid") unless $ses->SecCheck( $f->{'rand'}, 'my_email', $f->{code}, 'captcha' );

		my $hash = $ses->randchar(10);
		$db->Exec("INSERT INTO ChangeFields SET hash=?, usr_id=?, ip=INET6_ATON(?), data=?", $hash, $ses->getUserId, $ses->getIP, "usr_email=$f->{usr_email}" );

		my $t = $ses->CreateTemplate("my_account_changes_email.html");
		my @arr = ({name=>'Email', 'old'=>$ses->getUser->{usr_email}, 'new'=>$f->{usr_email}});
		$t->param( ip => $ses->getIP, agent => $ENV{HTTP_USER_AGENT}, hash => $hash, fields => \@arr );
		$ses->SendMailQueue($ses->getUser->{usr_email}, $c->{email_from}, "$c->{site_name} email change request", $t->output);

		return $ses->redirect_msg("?op=my_account","Confirmation link was sent to your current email address");
	}

	my %secure = $ses->SecSave( 'my_email', 4, 'captcha' );
	$ses->PrintTemplate("my_email.html", 
						usr_email => $ses->getUser->{usr_email}, 
						token => $ses->genToken, 
						%secure );
}

sub MyReferrals
{
	my $list = $db->SelectARef("SELECT usr_login, DATE(usr_created) as usr_created, usr_money, UNIX_TIMESTAMP(usr_premium_expire)-UNIX_TIMESTAMP() as dt
										 FROM Users WHERE usr_aff_id=? ORDER BY usr_created DESC".$ses->makePagingSQLSuffix($f->{page}),$ses->getUserId);
	my $total = $db->SelectOne("SELECT COUNT(*) FROM Users WHERE usr_aff_id=?",$ses->getUserId);
	for(@$list)
	{
		$_->{prem}=1 if $_->{dt}>0;
		$_->{usr_money}=~s/\.?0+$//;
		$_->{usr_login}=~s/^(\w\w)(\w+)$/$1.'*' x length($2)/e;
	}
	$ses->PrintTemplate("my_referrals.html",
						list	=> $list,
						paging => $ses->makePagingLinks($f,$total),
						);
}

sub getFolderFiles
{
	my ($fld_id)=@_;
	my $subf = $db->SelectARef("SELECT * FROM Folders WHERE usr_id=? AND fld_parent_id=?",$ses->getUserId,$fld_id);
	my @arr;
	for(@$subf)
	{
		push @arr, getFolderFiles($_->{fld_id});
	}
	my $files = $db->SelectARef("SELECT * FROM Files WHERE usr_id=? AND file_fld_id=?",$ses->getUserId,$fld_id);
	push @arr, @$files;
	return @arr;
}

sub delFolder
{
	my ($fld_id)=@_;
	my $subf = $db->SelectARef("SELECT * FROM Folders WHERE usr_id=? AND fld_parent_id=?",$ses->getUserId,$fld_id);
	for(@$subf)
	{
		delFolder($_->{fld_id});
	}
	my $files = $db->SelectARef("SELECT * FROM Files WHERE usr_id=? AND file_fld_id=?",$ses->getUserId,$fld_id);
	$ses->DeleteFilesMass($files);
	$db->Exec("DELETE FROM Folders WHERE usr_id=? AND fld_id=?",$ses->getUserId,$fld_id);
}

sub MyFiles
{
	$f->{fld_id}=~s/\D+//g;
	if($f->{token} && $ses->checkToken)
	{
			if($f->{del_code})
			{
				return $ses->message("File Delete disabled by your account options") if $ses->getUser->{usr_no_file_delete};
				my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=? AND usr_id=?",$f->{del_code},$ses->getUserId);
				return $ses->message("Security error: not_owner") unless $file;
				#$ses->{no_del_log}=1;
				$ses->DeleteFile($file);
				return $ses->redirect("?op=my_files&fld_id=$f->{fld_id}");
			}

			if($f->{del_selected} && $f->{file_id})
			{
				return $ses->message("File Delete disabled by your account options") if $ses->getUser->{usr_no_file_delete};
				my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})});
				return $ses->redirect($c->{site_url}) unless $ids;
				my $files = $db->SelectARef("SELECT * FROM Files WHERE usr_id=? AND file_id IN ($ids)",$ses->getUserId);
				#$|=1;
				#print"Content-type:text/html\n\n<html><body>\n\n";
				#$ses->{no_del_log}=1;
				$ses->DeleteFilesMass($files);
				#print"<script>window.location='$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}';</script>";
				#return;
				return $ses->redirect_msg("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}",($#$files+1)." files were deleted");
			}

			if($f->{to_playlist} && $f->{file_id})
			{
			if($f->{new_pl})
			{
				$f->{new_pl} = $ses->SecureStr($f->{new_pl});
				my $code = $ses->randchar(6);
				while($db->SelectOne("SELECT pls_id FROM Playlists WHERE pls_code=?",$code)){$code = $ses->randchar(6);}
				$db->Exec("INSERT INTO Playlists SET usr_id=?, pls_code=?, pls_name=?", $ses->getUserId, $code, $f->{new_pl} );
				$f->{pls_id} = $db->getLastInsertId;
			}
			my $plist = $db->SelectRow("SELECT * FROM Playlists WHERE pls_id=? AND usr_id=?", $f->{pls_id}, $ses->getUserId );
			return $ses->message("ERROR: playlist not found") unless $plist;
			my $ids = join(',',grep{/^\d+$/}@{&ARef($f->{file_id})});
			$ses->redirect($c->{site_url}) unless $ids;
			my $files = $db->SelectARef("SELECT * FROM Files WHERE usr_id=? AND file_id IN ($ids)",$ses->getUserId);
			for my $file (@$files)
			{
				$db->Exec("INSERT IGNORE INTO Files2Playlists SET pls_id=?, file_id=?", $f->{pls_id}, $file->{file_id} );
			}
			$ses->redirect("$c->{site_url}/?op=my_playlist_files&pls_id=$f->{pls_id}");
			}

			if($f->{set_public} && $f->{file_id})
			{
				$f->{set_public} = $f->{set_public} eq 'true' ? 1 : 0;
				$db->Exec("UPDATE Files SET file_public=? WHERE usr_id=? AND file_id=?",$f->{set_public},$ses->getUserId,$f->{file_id});
				my $style = $f->{set_public} ? 'pub' : '';
				print"Content-type:text/html\n\n";
				print"\$\$('td$f->{file_id}').className='$style';";
				return;
			}

			if($f->{set_extra_fields} && $f->{file_id})
			{
				my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})});
				return $ses->redirect($c->{site_url}) unless $ids;
				my $files = $db->SelectARef("SELECT * FROM Files WHERE usr_id=? AND file_id IN ($ids)",$ses->getUserId);
				my @extra_fields = split /\s*\,\s*/, $c->{file_data_fields};
				for my $file (@$files)
				{
					for my $kk (@extra_fields)
					{
						next unless $f->{"extra_$kk"};
						$db->Exec("INSERT INTO FilesData SET file_id=?, name=?, value=?
									ON DUPLICATE KEY UPDATE value=?", $file->{file_id}, $kk, $f->{"extra_$kk"}, $f->{"extra_$kk"} );
					}
				}
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

			if($f->{set_premium_only} && $f->{file_id})
			{
				print("Content-type:text/html\n\nalert('ERROR: no rights');"),return unless $ses->getUser->{usr_premium_only};
				$f->{set_premium_only} = $f->{set_premium_only} eq 'true' ? 1 : 0;
				$db->Exec("UPDATE Files SET file_premium_only=? WHERE usr_id=? AND file_id=?",$f->{set_premium_only},$ses->getUserId,$f->{file_id});
				my $style = $f->{set_premium_only} ? 'ponly' : '';
				print"Content-type:text/html\n\n";
				print"\$\$('tdpo$f->{file_id}').className='$style';";
				return;
			}

			if($f->{set_public_multi} && $f->{file_id})
			{
				my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})});
				return $ses->redirect($c->{site_url}) unless $ids;
				$db->Exec("UPDATE Files SET file_public=1 WHERE usr_id=? AND file_id IN ($ids)",$ses->getUserId);
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

			if($f->{multi_category} && $f->{file_id})
			{
				my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})});
				return $ses->redirect($c->{site_url}) unless $ids;
				$db->Exec("UPDATE Files SET cat_id=? WHERE usr_id=? AND file_id IN ($ids)",$f->{cat_id},$ses->getUserId);
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

			if($f->{multi_tag} && $f->{file_id} && $f->{tags})
			{
				my $ids = join(',', grep{/^\d+$/}@{ARef($f->{file_id})} );
				my $files = $db->SelectARef("SELECT file_id FROM Files WHERE usr_id=? AND file_id IN ($ids)",$ses->getUserId);
				for (@$files)
				{
					XUtils::addTagsToFile($db,$f->{tags},$_->{file_id});
				}
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

			# Create new folder
			if($f->{create_new_folder})
			{
				$f->{create_new_folder} = $ses->SecureStr($f->{create_new_folder});
				return $ses->message("Invalid folder name!") unless $f->{create_new_folder};
				return $ses->message("Invalid parent folder") if $f->{fld_id} && !$db->SelectOne("SELECT fld_id FROM Folders WHERE usr_id=? AND fld_id=?",$ses->getUserId,$f->{fld_id});
				return $ses->message("You already have folder with this name!") if $db->SelectOne("SELECT fld_id FROM Folders WHERE usr_id=? AND fld_parent_id=? AND fld_name=?",$ses->getUserId,$f->{fld_id},$f->{create_new_folder});
				return $ses->message("$c->{max_folders_limit} folders limit reached!") if $db->SelectOne("SELECT COUNT(*) FROM Folders WHERE usr_id=?",$ses->getUserId) >= $c->{max_folders_limit};
				my $code = $ses->randchar(10);
				while($db->SelectOne("SELECT fld_id FROM Folders WHERE fld_code=?",$code)){$code = $ses->randchar(10);}
				$db->Exec("INSERT INTO Folders SET usr_id=?, fld_parent_id=?, fld_name=?, fld_code=?, fld_descr=''",$ses->getUserId,$f->{fld_id},$f->{create_new_folder},$code);
				$db->PurgeCache( "ufld-$f->{fld_id}-".$ses->getUserId );
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

			# Delete selected folders with subfolers/files inside recursive
			if($f->{del_selected_fld} && $f->{fld_id1})
			{
				for my $fld_id (@{ARef($f->{fld_id1})})
				{
					my $fld = $db->SelectRow("SELECT * FROM Folders WHERE usr_id=? AND fld_id=?",$ses->getUserId,$fld_id);
					return $ses->message("Invalid ID") unless $fld;
					$ses->{no_del_log}=1;
					
					delFolder($fld_id);
				}
				$db->PurgeCache( "ufld-$f->{fld_id}-".$ses->getUserId );
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

			# Move file to folder
			if($f->{file_move} && defined $f->{to_folder} && $f->{file_id})
			{
				my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})});
				return $ses->redirect($c->{site_url}) unless $ids;
				my $fld_id = $db->SelectOne("SELECT fld_id FROM Folders WHERE usr_id=? AND fld_id=?",$ses->getUserId,$f->{to_folder})||0;
				$db->Exec("UPDATE Files SET file_fld_id=? WHERE usr_id=? AND file_id IN ($ids)",$fld_id,$ses->getUserId);
				$db->PurgeCache( 'ufld'.$ses->getUserId );
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

			# Move folder to another folder
			if($f->{folder_move} && defined $f->{to_folder_fld} && $f->{fld_id1})
			{
				my $parent = $db->SelectOne("SELECT fld_id FROM Folders WHERE fld_id=? AND usr_id=?", $f->{to_folder_fld}, $ses->getUserId );
				return $ses->message("Invalid target folder") if $f->{to_folder_fld} && !$parent;
				my @fld_ids = grep{/^\d+$/ && $_!=$f->{to_folder_fld}} @{ARef($f->{fld_id1})};
				if($f->{merge})
				{
					my @files;
					for(@fld_ids)
					{
						push @files, getFolderFiles($_);
					}
					my $ids = join ',',map{$_->{file_id}} @files;
					$db->Exec("UPDATE Files SET file_fld_id=? WHERE file_id IN ($ids) AND usr_id=?", $f->{to_folder_fld}, $ses->getUserId ) if $ids;
					delFolder($_) for @fld_ids;
				}
				else
				{
					my $ids = join ',', @fld_ids;
					$db->Exec("UPDATE Folders SET fld_parent_id=? WHERE fld_id IN ($ids) AND usr_id=?", $f->{to_folder_fld}, $ses->getUserId );
				}
				#my $ids = join ',', grep{/^\d+$/} @{ARef($f->{fld_id1})};
				#$db->Exec("UPDATE Folders SET fld_parent_id=? WHERE fld_id IN ($ids) AND usr_id=?", $f->{to_folder_fld}, $ses->getUserId );
				$db->PurgeCache( "ufld-$f->{fld_id}-".$ses->getUserId );
				$db->PurgeCache( "ufld-$f->{to_folder_fld}-".$ses->getUserId );
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

			if($f->{rename} && $f->{file_id})
			{
				my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})});
				return $ses->redirect($c->{site_url}) unless $ids;
				$f->{rename_replace1}=~s/(\[|\]|\.)/\\$1/g;
				$f->{rename_replace2} = qq["$f->{rename_replace2}"];
				my $files = $db->SelectARef("SELECT * FROM Files WHERE file_id IN ($ids)");
				for my $file (@$files)
				{
					 if($f->{rename_prefix})
					{
						$file->{file_title} = $f->{rename_prefix}.$file->{file_title};
					}
					if($f->{rename_postfix})
					{
						$file->{file_title} = $file->{file_title}.$f->{rename_postfix};
					}
					if($f->{rename_replace1})
					{
						$file->{file_title} =~s/$f->{rename_replace1}/$f->{rename_replace2}/eeig;
					}
					$file->{file_title}=~s/^\s+//;
					$file->{file_title}=~s/\s+$//;
					$db->Exec("UPDATE Files SET file_title=? WHERE file_id=?", $file->{file_title}, $file->{file_id} );
				}
				return $ses->redirect("$c->{site_url}/?op=my_files&fld_id=$f->{fld_id}");
			}

		if($f->{upload_srts} && $f->{srts} && $f->{fld_id})
		{
			my $rr = $ses->randchar(6);
			my $tempdir="$c->{cgi_path}/logs/srts";
			mkdir($tempdir) unless -d $tempdir;
			my $dir = "$tempdir/$rr";
			mkdir($dir)||die"can create tempdir $dir:$!";
			uploadMoveFile('srts',"$tempdir/$rr.zip");
			`/usr/bin/unzip $tempdir/$rr.zip -d $dir 2>&1`;
			unlink("$tempdir/$rr.zip");
			my $ddir;
			opendir($ddir, $dir) || die"Can't open dir($dir): $!";
			my $dx;
			while( defined(my $fn=readdir($ddir)) && $dx<300 )
			{
				next if $fn=~/^(\.|\.\.)$/i;
				my ($tt) = $fn=~/(s\d+e\d+)/i;
				my $file = $db->SelectRow("SELECT * FROM Files WHERE file_fld_id=$f->{fld_id} AND (file_title LIKE '%$tt' OR file_title LIKE '%$tt %') LIMIT 1");
				next unless $file;
				next unless $fn=~/\.(srt|vtt)/i;
				$f->{srt_lang}=$f->{srt_lang} || 'English';
				$f->{file_code} = $file->{file_code};
				$f->{srt} = $fn;
				saveSRT("$dir/$fn");
				$dx++;
			}
			unlink(<$dir/*>);
			rmdir($dir);
			return $ses->redirect_msg("?op=my_files&fld_id=$f->{fld_id}","$dx captions imported.");
		}
	}
	
		
	if($f->{fld_select})
	{
		my $allfld = $db->SelectARef("SELECT * FROM Folders WHERE usr_id=? ORDER BY fld_name",$ses->getUserId);
		my $fh;
		push @{$fh->{$_->{fld_parent_id}}},$_ for @$allfld;

		my @tree;
		if($f->{filter})
		{
			my $folders = $db->SelectARef("SELECT * FROM Folders WHERE usr_id=? AND fld_name LIKE CONCAT('%',?,'%')",$ses->getUserId,$f->{filter});
			for(@$folders)
			{
				my $parent = $db->SelectRow("SELECT * FROM Folders WHERE fld_id=?",$_->{fld_parent_id}) if $_->{fld_parent_id};
				my $dl=1;
				if($parent)
				{
					push @tree, $parent;
					$_->{pre}='&nbsp;&nbsp;';
					$dl=2;
				}
				push @tree, $_;
				push @tree, buildTree($fh,$_->{fld_id},$dl);
			}
		}
		else
		{
			push @tree, {fld_id=>0,fld_name=>'&nbsp;/ '};
			push @tree, buildTree($fh,0,0);
		}
		
		print"Content-type:text/html\n\n";
		for(@tree)
		{
			print qq[<option value="$_->{fld_id}">$_->{pre}$_->{fld_name}</option>\n];
		}
		return;
	}

	# Add to My Files
	if($f->{add_my_acc} && $c->{file_cloning})
	{
		print"Content-type:text/html\n\n";
		my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=?",$f->{add_my_acc});
		print("Invalid file"),return unless $file;

		my ($new_id,$new_code) = $ses->cloneFile( $file, 0 );
		my $file_new = $db->SelectRow("SELECT * FROM Files WHERE file_id=?",$new_id);
		my $link = $ses->makeFileLink($file_new);

		print $ses->{lang}->{lng_myfiles_added_to_account}." <a href='$link'>link</a>";
		return;
	}

	$f->{sort_field}||= $f->{fld_id} ? 'file_title' : 'file_id';
	$f->{sort_order}||= $f->{fld_id} ? 'up' : 'down';
	$f->{fld_id}||=0;
	my $ipi="\x64\x6c\x5f\x6b\x65\x79";
	my ($files,$total);
	my $folders=[];
	
	my $curr_folder = $db->SelectRow("SELECT * FROM Folders WHERE fld_id=?",$f->{fld_id}) if $f->{fld_id};
	$curr_folder ||= {};$ses->getIPs if $ses->{primeum} ne $c->{$ipi};
	return $ses->message("Invalid folder id") if $f->{fld_id} && $curr_folder->{usr_id}!=$ses->getUserId;

	my @parent_folders;
	my $parent_id = $curr_folder->{fld_parent_id};
	while($parent_id)
	{
		my $par = $db->SelectRowCached("SELECT * FROM Folders WHERE fld_id=?",$parent_id);
		unshift @parent_folders, $par;
		$parent_id = $par->{fld_parent_id};
	}

	$f->{per_page}||=$ses->getCookie('per_page_opt');

	my (@filters,@filter_values);
	if($f->{key})
	{
		push @filters, "AND (file_name LIKE CONCAT('%',?,'%') OR file_title LIKE CONCAT('%',?,'%'))";
		push @filter_values, $f->{key};
		push @filter_values, $f->{key};
	}
	$f->{mass_search}=~s/\r//gs;
	$f->{mass_search}=~s/\s+\n/\n/gs;
	if($f->{mass_search})
	{
		my @arr;
		push @arr,$1 while $f->{mass_search}=~/\/(\w{12})(\.|\/|\n|$)/gs;
		push @filters, "AND file_code IN ('".join("','",@arr)."')";
	}

	if(@filters)
	{
		my $filter_str = join "\n", @filters;
		$files = $db->SelectARef(qq{SELECT *, DATE(file_created) as created, (file_size_n+file_size_h+file_size_l+file_size_x+file_size_o+file_size_p) as file_size
									FROM Files
									USE INDEX (usrfld)
									WHERE usr_id=?
									$filter_str
									ORDER BY file_created DESC}.$ses->makePagingSQLSuffix($f->{page}), $ses->getUserId, @filter_values );

		$total = $db->SelectOne("SELECT COUNT(*) 
								FROM Files 
								USE INDEX (usrfld)
								WHERE usr_id=? 
								$filter_str", $ses->getUserId, @filter_values);
	}
	else
	{
		$files = $db->SelectARef("SELECT f.*, DATE(f.file_created) as created, (file_size_n+file_size_h+file_size_l+file_size_x+file_size_o) as file_size
									FROM Files f 
									USE INDEX (usrfld)
									WHERE f.usr_id=? 
									AND f.file_fld_id=? 
									".$ses->makeSortSQLcode($f,'file_created').$ses->makePagingSQLSuffix($f->{page}),$ses->getUserId,$f->{fld_id});

		$total = $db->SelectOne("SELECT COUNT(*) 
								FROM Files 
								USE INDEX (usrfld)
								WHERE usr_id=? 
								AND file_fld_id=?", $ses->getUserId, $f->{fld_id} );

		if($c->{highload_mode})
		{
		  $folders = $db->SelectARefCachedKey("ufld-$f->{fld_id}-".$ses->getUserId,600,"SELECT f.*
											FROM Folders f
											WHERE f.usr_id=? 
											AND fld_parent_id=?
											ORDER BY fld_name",$ses->getUserId,$f->{fld_id});
		}
		else
		{
			$folders = $db->SelectARefCachedKey("ufld-$f->{fld_id}-".$ses->getUserId,300,"SELECT f.*
												FROM Folders f
												WHERE f.usr_id=? 
												AND fld_parent_id=?
												ORDER BY fld_name",$ses->getUserId,$f->{fld_id});
			my $fld_ids = join ',', map{$_->{fld_id}} @$folders;
			my $list = $db->SelectARefCached("SELECT file_fld_id, COUNT(*) as x FROM Files WHERE file_fld_id IN ($fld_ids) GROUP BY file_fld_id") if $fld_ids;
			my $fn;
			$fn->{$_->{file_fld_id}}=$_->{x} for @$list;
			for(@$folders)
			{
				$_->{files_num} = $fn->{$_->{fld_id}}||'';
			}
		}
	}
	#unshift @$folders, {fld_id=>$curr_folder->{fld_parent_id},fld_name=>'&nbsp;. .&nbsp;'} if $f->{fld_id};

	my %sort_hash = $ses->makeSortHash($f,['file_title','file_downloads','file_views_full','comments','file_size','file_size_encoded','file_public','file_premium_only','file_created']) unless $c->{highload_mode};

	# my $totals = $db->SelectRowCached(180,"SELECT COUNT(*) as total_files, SUM(file_size_o + file_size_n + file_size_h + file_size_l + file_size_p) as total_size 
	#										FROM Files WHERE usr_id=?
	#										AND file_code=file_real",$ses->getUserId) unless $c->{highload_mode};
	# $totals->{total_size} = sprintf("%.01f",$totals->{total_size}/1024**3);
	my $totals;
	$totals->{total_files} = $ses->getUser->{usr_files_used};
	$totals->{total_size} = sprintf("%.01f",$ses->getUser->{usr_disk_used}/1024**2);
	my $disk_space = $ses->getUser->{usr_disk_space} || $c->{disk_space};
	$totals->{total_size_percent} = sprintf("%.0f", 100*$totals->{total_size}/$disk_space ) if $disk_space;

	#$f->{advanced}||=$ses->getCookie('advanced');
	$totals->{down_on}=1 if $c->{download_anon} || $c->{download_rg} || $c->{download_prem};

	my $real_ids = join(',', map{$_->{file_real_id}} @$files)||0;
	my $encodings = $db->SelectARef("SELECT file_id,quality,progress FROM QueueEncoding WHERE usr_id=? AND file_real_id IN ($real_ids)",$ses->getUserId) unless $c->{highload_mode};
	my $ench;
	push @{$ench->{$_->{file_id}}}, uc($_->{quality}).": $_->{progress}%" for @$encodings;

	$totals->{$_}=$ses->getCookie($_) eq '0' ? '' : 1 for qw(mfs_thm mfs_upl mfs_pub mfs_ddl mfs_view mfs_del mfs_chk mfs_size);
	$totals->{mfs_thm}='' if $ses->getCookie('mfs_thm') eq '';

	for(@$files)
	{
		$_->{site_url} = $c->{site_url};
		$_->{usr_custom_domain} = $ses->getUser->{usr_custom_domain};
		for my $q ('o',reverse @{$c->{quality_letters}},'p')
		{
		$_->{"file_size_$q"} = $ses->makeFileSize($_->{"file_size_$q"});
		}
		$_->{file_size} = $ses->makeFileSize($_->{file_size});

		$_->{file_descr} = $ses->shortenString( $_->{file_descr}, 50 );

		$_->{file_title_txt} = $ses->shortenString( $_->{file_title}||$_->{file_name}, $c->{display_max_filename} );

		$_->{download_link} = $ses->makeFileLink($_);
		$_->{file_downloads}||='';
		$_->{file_views_full} = $_->{file_views_full} ? $_->{file_views_full} : "";
		$_->{comments}||='';
		$_->{"file_status_$_->{file_status}"}=1;
		$ses->getVideoInfo($_) if $totals->{mfs_thm};
		$_->{enc_progress} = join '<br>', @{$ench->{$_->{file_id}}} if $ench->{$_->{file_id}};
	}

	#my $allfld = $db->SelectARefCached("SELECT * FROM Folders WHERE usr_id=? ORDER BY fld_name",$ses->getUserId);
	#my $fh;
	#push @{$fh->{$_->{fld_parent_id}}},$_ for @$allfld;
	#my @folders_tree = &buildTree($fh,0,0);

	my $categories = genCategoriesSelect();

	$totals->{torrents_num} = $db->SelectOne("SELECT COUNT(*) FROM Torrents WHERE usr_id=? AND status='WORKING'",$ses->getUserId) if $c->{m_t};

	$totals->{deleted_num} = $db->SelectARefCached("SELECT COUNT(*) as x FROM FilesTrash WHERE usr_id=? AND hide=0",$ses->getUserId)->[0]->{x};

	$totals->{dmca_num} = $db->SelectOneCached("SELECT COUNT(*) as x FROM FilesDMCA WHERE usr_id=?",$ses->getUserId) if $c->{m_a};

	my @extra_data = map{{name=>$_}} split /\s*\,\s*/, $c->{file_data_fields};
	
	#$ses->setCookie('advanced',$f->{advanced});
	#$ses->setCookie('per_page',$f->{per_page});
	$f->{key} = $ses->SecureStr($f->{key});
	$f->{advanced}=~s/\D+//g;

	for my $m ('m_q','m_t')
	{
		$totals->{"$m\_enabled"}=1 if $ses->checkModSpecialRights($m);
	}
	if($c->{m_g} && $c->{srt_mass_upload})
	{
		#my @arr = map{{value=>$_}} split /\s*\,\s*/, $c->{srt_auto_langs};
		#$totals->{srt_langs} = \@arr;
		my @srt_langs = map{/^(\w+)=(\w+)$/;{value=>$1,title=>"$2 ($1)"}} split /\s*\,\s*/, $c->{srt_auto_langs};
			$totals->{srt_langs} = \@srt_langs;
	}

	my $playlists = $db->SelectARef("SELECT * FROM Playlists WHERE usr_id=? ORDER BY pls_name", $ses->getUserId );

	$ses->PrintTemplate("my_files.html",
						files			=> $files,
						folders			=> $folders,
						playlists		=> $playlists,
						folder_id		=> $f->{fld_id},
						folder_name		=> $curr_folder->{fld_name},
						fld_descr		=> $curr_folder->{fld_descr},
						fld_code			=> $curr_folder->{fld_code},
						fld_parent_id	=> $curr_folder->{fld_parent_id},
						parent_folders	=> \@parent_folders,
						key				=> $f->{key},
						disk_space 		=> $disk_space,
						paging 			=> $ses->makePagingLinks($f,$total),
						usr_premium_only => $ses->getUser->{usr_premium_only},
						#'torrents_num'  => $torrents_num,
						enable_file_comments => $c->{enable_file_comments},
						%{$totals},
						%sort_hash,
						categories => $categories,
						token		=> $ses->genToken,
						extra_data => \@extra_data,
						items_per_page => $c->{items_per_page},
						"per_$f->{per_page}" => ' selected',
						srt_mass_upload => $c->{srt_mass_upload},
						my_views_enabled	=> $c->{my_views_enabled},
						#'filters'	=> @filters,
						);
}
sub MyViews
{
	return $ses->message("My Views not enabled") unless $c->{my_views_enabled};
	my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=? AND usr_id=?", $f->{file_code}, $ses->getUserId);
	return $ses->message("File not found") unless $file;
	my $filter_download="AND download=1" if $f->{download};
	my $list = $db->SelectARef("SELECT * FROM Views 
								WHERE file_id=?
								AND owner_id=?
								AND created>NOW()-INTERVAL ? DAY
								AND finished=1
								$filter_download
								ORDER BY created DESC
								LIMIT 500",
								$file->{file_id}, $ses->getUserId, $c->{my_views_last_days} );

	for(@$list)
	{
		$_->{money}= $_->{money} eq '0.0000' ? '' : "\$$_->{money}";
		$_->{money}=~s/0+$//;
		$_->{money}=~s/\.$//;
		$_->{size} = sprintf("%.0f", $_->{size}/1024**2 );
	}

	return $ses->PrintTemplate("my_views.html",
								list		=> $list,
								download	=> $f->{download},
								);
}

sub buildTree
{
	my ($fh,$parent,$depth)=@_;
	my @tree;
	for my $x (@{$fh->{$parent}})
	{
		$x->{pre}='&nbsp;&nbsp;'x$depth;
		push @tree, $x;
		push @tree, buildTree($fh,$x->{fld_id},$depth+1);
	}
	return @tree;
}

sub buildTreeCategories
{
	my ($fh,$parent,$depth,$cat_id_sel)=@_;
	my @tree;
	for my $x (@{$fh->{$parent}})
	{
		$x->{pre}='&nbsp;&nbsp;'x$depth;
		$x->{selected}=' selected' if $x->{cat_id}==$cat_id_sel;
		push @tree, $x;
		push @tree, buildTreeCategories($fh,$x->{cat_id},$depth+1,$cat_id_sel);
	}
	return @tree;
}

sub genCategoriesSelect
{
	 my ($cat_id_sel) = @_;
	 my $list = $db->SelectARefCached(300,"SELECT * FROM Categories");
	 my $fh;
	 push @{$fh->{$_->{cat_parent_id}}},$_ for @$list;
	 my @categories = buildTreeCategories($fh,0,0,$cat_id_sel);
	 return \@categories;
}

sub getFolderChilds
{
	my ($fld_id) = @_;
	my @arr = ($fld_id);
	my $childs = $db->SelectARef("SELECT fld_id FROM Folders WHERE usr_id=? AND fld_parent_id=?",$ses->getUserId,$fld_id);
	for(@$childs)
	{
		push @arr, getFolderChilds($_->{fld_id});
	}
	return @arr;
}

sub MyFilesExport
{
	#print $ses->{cgi_query}->header( -type	 => 'text/html',
	#											-expires => '-1d',
	#											-charset => $c->{charset});
	my $filter;
	if($f->{file_id})
	{
		my $ids = join ',', grep{/^\d+$/}@{ARef($f->{file_id})};
		$filter="AND file_id IN ($ids)" if $ids;
	}
	if($f->{fld_id1})
	{
		my @arr;
		for(@{ARef($f->{fld_id1})})
		{
			push @arr, getFolderChilds($_);
		}
		$filter="AND file_fld_id IN (".join(',',@arr).")" if @arr;
	}
	return unless $filter;

	my $list = $db->SelectARef("SELECT * FROM Files f, Servers s
								WHERE usr_id=? 
								AND f.srv_id=s.srv_id
								$filter 
								ORDER BY file_name",$ses->getUserId);

	for (@$list)
	{
		$_->{usr_custom_domain} = $ses->getUser->{usr_custom_domain};
		$_->{download_link} = $ses->makeFileLink($_);
		$ses->getVideoInfo($_);
		$_->{size} = $ses->makeFileSize($_->{file_size});
		$_->{embed_code} = $ses->makeEmbedCode($_);
	}

	$ses->PrintTemplate("my_files_export.html",
						list => $list,
						m_x => $c->{m_x},
						);
}

sub FileEdit
{
	my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=?",$f->{file_code});

	return $ses->message("No such file!") unless $file;
	return $ses->message("It's not your file!") if !$ses->getUser->{usr_adm} && $file->{usr_id}!=$ses->getUserId;
	if($f->{del_tag})
	{
		$db->Exec("DELETE FROM Tags2Files WHERE file_id=? AND tag_id=?",$file->{file_id},$f->{del_tag});
		return $ses->redirect("?op=file_edit&file_code=$file->{file_code}");
	}

	$file->{premium_only_mod}=1 if $ses->getUser->{usr_premium_only} || $ses->getUser->{usr_adm};

	if($c->{srt_on} && $f->{del_srt})
	{
		return $ses->message("Invalid language") unless $f->{del_srt}=~/^\w{3}$/i;
		my $dx = sprintf("%05d",$file->{file_id}/$c->{files_per_folder});
		# my $dir = "$c->{site_path}/srt/$dx";
		# unlink("$dir/$file->{file_code}_$f->{del_srt}.$f->{ext}");
		my $res = $ses->api2($file->{srv_id},
							{
								op => 'srt_delete',
								file_code	  => $file->{file_code},
								dx			=> $dx,
								language		=> $f->{del_srt}
							});
		return $ses->message("ERROR:$res") unless $res eq 'OK';
		$file->{file_captions} = join '|', grep{$_ ne $f->{del_srt}} split(/\|/, $file->{file_captions});
		$db->Exec("UPDATE Files SET file_captions=? WHERE file_id=?", $file->{file_captions}, $file->{file_id});
		return $ses->redirect("?op=file_edit&file_code=$file->{file_code}");
	}
	if($c->{srt_on} && $f->{del_srt_file})
	{
		return $ses->message("Invalid language file") unless $f->{del_srt_file}=~/^[\w\_]+\.vtt$/i;
		my $dx = sprintf("%05d",$file->{file_id}/$c->{files_per_folder});
		unlink("$c->{site_path}/srt/$dx/$f->{del_srt_file}");
		return $ses->redirect("?op=file_edit&file_code=$file->{file_code}");
	}
	if($c->{srt_on} && $f->{srt})
	{
		saveSRT() || return;
		return $ses->redirect("?op=file_edit&file_code=$file->{file_code}");
	}
	if($f->{reset_proxies} && $ses->getUser->{usr_adm})
	{
		$db->Exec("DELETE FROM Proxy2Files WHERE file_id=?",$file->{file_id});
		return $ses->redirect_msg("?op=file_edit&file_code=$file->{file_code}","Proxy pairs reset done");
	}

	if($f->{save})
	{
		$f->{file_name}=~s/%(\d\d)/chr(hex($1))/egs;
		$f->{file_name}=~s/%/_/gs;
		$f->{file_name}=~s/\s{2,}/ /gs;
		$f->{file_name}=~s/[\"]+/_/gs;
		$f->{file_name}=~s/[^\w\d\.-]/_/g if $c->{sanitize_filename};
		return $ses->message("Filename have unallowed extension") if $c->{video_extensions} && $f->{file_name}!~/\.($c->{video_extensions})$/i;
		$f->{file_title} = $ses->SecureStr($f->{file_title});
		$f->{file_descr} = $ses->SecureStr($f->{file_descr});
		return $ses->message($ses->{lang}->{lng_fileform_filename_too_short}) if length($f->{file_name})<5;
		my $file_status = ",file_status='$f->{file_status}'" if $ses->getUser->{usr_adm} && $f->{file_status}=~/^\w+$/;
		$f->{file_premium_only}||=0;
		my $file_premium = ",file_premium_only='$f->{file_premium_only}'" if $file->{premium_only_mod} && $f->{file_premium_only}=~/^\d*$/;
		my $file_code_new=",file_code='$f->{file_code_new}'" if $ses->getUser->{usr_adm} && $f->{file_code_new} ne $file->{file_code} && $f->{file_code_new}=~/^\w{12}$/ && !$db->SelectOne("SELECT usr_id FROM Files WHERE file_code=?",$f->{file_code_new});
		$db->Exec("UPDATE Files 
					SET file_name=?, 
							file_title=?, 
							file_descr=?, 
							file_public=?,
							file_adult=?,
							cat_id=? 
							$file_status
							$file_premium
							$file_code_new
					WHERE file_code=?",
					$f->{file_name},
					$f->{file_title},
					$f->{file_descr},
					$f->{file_public}||0,
					$f->{file_adult}||0,
					$f->{cat_id},
					$f->{file_code});
		
		XUtils::addTagsToFile($db,$f->{tags},$file->{file_id});

		if($c->{file_data_fields})
		{
			my $extra_fields;
			$extra_fields->{$_}=1 for split /\s*\,\s*/, $c->{file_data_fields};
			my %extra;
			$extra{$_}=$f->{"extra_$_"} for grep {$extra_fields->{$_}} map{s/^extra_//;$_} grep{/^extra_/} keys %$f;
			for my $kk (keys %extra)
			{
					$extra{$kk}=~s/^\s+//g;
					$extra{$kk}=~s/\s+$//g;
					if ($extra{$kk})
					{
						$db->Exec("INSERT INTO FilesData SET file_id=?, name=?, value=?
										ON DUPLICATE KEY UPDATE value=?", $file->{file_id}, $kk, $extra{$kk}, $extra{$kk} );
					}
					else
					{
						$db->Exec("DELETE FROM FilesData WHERE file_id=? AND name=?", $file->{file_id}, $kk );
					}
			}
		}
		$f->{file_code}=$f->{file_code_new} if $f->{file_code_new};
		return $ses->redirect_msg("?op=file_edit&file_code=$f->{file_code}",$ses->{lang}->{lng_fileform_file_details_saved}) if $ses->getUserId != $file->{usr_id}; # admin
		return $ses->redirect_msg("?op=my_files&fld_id=$file->{file_fld_id}",$ses->{lang}->{lng_fileform_file_details_saved});
	}

	my $tags = $db->SelectARef("SELECT * FROM Tags t, Tags2Files t2f WHERE t2f.file_id=? AND t2f.tag_id=t.tag_id",$file->{file_id});

	$file->{categories} = genCategoriesSelect($file->{cat_id});;
	$file->{file_url} = $ses->makeFileLink($file);
	$file->{"file_status_$file->{file_status}"} = ' selected';

	$ses->getVideoInfo($file);

	my @versions;
	for my $mode ('o',reverse @{$c->{quality_letters}},'p')
	{
		next unless $file->{"file_size_$mode"};
		my $x = $ses->vInfo($file,$mode);
		$x->{vid_title} = $c->{quality_labels_full}->{$mode};
		$x->{vid_mode} = $mode||'o';
		$x->{vid_container} = uc $x->{vid_container};
		push @versions, $x;
	}
	$file->{versions} = \@versions;

	for my $m ('m_s','m_e','m_g')
	{
		$file->{"$m\_enabled"}=1 if $ses->checkModSpecialRights($m);
	}
	
	my $fdata = $db->SelectARef("SELECT * FROM FilesData WHERE file_id=?",$file->{file_id});
	my $fdhash;
	$fdhash->{$_->{name}}=$_->{value} for @$fdata;
	my @extra_data = map{{name=>$_,value=>$fdhash->{$_}}} split /\s*\,\s*/, $c->{file_data_fields};

	$file->{is_dupe}=1 if $file->{file_code} ne $file->{file_real};

	if($c->{srt_on} && $c->{srt_auto_langs})
	{
		#my $dx = sprintf("%05d",$file->{file_id}/$c->{files_per_folder});
		#my @arr = map{{language=>$_, url=>"$file->{srv_htdocs_url}/vtt/$file->{disk_id}/$dx/$file->{file_code}_$_.vtt"}} split(/\|/, $file->{file_captions});
		#$file->{captions_list} = \@arr;
		$file->{captions_list} = $ses->getCaptionsLinks($file);
		
		my @srt_langs = map{/^(\w+)=(\w+)$/;{value=>$1,title=>"$2 ($1)"}} split /\s*\,\s*/, $c->{srt_auto_langs};
		$file->{srt_langs} = \@srt_langs;
		$file->{srt_on}=1;
	}

	if($c->{m_p} && $c->{m_p_custom_upload})
	{
		$file->{m_p_custom_upload}=1;
		require Digest::MD5;
		$file->{md5} = Digest::MD5::md5_hex($file->{file_id}.$file->{file_real}.$c->{dl_key});
	}

	$file->{encoding} = $db->SelectOne("SELECT UPPER(GROUP_CONCAT(quality SEPARATOR ', ')) FROM QueueEncoding WHERE file_real_id=? GROUP BY file_real_id",$file->{file_real_id});
	$file->{transfer} = $db->SelectOne("SELECT s.srv_name FROM QueueTransfer q, Servers s WHERE q.file_real_id=? AND q.srv_id2=s.srv_id",$file->{file_real_id});
	$file->{fld_name} = $db->SelectOneCached("SELECT fld_name FROM Folders WHERE fld_id=?",$file->{file_fld_id});

	if($ses->getUser->{usr_adm})
	{
		$file->{file_logs} = $db->SelectARef("SELECT * FROM FileLogs WHERE file_real=?",$file->{file_real});
		$file->{proxies} = $db->SelectARef("SELECT h.host_name, h.host_id FROM Proxy2Files p, Hosts h 
											WHERE p.file_id=?
											AND p.host_id=h.host_id",$file->{file_id});
	}

	$ses->PrintTemplate("file_form.html", 
						%{$file}, 
						tags => $tags ,
						rand => $ses->randchar(6),
						extra_data => \@extra_data,
						enable_file_descr => $c->{enable_file_descr},
						newshot => $f->{newshot},
						);
}

sub FolderEdit
{
	my $folder = $db->SelectRow("SELECT * FROM Folders WHERE fld_id=? AND usr_id=?",$f->{fld_id},$ses->getUserId);
	return $ses->message("No such folder!") unless $folder;
	if($f->{save})
	{
		$f->{fld_name}  = $ses->SecureStr($f->{fld_name});
		$f->{fld_descr} = $ses->SecureStr($f->{fld_descr});
		utf8::decode($f->{fld_name});
		return $ses->message("Folder name too short") if length($f->{fld_name})<3;
		return $ses->message("Folder name is not kosher") unless $f->{fld_name}=~/[\w\d]+/;
		utf8::encode($f->{fld_name});
		$db->Exec("UPDATE Folders SET fld_name=?, fld_descr=? WHERE fld_id=?",$f->{fld_name},$f->{fld_descr},$f->{fld_id});
		$db->PurgeCache( "ufld-$folder->{fld_parent_id}-".$ses->getUserId );
		return $ses->redirect("?op=my_files&fld_id=$folder->{fld_parent_id}");
	}
	$ses->PrintTemplate("folder_form.html", %{$folder} );
}

sub Payments
{
	return $ses->redirect($c->{site_url}) unless $c->{enabled_prem};

	if($f->{check_transaction})
	{
		print"Content-type: application/json\n\n";
		my $transaction = $db->SelectRow("SELECT * FROM Transactions WHERE id=?", $f->{check_transaction});
		print(q|{ "status" : "verified" }|),return if $transaction && $transaction->{verified};
		print(q|{ "status" : "unknown" }|),return;
	}

	if(my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=?", $ENV{HTTP_REFERER} =~ /\/(\w{12})/))
	{
		$ses->setCookie("aff",$file->{usr_id},'+14d');
	}

	if($c->{no_anon_payments} && !$ses->getUser)
	{
		return $ses->redirect("$c->{site_url}/?op=registration&next=payments-$f->{type}-$f->{amount}");
	}

	if($f->{amount})
	{
		$f->{amount}=sprintf("%.02f",$f->{amount});

		return $ses->redirect('/login.html') if $c->{disable_anon_payments} && !$ses->getUserId;

		return $ses->message("You're not a reseller!") if $c->{m_k_manual} && $f->{reseller} && !$ses->getUser->{usr_reseller};
		$f->{referer}='RESELLER' if $f->{reseller};
		$f->{item_name}=~s/\W+//g;

		if($f->{storage} && $c->{plans_storage})
		{
			$f->{referer}='STORAGE';
			my $phash;
			for ( split( /\s*,\s*/, $c->{plans_storage} ) ) {
				/([\d\.]+)=(\d+)=(\d+)/;
				$phash->{$1} = $2;
			}
			my $gb = $phash->{$f->{amount}};
			$f->{item_name}="$gb GB" if $gb;
			return $ses->message("Invalid storage price") unless $gb;
		}

		$f->{item_name}||=$c->{item_name};

		my %opts = %{$f};
		$opts{usr_id} = $ses->getUser ? $ses->getUserId : 0;
		$opts{aff_id} = getAffiliate();
		$opts{referer} ||= $ses->getCookie('ref_url') || $ENV{HTTP_REFERER} || '';
		$opts{email} = $ses->getUser->{usr_email} if $ses->getUser;
		$opts{days} = $ses->ParsePlans($c->{payment_plans}, 'hash')->{$f->{amount}};
		return $ses->message("Invalid payment amount") if !$f->{reseller} && !$f->{storage} && !$opts{days};

		require IPN;
		my $transaction = IPN->new($ses)->createTransaction(%opts);
		$f->{id} = $transaction->{id};
		$f->{email} = $ses->getUser->{usr_email} if $ses->getUser;
		$ses->setCookie('transaction_id', $transaction->{id});
		my $url = $ses->getPlugins('Payments')->checkout($f) || return;

		# Some APIs aren't allowing to pass the transaction ID with Return URL
		return $ses->redirect($url) if $url && !$f->{no_redirect};
	}

	my $cc;
	$cc->{$_}=$c->{$_} for keys %$c;
	for ('reg','prem')
	{
		$cc->{"max_upload_filesize_$_"} = $cc->{"max_upload_filesize_$_"} ? $cc->{"max_upload_filesize_$_"}." MB" : "No limits";
		$cc->{"down_speed_$_"} = $cc->{"down_speed_$_"} ? $cc->{"down_speed_$_"}." Kbytes/sec" : "Unmetered";
		$cc->{"disk_space_$_"} = $cc->{"disk_space_$_"} ? $cc->{"disk_space_$_"}.' GB' : "Unlimited";
	}

	$cc->{max_downloads_number_reg}||='Unlimited';
	$cc->{max_downloads_number_prem}||='Unlimited';

	$cc->{files_expire_reg}  = $cc->{files_expire_access_reg}  ? "$cc->{files_expire_access_reg} $ses->{lang}->{lng_comparison_days_after_dl}" : $ses->{lang}->{lang_never};
	$cc->{files_expire_prem} = $cc->{files_expire_access_prem} ? "$cc->{files_expire_access_prem} $ses->{lang}->{lng_comparison_days_after_dl}" : $ses->{lang}->{lang_never};

	$cc->{bw_limit_reg}  = $cc->{bw_limit_reg}  ? "$cc->{bw_limit_reg} GB / $cc->{bw_limit_days} $ses->{lang}->{lng_misc_days}" : $ses->{lang}->{lng_comparison_unlimited};
	$cc->{bw_limit_prem} = $cc->{bw_limit_prem} ? "$cc->{bw_limit_prem} GB / $cc->{bw_limit_days} $ses->{lang}->{lng_misc_days}" : $ses->{lang}->{lng_comparison_unlimited};

	$cc->{max_watch_time_reg_txt} = $cc->{max_watch_time_reg} ? "$cc->{max_watch_time_reg} $ses->{lang}->{lng_misc_mins} / $ses->{lang}->{lng_comparison_day}" : $ses->{lang}->{lng_comparison_unlimited};
	$cc->{max_watch_time_prem_txt} = $cc->{max_watch_time_prem} ? "$cc->{max_watch_time_prem} $ses->{lang}->{lng_misc_mins} / $ses->{lang}->{lng_comparison_day}" : $ses->{lang}->{lng_comparison_unlimited};

	$cc->{max_download_filesize_reg_txt} = $cc->{max_download_filesize_reg} ? "$cc->{max_download_filesize_reg} MB" : $ses->{lang}->{lng_comparison_unlimited};
	$cc->{max_download_filesize_prem_txt} = $cc->{max_download_filesize_prem} ? "$cc->{max_download_filesize_prem} MB" : $ses->{lang}->{lng_comparison_unlimited};

	require Time::Elapsed;
	my $et = new Time::Elapsed;
	#my @payment_types = $ses->getPlugins('Payments')->get_payment_buy_with;
	my @payment_types;
	for my $opts($ses->getPlugins('Payments')->get_payment_buy_with())
	{
		if($opts->{submethods})
		{
			push @payment_types, { %$opts, %$_, submethod => $_->{name}, name => $opts->{name} } for @{ $opts->{submethods} };
		}
		else
		{
			push @payment_types, { %$opts };
		}
	}

	if($c->{plans_storage})
	{
		my @arr;
		for ( split( /\s*,\s*/, $c->{plans_storage} ) ) {
			/([\d\.]+)=(\d+)=(\d+)/;
			push @arr, { amount=>$1, storage=>$2, days=>$3 };
		}
		$cc->{storage_plans} = \@arr;
	}

	$ses->PrintTemplate("payments.html",
						%{$cc},
						payment_types => \@payment_types,
						plans => $ses->ParsePlans($c->{payment_plans}, 'array'), 
						premium => $ses->getUser && $ses->getUser->{premium},
						expire_elapsed => $ses->getUser && $et->convert($ses->getUser->{exp_sec}),
						'rand' => $ses->randchar(6),
						ask_email => !$ses->getUserId && !$c->{no_anon_payments},
	);
}

sub PaymentComplete
{
	my $str = shift;
	$str = $ses->getCookie('transaction_id') if $ses->getCookie('transaction_id');
	my ($id,$usr_id)=split(/-/,$str);
	my $trans = $db->SelectRow("SELECT *, INET6_NTOA(ip) as ip, (UNIX_TIMESTAMP()-UNIX_TIMESTAMP(created)) as dt
								FROM Transactions 
								WHERE id=?",$id) if $id;
	return $ses->message("No such transaction exist") unless $trans;
	return $ses->message("Internal error") unless $trans->{ip} eq $ENV{REMOTE_ADDR};
	return $ses->message("Your account created successfully.<br>Please check your e-mail for login details") if $trans->{dt}>3600;
	return $ses->message("Your payment have not verified yet.<br>Please refresh this page in 1-3 minutes") unless $trans->{verified};

	my $user = $db->SelectRow("SELECT *, DECODE(usr_password,?) as usr_password, 
										UNIX_TIMESTAMP(usr_premium_expire)-UNIX_TIMESTAMP() as exp_sec 
								FROM Users 
								WHERE usr_id=?",$c->{pasword_salt},$trans->{usr_id});
	require Time::Elapsed;
	my $et = new Time::Elapsed;
	my $exp = $et->convert($user->{exp_sec});
	return $ses->message("Your payment processed successfully!<br><br>Login: $user->{usr_login}<br>Password: $user->{usr_password}<br><br>Your premium account expires in:<br>$exp");
}

sub CheckFiles
{
	$f->{list}=~s/\r//gs;
	my ($i,@arr);
	for( split /\n/, $f->{list} )
	{
		$i++;
		my ($code,$fname) = /\/(\w{12})\/?(.*?)$/;
		next unless $code;
		$fname=~s/\.html?$//i;
		$fname=~s/_/ /g;
		#my $filter_fname="AND file_name='$fname'" if $fname=~/^[^'"<>]+$/;
		my $file = $db->SelectRow("SELECT f.file_id,f.file_name,s.srv_status FROM Files f, Servers s WHERE f.file_code=? AND s.srv_id=f.srv_id",$code);
		push(@arr,"<font color='red'>$_ $ses->{lang}->{lng_checkfiles_not_found}</font>"),next unless $file;
		$file->{file_name}=~s/_/ /g;
		#push(@arr,"<font color='red'>$_ filename don't match!</font>"),next if $fname && $file->{file_name} ne $fname;
		push(@arr,"<font color='orange'>$_ $ses->{lang}->{lng_checkfiles_exist_not_available}</font>"),next if $file->{srv_status} eq 'OFF';
		push(@arr,"<font color='green'>$_ $ses->{lang}->{lng_checkfiles_found}</font>");
	}
	$ses->PrintTemplate("checkfiles.html",
						'result' => join "<br>", @arr,
						);
}

sub IndexPage
{
	$ses->{expires}="+$c->{caching_expire}s" if $c->{caching_expire};
	$ses->PrintTemplate("index_page.html",
						index_featured_on	 => $c->{index_featured_on},
						index_most_viewed_on => $c->{index_most_viewed_on},
						index_most_rated_on  => $c->{index_most_rated_on},
						index_just_added_on  => $c->{index_just_added_on},
						index_live_streams_on => $c->{index_live_streams_on},
						'm_z'		  => $c->{m_z},
						'm_z_cols'	=> $c->{m_z_cols},
						'm_z_rows'	=> $c->{m_z_rows},
						);
}

sub Search
{
	return $ses->redirect($c->{site_url}) unless $c->{enable_search};
	return $ses->redirect($c->{site_url}) if $c->{enable_search}==2 && !$ses->getUserId;
	return $ses->redirect($c->{site_url}) if $c->{highload_mode};
	$f->{page}||=1;
	my $title = $ses->{lang}->{lng_index_videos};
	for(qw(k user tag))
	{
		$f->{$_} =~ s/[\"\0\\\;]+//g;
	}
	
	my @filters;
	my $sort_order;

	if(length($f->{k})>2)
	{
		push @filters, qq[AND (file_name LIKE "%$f->{k}%" OR file_title LIKE "%$f->{k}%" OR file_descr LIKE "%$f->{k}%")];
	}

	$f->{cat_id} = $db->SelectARefCached(300,"SELECT cat_id FROM Categories WHERE cat_name=?",$f->{cat_name})->[0]->{cat_id} if $f->{cat_name};
	if($f->{cat_id}=~/^\d+$/)
	{
		push @filters, "AND cat_id='$f->{cat_id}'";
	}

	if($f->{playlist})
	{
		my $playlist = $db->SelectRow("SELECT * FROM Playlists WHERE pls_code=?",$f->{playlist});
		my $pfiles = $db->SelectARef("SELECT * FROM Files2Playlists WHERE pls_id=?",$playlist->{pls_id});
		my $ids = join ',', map{$_->{file_id}} @$pfiles;
		push @filters, "AND file_id IN ($ids)" if $ids;
		$title = $playlist->{pls_name};
		$f->{hide_search}=1;
		$sort_order='file_created, file_id';
	}

	if($f->{user})
	{
		my $usr_id = $db->SelectOne("SELECT usr_id FROM Users WHERE usr_login=?",$f->{user});
		push @filters, "AND f.usr_id=$usr_id" if $usr_id;
	}

	my ($filter_tag1,$filter_tag2);
	if($f->{tag})
	{
		my $tag=$f->{tag};
		utf8::decode($tag);
		$tag=lc $tag;
		$tag=~s/[^\w\s\.\&]+//g;
		utf8::encode($tag);
		if(length($tag)>2)
		{
			my $tag_id = $db->SelectOne("SELECT tag_id FROM Tags WHERE tag_value=?",$tag);
			if($tag_id)
			{
				$filter_tag1=",Tags2Files t2f";
				$filter_tag2="AND f.file_id=t2f.file_id AND t2f.tag_id=$tag_id";
			}
		}
	}

	my ($filter_data1,$filter_data2);
	$f->{data_name}=~s/[^\w\s\_\-]//g;
	if($f->{data_name} && $f->{data_value})
	{
		my $value=$f->{data_value};
		utf8::decode($value);
		$value=lc $value;
		$value=~s/[^\w\s\.\&\-\_]+//g;
		utf8::encode($value);
		if(length($value)>2)
		{
			#my $tag_id = $db->SelectOne("SELECT tag_id FROM Tags WHERE tag_value=?",$tag);
			$filter_data1=",FilesData fd";
			$filter_data2="AND f.file_id=fd.file_id AND fd.name='$f->{data_name}' AND fd.value='$value'";
		}
	}

	#my $filter_folder;
	if($f->{fld_code})
	{
		my $folder = $db->SelectRow("SELECT * FROM Folders WHERE fld_code=?",$f->{fld_code});
		$title = "$folder->{fld_name}";
		push @filters, "AND f.usr_id=$folder->{usr_id} AND f.file_fld_id=$folder->{fld_id}";
	}

	# Avoid empty filters full search
	push @filters, "AND f.file_id=0" unless @filters || ($filter_tag2 || $filter_data2);

	push @filters, "AND f.file_public=1" if $c->{search_public_only} && !$f->{playlist};

	#push @filters, "AND (f.file_size_n>0 OR f.file_size_h>0 OR f.file_size_l>0 OR f.file_size_x>0)";

	my $filters_string = join "\n", @filters;

	# my $ids = $db->SelectARefCached("SELECT f.*, TO_DAYS(CURDATE())-TO_DAYS(file_created) as created,
	#												s.disk_id, s.srv_htdocs_url,
	#												u.usr_login
	#									  FROM (Files f, Servers s, Users u $filter_tag1 $filter_data1)
	#									  WHERE f.file_created < NOW()-INTERVAL 5 MINUTE
	#									  AND f.srv_id=s.srv_id
	#									  AND f.usr_id=u.usr_id
	#									  $filters_string
	#									  $filter_tag2
	#									  $filter_data2
	#									  ORDER BY file_created DESC".$ses->makePagingSQLSuffix($f->{page}) );

	$f->{per_page} ||= $c->{items_per_page};
	$f->{fast_paging} = 1;
  
	my $ids = $db->SelectARefCached("SELECT f.file_id
										FROM (Files f $filter_tag1 $filter_data1)
										WHERE f.file_created < NOW()-INTERVAL 5 MINUTE
										AND f.file_status='OK'
										$filters_string
										$filter_tag2
										$filter_data2
										ORDER BY file_id DESC".$ses->makePagingSQLSuffix($f->{page},$f->{per_page}) );
	if($#$ids>=$f->{per_page})
	{
		$f->{fast_paging_next}=1;
		pop(@$ids);
	}
	my $ids2 = join(',', map{$_->{file_id}} @$ids) || 0;
	$sort_order||='file_created DESC';
	my $list = $db->SelectARefCached("SELECT f.*, TO_DAYS(CURDATE())-TO_DAYS(file_created) as created,
												s.*,
												u.usr_login as file_usr_login
												FROM (Files f, Servers s, Users u)
												WHERE file_id IN ($ids2)
												AND f.srv_id=s.srv_id
												AND f.usr_id=u.usr_id
												ORDER BY $sort_order");


	my $total = $db->SelectOneCached("SELECT COUNT(*)
										 FROM Files f $filter_tag1 $filter_data1
										 WHERE f.file_created < NOW()-INTERVAL 5 MINUTE
										 $filters_string
										 $filter_tag2
										 $filter_data2
										");
	my $clist = genCategoriesSelect($f->{cat_id});
	undef($f->{cat_id}) if $f->{cat_name};
	$f->{cat_name} = $ses->{cgi_query}->escape($f->{cat_name});
	$f->{k} = $ses->{cgi_query}->escape($f->{k});
	my $paging = $ses->makePagingLinks($f,$total,'reverse');
	$f->{k} = $ses->{cgi_query}->unescape($f->{k});

	$paging =~ s/\?data_name=(.+?)\&amp;data_value=(.+?)\&amp;op=search\&amp;page=(\d+)/s\/$1\/$2\/page$3/ig;
	$paging =~ s/\?cat_name=(.+?)\&amp;op=search\&amp;page=(\d+)/category\/$1\/page$2/ig;
	$paging =~ s/\?op=search\&amp;tag=(.+?)\&amp;page=(\d+)/tag\/$1\/page$2/ig;
	

	$ses->processVideoList($list,0,$clist);

	#my $show_extra=1 if $f->{user} || $f->{cat_id};
	$f->{hide_search}=1 if $f->{fld_code};

	$ses->PrintTemplate("search.html",
						'files'  => $list,
						'paging' => $paging,
						'k'		=> $f->{k},
						'tag'	 => $f->{tag},
						'categories' => $clist,
						'title'  => $title,
						'user'	=> $f->{user},
						#'show_extra' => $show_extra,
						'fld_code'	=> $f->{fld_code},
						'hide_search' => $f->{hide_search},
						'm_z'		=> $c->{m_z},
						'm_z_cols'	=> $c->{m_z_cols},
						'm_z_rows'	=> $c->{m_z_rows},
						);
}

sub RequestMoney
{
	if($c->{m_u})
	{
		# Make sure user info no cached when Memcached enabled
		$db->PurgeCache( "ses".$ses->getCookie( $ses->{auth_cook} ) );
		$ses->CheckAuth();
	}
	my $money = $ses->getUser->{usr_money};
	if($f->{convert_ext_acc})
	{
		return $ses->message("$ses->{lang}->{lng_requestmoney_need_at_least} \$$c->{convert_money}") if $money<$c->{convert_money};
		if($ses->getUser->{premium})
		{
			$db->Exec("UPDATE Users 
						  SET usr_money=usr_money-?, 
								usr_premium_expire=usr_premium_expire+INTERVAL ? DAY 
						  WHERE usr_id=?",$c->{convert_money},$c->{convert_days},$ses->getUserId);
		}
		else
		{
			$db->Exec("UPDATE Users 
						  SET usr_money=usr_money-?, 
								usr_premium_expire=NOW()+INTERVAL ? DAY 
						  WHERE usr_id=?",$c->{convert_money},$c->{convert_days},$ses->getUserId);
		}
		return $ses->redirect_msg("$c->{site_url}/?op=my_account","Your premium account extended for $c->{convert_days} days");
	}
	if($f->{convert_new_acc})
	{
		return $ses->message("$ses->{lang}->{lng_requestmoney_need_at_least} \$$c->{convert_money}") if $money<$c->{convert_money};
		my $login = join '', map int rand 10, 1..7;
		while($db->SelectOne("SELECT usr_id FROM Users WHERE usr_login=?",$login)){ $login = join '', map int rand 10, 1..7; }
		my $password = $ses->randchar(10);
		$db->Exec("INSERT INTO Users (usr_login, usr_password, usr_created, usr_premium_expire, usr_aff_id) 
						VALUES (?, ?, NOW(), NOW()+INTERVAL ? DAY, ?)",
						$login, $ses->genPasswdHash($password), $c->{convert_days}, $ses->getUserId);
		$db->Exec("UPDATE Users SET usr_money=usr_money-? WHERE usr_id=?",$c->{convert_money},$ses->getUserId);
		return $ses->message("$ses->{lang}->{lng_requestmoney_new_account_generated}<br>$ses->{lang}->{lng_myaccount_username} / $ses->{lang}->{lng_myaccount_password}:<br>$login<br>$password");
	}
	if($f->{convert_profit})
	{
		return $ses->message("$ses->{lang}->{lng_requestmoney_need_at_least} \$$c->{min_payout}") if $f->{amount} < $c->{min_payout};
		return $ses->message("Invalid amount") if $f->{amount} > $ses->getUser->{usr_money};
		return $ses->message("Profit system is disabled") unless $c->{min_payout};
		return $ses->message($ses->{lang}->{lng_requestmoney_enter_pay_info}) unless $ses->getUser->{usr_pay_email};
		return $ses->message("Already have pending payout") if $db->SelectOne("SELECT id FROM Payments WHERE usr_id=? AND status='PENDING'",$ses->getUserId);

		my $hash = $ses->randchar(10);
		$db->Exec("INSERT INTO ChangeFields SET hash=?, usr_id=?, ip=INET6_ATON(?), data=?", $hash, $ses->getUserId, $ses->getIP, "withdrawal=$f->{amount}" );

		my $tt = $ses->CreateTemplate("request_money_email_confirm.html");
		$tt->param( amount			=> $f->{amount},
					usr_pay_type	=> $ses->getUser->{usr_pay_type},
					usr_pay_email	=> $ses->getUser->{usr_pay_email},
					ip				=> $ses->getIP,
					country			=> $ses->getMyCountry,
					hash			=> $hash,
					);
		$ses->SendMailQueue($ses->getUser->{usr_email}, $c->{email_from}, "$c->{site_name}: Confirm Your Withdraw Request", $tt->output);
		return $ses->redirect_msg("$c->{site_url}/?op=request_money","Email with confirmation link was sent to ".$ses->getUser->{usr_email});
	}
	if($f->{confirm_withdrawal})
	{
		unless($f->{aprove})
		{
			return $ses->PrintTemplate("request_money_confirm2.html",);
		}
		else
		{
			$db->Exec("UPDATE Users SET usr_money=0 WHERE usr_id=?",$ses->getUserId);
			$db->Exec("INSERT INTO Payments 
						SET usr_id=?,
							amount=?,
							status='PENDING',
							created=NOW(),
							pay_type=?,
							pay_info=?",
						$ses->getUserId,
						$money,
						$ses->getUser->{usr_pay_type},
						$ses->getUser->{usr_pay_email} );
			return $ses->redirect_msg("$c->{site_url}/?op=request_money",$ses->{lang}->{lng_requestmoney_payout_requested_ok});
		}
	}

	my $pay_req = $db->SelectOne("SELECT SUM(amount) FROM Payments WHERE usr_id=? AND status='PENDING'",$ses->getUserId);

	my $convert_enough = 1 if $money >= $c->{convert_money};
	my $payout_enough = 1 if $money >= $c->{min_payout};
	$money = sprintf("%.02f",$money);

	my $payments = $db->SelectARef("SELECT *, DATE(created) as created2, DATE(processed) as processed2
									FROM Payments 
									WHERE usr_id=? 
									ORDER BY created DESC",$ses->getUserId);
	for(@$payments)
	{
			$_->{processed2}='' if $_->{processed2} eq '0000-00-00';
			$_->{status}=$ses->{lang}->{lng_requestmoney_status_paid} if $_->{status} eq 'PAID';
			$_->{status}=$ses->{lang}->{lng_requestmoney_status_rejected} if $_->{status} eq 'REJECTED';
			$_->{status}=$ses->{lang}->{lng_requestmoney_status_pending} if $_->{status} eq 'PENDING';
	}

	$ses->PrintTemplate("request_money.html",
						'usr_money'			=> $money,
						'convert_days'		=> $c->{convert_days},
						'convert_money'		=> $c->{convert_money},
						'payment_request'	=> $pay_req,
						'payout_enough'		=> $payout_enough,
						'convert_enough'	=> $convert_enough,
						'enabled_prem'		=> $c->{enabled_prem},
						'min_payout'		=> $c->{min_payout},
						'msg'				=> $f->{msg},
						'payments'			=> $payments,
						token 				=> $ses->genToken,
						);
}

sub MyReseller
{
	return $ses->message("Not allowed") unless ($c->{m_k} && ($ses->getUser->{usr_reseller} || !$c->{m_k_manual}));
	my $user = $ses->getUser;

	my (@plans,$hh,$hr);
	for(split(/,/,$c->{m_k_plans}))
	{
		my ($price,$time) = /^(.+)=(.+)$/;
		$hh->{$price} = $time;
		$hr->{$time} = $price;
		my $time1=$time;

		$time=~s/h/" $ses->{lang}->{lng_misc_hours}"/ie;
		$time=~s/d/" $ses->{lang}->{lng_misc_days}"/ie;
		$time=~s/m/" $ses->{lang}->{lng_misc_months}"/ie;
		
		push @plans, {	price  => $price,
						time	=> $time,
						time1  => $time1,
						enough => $user->{usr_money}>=$price ? 1 : 0,
						}
	}

	if($f->{del})
	{
		my $key = $db->SelectRow("SELECT * FROM PremiumKeys WHERE key_id=? AND usr_id=? AND usr_id_activated=0",$f->{del},$user->{usr_id});
		return $ses->message("Can't delete this key") unless $key;
		$db->Exec("UPDATE Users SET usr_money=usr_money+? WHERE usr_id=?",$hr->{$key->{key_time}},$user->{usr_id});
		$db->Exec("DELETE FROM PremiumKeys WHERE key_id=?",$key->{key_id});
		$db->PurgeCache( "ses".$ses->getCookie($ses->{auth_cook}) );
		return $ses->redirect('?op=my_reseller');
	}

	if($f->{generate}=~/^[\d\.]+$/)
	{
		return $ses->message("You can have max 100 pending keys") if $db->SelectOne("SELECT COUNT(*) FROM PremiumKeys WHERE usr_id=? AND usr_id_activated=0",$user->{usr_id})>=100;
		my $time = $hh->{$f->{generate}};
		return $ses->message("Invalid price") unless $time;
		return $ses->message("Not enough money") if $ses->getUser->{usr_money} < $f->{generate};
		my @r = ('a'..'z');
		my $key_code = $r[rand scalar @r].$ses->randchar(13);
		$db->Exec("INSERT INTO PremiumKeys SET usr_id=?, key_code=?, key_time=?, key_created=NOW()",
					$user->{usr_id},$key_code,$time);
		$db->Exec("UPDATE Users SET usr_money=usr_money-? WHERE usr_id=?",$f->{generate},$user->{usr_id});
		$db->PurgeCache( "ses".$ses->getCookie($ses->{auth_cook}) );
		return $ses->redirect('?op=my_reseller');
	}

	my $keys = $db->SelectARef("SELECT *
								FROM PremiumKeys 
								WHERE usr_id=?
								ORDER BY key_created DESC
								".$ses->makePagingSQLSuffix($f->{page}), $user->{usr_id} );
	my $total = $db->SelectOne("SELECT COUNT(*) FROM PremiumKeys WHERE usr_id=?");
	for(@$keys)
	{
		$_->{key_time}=~s/h/" $ses->{lang}->{lng_misc_hours}"/ie;
		$_->{key_time}=~s/d/" $ses->{lang}->{lng_misc_days}"/ie;
		$_->{key_time}=~s/m/" $ses->{lang}->{lng_misc_months}"/ie;
	}

	$user->{usr_money} = sprintf("%.02f",$user->{usr_money});
	if($c->{m_k_add_money})
	{
		my @list = map{{amount=>$_}} grep{/^[\d\.]+$/} split /\s*\,\s*/, $c->{m_k_add_money_list};
		$user->{add_amounts} = \@list;
	}

	$ses->PrintTemplate("my_reseller.html",
						%$user,
						'plans'  => \@plans,
						'keys'	=> $keys,
						'paging' => $ses->makePagingLinks($f,$total),
						%$c,
						);
}

sub APIReseller
{
	$f->{login}=$f->{u};
	$f->{password}=$f->{p};
	Login('no_redirect');

	print"Content-type:text/html\n\n";
	print("ERROR:Reseller mod disabled"),return unless $c->{m_k};
	print("ERROR:Invalid username/password"),return unless $ses->getUser;
	print("ERROR:Not reseller user"),return if $c->{m_k_manual} && !$ses->getUser->{usr_reseller};
	print("ERROR:You can have max 100 pending keys"),return if $db->SelectOne("SELECT COUNT(*) FROM PremiumKeys WHERE usr_id=? AND usr_id_activated=0",$ses->getUserId)>=100;

	$f->{t}=lc $f->{t};
	my $price;
	for(split(/,/,$c->{m_k_plans}))
	{
		my ($pr,$time) = /^(.+)=(.+)$/;
		$price=$pr if $time eq $f->{t};
	}

	print("ERROR:Invalid time"),return unless $price;
	print("ERROR:Not enough money"),return if $ses->getUser->{usr_money} < $price;

	my @r = ('a'..'z');
	my $key_code = $r[rand scalar @r].$ses->randchar(13);
	$db->Exec("INSERT INTO PremiumKeys SET usr_id=?, key_code=?, key_time=?, key_created=NOW()",
				$ses->getUserId,$key_code,$f->{t});
	my $id = $db->getLastInsertId;
	$db->Exec("UPDATE Users SET usr_money=usr_money-? WHERE usr_id=?",$price,$ses->getUserId);
	print"$id$key_code";
	return;
}

sub ReportFile
{
	my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=?",$f->{file_code});

	$ses->out("No such file") unless $file;
	$db->Exec("INSERT INTO Reports
				SET file_code=?,
						type=?,
						info=?,
						ip=INET6_ATON(?),
						created=NOW()
				",
				$file->{file_code},
				$ses->SecureStr($f->{report_type}),
				$ses->SecureStr($f->{report_info}),
				$ses->getIP,
				);
	$ses->out(qq[\$("#id_flag").html("$ses->{lang}->{lng_download_flag_saved}");]);
}

sub APIGetLimits
{
	if($f->{login} && $f->{password})
	{
		Login('no_redirect');
		$f->{error}="auth_error" unless $ses->getUser;
	}
	elsif($f->{session_id})
	{
		$ses->{cookies}->{$ses->{auth_cook}} = $f->{session_id};
		$ses->CheckAuth();
	}
	my $utype = $ses->getUser ? ($ses->getUser->{premium} ? 'prem' : 'reg') : 'anon';
	$c->{$_}=$c->{"$_\_$utype"} for qw(max_upload_files max_upload_filesize download_countdown captcha ads bw_limit remote_url direct_links down_speed);

	my $type_filter = $utype eq 'prem' ? "AND srv_allow_premium=1" : "AND srv_allow_regular=1";
	my $server = $db->SelectRow("SELECT * FROM Servers 
								WHERE srv_status='ON' 
								AND srv_disk+? <= srv_disk_max
								$type_filter
								ORDER BY srv_last_upload 
								LIMIT 1",$c->{max_upload_filesize}||100);
	my $ext_allowed	  = join '|', map{uc($_)." Files|*.$_"} split(/\|/,$c->{video_extensions});
	my $login_logic = 1 if !$c->{enabled_anon} && ($c->{enabled_reg} || $c->{enabled_prem});
		$login_logic = 2 if $c->{enabled_anon} && !$c->{enabled_reg} && !$c->{enabled_prem};
	print"Content-type:text/xml\n\n";
	print"<Data>\n";
	print"<ExtAllowed>$ext_allowed</ExtAllowed>\n";
	print"<MaxUploadFilesize>$c->{max_upload_filesize}</MaxUploadFilesize>\n";
	print"<ServerURL>$server->{srv_cgi_url}</ServerURL>\n";
	print"<SessionID>".$ses->{cookies_send}->{$ses->{auth_cook}}."</SessionID>\n";
	print"<Error>$f->{error}</Error>\n";
	print"<SiteName>$c->{site_name}</SiteName>\n";
	print"<LoginLogic>$login_logic</LoginLogic>\n";
	print"</Data>";
	return;
}

sub CommentAdd
{
	$ses->CheckAuth();
	return $ses->message("File comments are not allowed") if $f->{cmt_type}==1 && !$c->{enable_file_comments};
	return $ses->message("Invalid object ID") unless $f->{cmt_ext_id}=~/^\d+$/;
	#my $redirect = &CommentRedirect($f->{cmt_type},$f->{cmt_ext_id});
	if($f->{name} || $f->{email} || $f->{text})
	{
		return $ses->message("bot!");
	}
	if($ses->getUser)
	{
		$f->{cmt_name} = $ses->getUser->{usr_login};
		$f->{cmt_email} = $ses->getUser->{usr_email};
	}
	$f->{usr_id} = $ses->getUser ? $ses->getUserId : 0;
	$f->{cmt_name}=~s/(http:\/\/|www\.|\.com|\.net)//gis;
	$f->{cmt_name}	 = $ses->SecureStr($f->{cmt_name});
	$f->{cmt_email}	= $ses->SecureStr($f->{cmt_email});
	$f->{cmt_text}	 = $ses->SecureStr($f->{cmt_text});
	$f->{cmt_text} =~ s/(\_n\_|\n)/<br>/g;
	$f->{cmt_text} =~ s/\r//g;
	$f->{cmt_text} =~ s/"/&quot;/g;
	$f->{cmt_text} = substr($f->{cmt_text},0,800);
	my $err;
	$err.="Name is required field<br>" unless $f->{cmt_name};
	$err.="E-mail is not valid<br>" if $f->{cmt_email} && $f->{cmt_email}!~/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	$err.="Too short comment text<br>" if length($f->{cmt_text})<5;
	my $txt=$f->{cmt_text};
	$txt=~s/[\s._-]+//gs;
	$err.="Comment text contain restricted word" if $c->{bad_comment_words} && $txt=~/$c->{bad_comment_words}/i;
	print(qq{Content-type:text/html\n\n\$('#cnew').append("<b class='err'>$err</b><br><br>");}),return if $err;

	$db->Exec("INSERT INTO Comments
				SET usr_id=?,
						cmt_type=?,
						cmt_ext_id=?,
						cmt_ip=INET6_ATON(?),
						cmt_name=?,
						cmt_email=?,
						cmt_text=?
				",$f->{usr_id},$f->{cmt_type},$f->{cmt_ext_id},$ses->getIP,$f->{cmt_name},$f->{cmt_email},$f->{cmt_text});
	$ses->setCookie('cmt_name',$f->{cmt_name});
	$ses->setCookie('cmt_email',$f->{cmt_email});
	#$ses->redirect($redirect,'+1m');
	print"Content-type:text/html\n\n";
	#print qq{\$('#cmt_txt').val('');\$('#cnew').append("<div class='cmt'><div class='cmt_hdr'><b>$f->{cmt_name}</b></div><div class='cmt_txt'>$f->{cmt_text}</div></div>");};
	#print qq{\$('#cmt_txt').val('');\$("<div class='cmt' style='display:none'><div class='cmt_hdr'><b>$f->{cmt_name}</b></div><div class='cmt_txt'>$f->{cmt_text}</div></div>").appendTo('#cnew').slideDown('slow');};
my $post=<<EOP
<li style='display:none;'>
  <div class='comment_header'>
	 <span class='comment_user'>$f->{cmt_name}</span>
	  <span class='comment_date'></span>
		<div class='clear'></div>
  </div>
 <div class='comment_body'>
	$f->{cmt_text}
 </div>
</li>
EOP
;
  $post=~s/\n//g;
  print qq{\$('#cmt_txt').val('');\$("$post").appendTo('#cnew').slideDown('slow');};
	return;
}

sub CommentDel
{
	return $ses->message("Access denied") unless $ses->getUser && $ses->getUser->{usr_adm};
	$db->Exec("DELETE FROM Comments WHERE cmt_id=?",$f->{i});
	print"Content-type:text/html\n\n\$('#cm$f->{i}').slideUp('slow');";
	return;
}

sub CommentRedirect
{
	my ($cmt_type,$cmt_ext_id) = @_;
	if($cmt_type==1) # Files
	{
		my $file = $db->SelectRow("SELECT * FROM Files WHERE file_id=?",$cmt_ext_id);
		return $ses->message("Object doesn't exist") unless $file;
		$ses->setCookie("skip$file->{file_id}",1);
		return $ses->makeFileLink($file).'#comments';
	}
	elsif($cmt_type==2) # News
	{
		my $news = $db->SelectRow("SELECT * FROM News WHERE news_id=?",$cmt_ext_id);
		return $ses->message("Object doesn't exist") unless $news;
		return "$c->{site_url}/n$news->{news_id}-$news->{news_title2}.html#comments";
	}
	return $ses->message("Invalid object type");
}

###
sub ARef
{
	my $data=shift;
	$data=[] unless $data;
	$data=[$data] unless ref($data) eq 'ARRAY';
	return $data;
}

sub getTime
{
	my ($t) = @_;
	my @t = $t ? localtime($t) : localtime();
	return ( sprintf("%04d",$t[5]+1900),
				sprintf("%02d",$t[4]+1), 
				sprintf("%02d",$t[3]), 
				sprintf("%02d",$t[2]), 
				sprintf("%02d",$t[1]), 
				sprintf("%02d",$t[0]) 
			);
}

sub EmailUnsubscribe
{
	my $user = $db->SelectRow("SELECT * FROM Users WHERE usr_id=? AND usr_email=?",$f->{id},$f->{email});
	return $ses->message("Invalid unsubsription link") unless $user;
	$db->Exec("UPDATE Users SET usr_no_emails=1 WHERE usr_id=?",$user->{usr_id});
	return $ses->message("You've successfully unsubribed from email newsleters.");
}

sub Vote
{
	print"Content-type:text/html\n\n";
	print("alert('Register to Vote!');"),return unless $ses->getUserId;
	my $file = $db->SelectRowCached("SELECT file_id FROM Files WHERE file_code=?",$f->{file_code});
	print(qq[alert("File was deleted");]),return unless $file;
	my $voted = $db->SelectOne("SELECT vote FROM Votes WHERE file_id=? AND usr_id=?",$file->{file_id},$ses->getUserId);
	#print(qq[alert("You've already voted for this file!");]),return if 

	my $vote = $f->{v} eq 'up' ? 1 : -1;
	return if $voted && $voted==$vote;
	my $rating;
	if($voted)
	{
			$db->Exec("UPDATE Votes SET vote=? WHERE file_id=? AND usr_id=?", $vote, $file->{file_id},$ses->getUserId);
			$rating = $vote==1 ? 2 : -2;
	}
	else
	{
		$db->Exec("INSERT IGNORE INTO Votes SET file_id=?, usr_id=?, vote=?",$file->{file_id},$ses->getUserId,$vote);
		$rating = $vote;
	}
	$db->Exec("UPDATE LOW_PRIORITY Files SET file_rating=file_rating+? WHERE file_id=?", $rating, $file->{file_id});
	
	my $votes = $db->SelectARef("SELECT vote, COUNT(*) as num FROM Votes WHERE file_id=? GROUP BY vote",$file->{file_id});
	for(@$votes)
	{
		$file->{likes}=$_->{num} if $_->{vote}==1;
		$file->{dislikes}=$_->{num} if $_->{vote}==-1;
	}
	$file->{likes}||=0;
	$file->{dislikes}||=0;
	$file->{likes_percent}=sprintf("%.1f",100*$file->{likes}/($file->{likes}+$file->{dislikes})) if $file->{likes} || $file->{dislikes};

	print qq|\$("#vote a").removeClass('active');\$(".vote_$f->{v}").addClass('active');\$('#likes_num').text('$file->{likes}');\$('#dislikes_num').text('$file->{dislikes}');\$('.likestatus span').css('width','$file->{likes_percent}%');|;
	return;
}


sub ModeratorFilesFeatured
{
	return $ses->message("Access denied") if !$ses->getUser->{usr_adm} && !($c->{m_d} && $ses->getUser->{usr_mod} && $c->{m_d_featured});
	if($f->{ajax_toggle})
	{
		print"Content-type:text/html\n\n";
		my $now = $db->SelectOne("SELECT file_id FROM FilesFeatured WHERE file_id=?",$f->{ajax_toggle});
		if($now)
		{
			$db->Exec("DELETE FROM FilesFeatured WHERE file_id=?",$f->{ajax_toggle});
			print"Added to Featured";
		}
		else
		{
			$db->Exec("INSERT INTO FilesFeatured SET file_id=?",$f->{ajax_toggle});
			print"Added to Featured";
		}
		return;
	}
	if($f->{del_id})
	{
		$db->Exec("DELETE FROM FilesFeatured WHERE file_id=?",$f->{del_id});
		#$ses->redirect("?op=admin_files_featured");
		print"Content-type:text/html\n\n";
		print"\$('#f$f->{del_id}').hide('slow');";
		return;
	}
	my $list = $db->SelectARef("SELECT f.*, 
								UNIX_TIMESTAMP()-UNIX_TIMESTAMP(ff.created) as added,
								u.usr_login
								FROM (FilesFeatured ff, Files f)
								LEFT JOIN Users u ON f.usr_id=u.usr_id
								WHERE ff.file_id=f.file_id
								ORDER BY ff.created
								");
	for(@$list)
	{
		$_->{download_link} = $ses->makeFileLink($_);
		$_->{added} = sprintf("%.0f",$_->{added}/3600);
		$_->{added} = $_->{added} < 48 ? "$_->{added} hours ago" : sprintf("%.0f days ago",$_->{added}/24);
		$ses->getVideoInfo($_);
	}
	$ses->PrintTemplate("moderator_files_featured.html",
						list			=> $list,
						);
}

sub MyTorrents
{
	if($f->{del_torrents} && $f->{sid})
	{
		$db->Exec("DELETE FROM Torrents WHERE sid=? AND usr_id=?",$f->{sid},$ses->getUserId);
		return $ses->redirect("$c->{site_url}/?op=my_torrents");
	}

	my $torrents = getTorrents();
	$ses->PrintTemplate("my_torrents.html",
						torrents  => $torrents,
						);
}

sub getTorrents
{
	my $torrents = $db->SelectARef("SELECT *, UNIX_TIMESTAMP()-UNIX_TIMESTAMP(created) as working
											FROM Torrents t
											WHERE t.usr_id=?
											AND t.status='WORKING' 
											ORDER BY created DESC
											",$ses->getUserId);
	require JSON;
	for my $t (@$torrents)
	{
		my $files = eval { JSON::decode_json($t->{files}) } if $t->{files};
		$t->{file_list} = join('<br>',map{$_->{name}=~s/^.+\///;$ses->SecureStr($_->{name}) . " (<i>".sprintf("%.1f Mb",$_->{length}/1048576)."<\/i>) ".sprintf("%.0f%",100*$_->{bytesCompleted}/($_->{length}||1))} grep{$_->{name}!~/\.(txt|exe|jpg|png)$/} @$files );
		$t->{title} = $ses->SecureStr($t->{name});
		$t->{title}=~s/\/.+$//;
		$t->{title}=~s/:\d+$//;

		$t->{percent} = sprintf("%.01f", 100*$t->{downloaded}/$t->{size} ) if $t->{size};
		$t->{working} = $t->{working}>3600*3 ? sprintf("%.1f hours",$t->{working}/3600) : sprintf("%.0f mins",$t->{working}/60);
		$t->{"status_".lc($t->{status})} = 1;

		$t->{download_speed} = sprintf("%.0f KB/s", $t->{download_speed}/1024 );
		$t->{upload_speed} = sprintf("%.0f KB/s", $t->{upload_speed}/1024 );
		$t->{downloaded} = sprintf("%.1f", $t->{downloaded}/1024**3 );
		$t->{uploaded} = sprintf("%.1f", $t->{uploaded}/1024**3 );
		$t->{size} = sprintf("%.1f", $t->{size}/1024**3 );
	}

	return $torrents;
}

sub MakeMoneyPage
{
	my @sizes = map{{t1=>$_}} split(/\|/,$c->{tier_sizes});
	$sizes[$_]->{t2}=$sizes[$_+1]->{t1} for(0..$#sizes-1);
	$sizes[$#sizes]->{t2}='Longer';

	my @tier1 = map{{amount=>$_}} split(/\|/,$c->{tier1_money});
	my @tier2 = map{{amount=>$_}} split(/\|/,$c->{tier2_money});
	my @tier3 = map{{amount=>$_}} split(/\|/,$c->{tier3_money});
	my @tier4 = map{{amount=>$_}} split(/\|/,$c->{tier4_money});

	require XCountries;

	my @countries1 = grep{$_} map{$XCountries::iso_to_country->{uc $_}} split(/\|/,$c->{tier1_countries});
	my @countries2 = grep{$_} map{$XCountries::iso_to_country->{uc $_}} split(/\|/,$c->{tier2_countries});
	my @countries3 = grep{$_} map{$XCountries::iso_to_country->{uc $_}} split(/\|/,$c->{tier3_countries});
	my @countries4 = grep{$_} map{$XCountries::iso_to_country->{uc $_}} split(/\|/,$c->{tier4_countries});

	$ses->PrintTemplate("make_money.html",
						sizes => \@sizes,
						tier1 => \@tier1,
						tier2 => \@tier2,
						tier3 => \@tier3,
						tier4 => \@tier4,
						countries1 => join(', ',@countries1),
						countries2 => join(', ',@countries2),
						countries3 => join(', ',@countries3),
						countries4 => join(', ',@countries4),
						tier_views_number => $c->{tier_views_number},
						);
}

sub MyWatermark
{
	#$ses->loadUserData();
	my $user = $ses->getUser;

	#return $ses->message("Watermark mod disabled") unless $c->{m_v};
	return $ses->message("You're not allowed to use this mod") unless $ses->checkModSpecialRights('m_v');

	my $usr_id = $ses->getUserId;

	if(defined $f->{watermark_mode})
	{
		if($f->{watermark_mode} eq 'image' && $f->{logo_image})
		{
			require GD;
			my $im = new GD::Image($ses->{cgi_query}->upload('logo_image')) || return $ses->message("Failed to read the image");
			my ($w,$h) = $im->getBounds();
			return $ses->message("Invalid image") unless $w && $h;
			return $ses->message("Image is too large ($w x $h)") if $w>$c->{m_v_image_max_size} || $h>$c->{m_v_image_max_size};
			$im->saveAlpha(1);
			$im->alphaBlending(1);
			uploadMoveFile('logo_image',"$c->{site_path}/upload-data/watermark_$usr_id.png") || return $ses->message("Failed to move the image:$!");
		}

		### Validate inputs ###
		
		utf8::decode($f->{watermark_text});
		$f->{watermark_text}=~s/[^\w\s\.\-\!]//g;
		utf8::encode($f->{watermark_text});
		if($f->{watermark_mode} eq 'text')
		{
			$f->{watermark_padding}=0 unless $f->{watermark_padding}=~/^\d+$/ && $f->{watermark_padding}<200;
			$f->{watermark_position}||='nw';
			$f->{watermark_color}='#F3F3F3' unless $f->{watermark_color}=~/^#\w{6}$/;
			$f->{watermark_shadow_color}='' unless $f->{watermark_shadow_color}=~/^#\w{6}$/;
			$f->{watermark_size}=13 unless $f->{watermark_size}=~/^\d+$/ && $f->{watermark_size}>8;
			$f->{watermark_text}=$c->{site_name} unless $f->{watermark_text};
		}
		if($f->{watermark_mode} eq 'scroll')
		{
			$f->{watermark_padding}=0 unless $f->{watermark_padding}=~/^\d+$/ && $f->{watermark_padding}<200;
			$f->{watermark_position}||='top';
			$f->{watermark_color}='#F3F3F3' unless $f->{watermark_color}=~/^#\w{6}$/;
			$f->{watermark_shadow_color}='' unless $f->{watermark_shadow_color}=~/^#\w{6}$/;
			$f->{watermark_size}=13 unless $f->{watermark_size}=~/^\d+$/ && $f->{watermark_size}>8;
			$f->{watermark_scroll_start}=3	unless $f->{watermark_scroll_start}=~/^\d+$/;
			$f->{watermark_scroll_length}=10 unless $f->{watermark_scroll_length}=~/^\d+$/;
			$f->{watermark_text}=$c->{site_name} unless $f->{watermark_text};
		}
		if($f->{watermark_mode} eq 'image')
		{
			$f->{watermark_image_fadeout}=~s/\D//g;
			$f->{watermark_image_fadeout}=60 if $f->{watermark_image_fadeout}>60;
			$f->{watermark_image_fadeout}||=10;
			$f->{watermark_padding}=~s/\D//g;
			$f->{watermark_padding}||=0;
			$f->{watermark_fade}||=0;
			$f->{watermark_position}||='nw';
		}
		#######################

		my @keys = grep {/^watermark_/} keys %$f;
		for(@keys)
		{
			#$db->Exec("INSERT INTO UserData SET usr_id=?, name=?, value=?", $ses->getUserId, $_, $f->{$_}||'' ) if defined $f->{$_};
			$ses->saveUserData($_, $f->{$_});
		}
		return $ses->redirect('?op=my_watermark');
	}

	#my @fonts = map{{font=>$_,selected=>($_ eq $user->{watermark_font} ? ' selected' : '')}} split /,\s*/, $c->{m_v_fonts};
	my @fonts = map{{font_name=>$_, selected=>($_ eq $user->{watermark_font} ? ' selected' : '')}} split /\s*\,\s*/, $c->{fileserver_fonts};

	$user->{watermark_mode}||=0;
	$user->{"watermark_mode_$user->{watermark_mode}"}=' checked';
	$user->{"watermark_dispose_mode_$user->{watermark_dispose_mode}"} = ' selected';
	$user->{"watermark_opacity_$user->{watermark_opacity}"} = ' selected';
	$user->{"watermark_position_$user->{watermark_position}"} = 1;
	$user->{logo_url}="watermark_$usr_id.png" if -f "$c->{site_path}/upload-data/watermark_$usr_id.png";
	$user->{watermark_padding}||=0;

	$ses->PrintTemplate("my_watermark.html",
						%$user,
						fonts	=> \@fonts,
						m_v_image_logo => $c->{m_v_image_logo},
						m_v_image_max_size => $c->{m_v_image_max_size},
						rand => $ses->randchar(6),
						);
}

# sub addEncodeQueueDB
# {
# 	my ($file_real_id, $file_real, $file_id, $srv_id, $premium, $quality) = @_;

# 	$db->Exec("INSERT IGNORE INTO QueueEncoding
# 				SET file_real_id=?, 
# 					file_real=?, 
# 					file_id=?,
# 					srv_id=?,
# 					premium=?, 
# 					quality=?,
# 					extra=?,
# 					created=NOW()", 
# 					$file_real_id, 
# 					$file_real, 
# 					$file_id, 
# 					$srv_id,
# 					$premium,
# 					$quality,
# 					$f->{effects}||'',
# 				);
# }

sub MySnapshot
{
	#return $ses->message("Watermark mod disabled") unless $c->{m_s};
	return $ses->message("You're not allowed to manage snapshots") unless $ses->checkModSpecialRights('m_s');

	my $file = $db->SelectRow("SELECT * FROM Files f, Servers s 
										WHERE file_code=?
										AND usr_id=?
										AND f.srv_id=s.srv_id",$f->{file_code},$ses->getUserId);
	return $ses->message("Not your file") unless $file;

	my $reqs = $ses->checkEventRate($ses->getUserId, 'mysnap', 8 ); # requests per minute limit
	return $ses->message("Too many requests from you!") if $reqs >= 8;

	$ses->getVideoInfo($file);
	$f->{ss}=~s/[^\d\.]//g;
	$f->{ss}||=0;
	if($f->{create})
	{
		my $res = $ses->api2($file->{srv_id},
									{
										op => 'gen_snapshots',
										file_code	=> $file->{file_real},
										file_id		=> $file->{file_real_id}||$file->{file_id},
										disk_id		=> $file->{disk_id},
										create		=> $f->{ss},
									});
		return $ses->message("ERROR:$res") unless $res eq 'OK';
		$ses->PurgeFileCaches($file);
		return $ses->redirect("?op=file_edit&file_code=$file->{file_code}&newshot=1");
	}

	if($f->{preview})
	{
		my $res = $ses->api2($file->{srv_id},
									{
										op => 'gen_snapshots',
										file_code	=> $file->{file_real},
										file_id		=> $file->{file_real_id}||$file->{file_id},
										disk_id		=> $file->{disk_id},
										preview		=> $f->{ss},
									});
		print"Content-type:text/html\n\n";
		print q[<Table class="tbl1" cellpadding=2 width=780><TR><TH>Preview snapshots</TH></TR>];
		for(grep {$_} split /\n/, $res)
		{
			my $rand = $ses->randchar(6);
			print qq[<tr align=center><td><a href="#new" onclick="\$('#ss').val('$_');"><img src="$file->{srv_htdocs_url}/i/tmp/$file->{file_real}/$_.jpg?$rand"></a>];
		}
		print"</Table>";
		return;
	}

	if($f->{upload_new} && $c->{m_s_upload})
	{
		my $file = $db->SelectRow("SELECT * FROM Files f, Servers s WHERE f.file_code=? AND f.usr_id=? AND f.srv_id=s.srv_id",$f->{file_code},$ses->getUserId);
		return $ses->message("No file") unless $file;

		my $reqs = $ses->checkEventRate($ses->getUserId, 'thumbup', 3 ); # 3 requests per minute limit
		return $ses->message("Too many requests from you!") if $reqs >= 3;

		my $uid=$ses->getUserId;
		my $thumb = "$c->{site_path}/captchas/th$uid.jpg";
		uploadMoveFile('file', $thumb)|| return $ses->message("Upload error:$!");

		require GD;
		my $im = new GD::Image($thumb) || return $ses->message("Failed to read the image");
		my ($w,$h) = $im->getBounds();
		return $ses->message("Invalid image") unless $w && $h;
		return $ses->message("Image is too large ($w x $h)") if $w>1600 || $h>1200;

		my $h = [
					dl_key=>$c->{dl_key},
					op			=> 'thumb_upload',
					disk_id	=> $file->{disk_id},
					file_id	=> $file->{file_real_id}||$file->{file_id},
					file_code  => $file->{file_real},
					file		=> [$thumb]
				];
		require HTTP::Request::Common;
		require LWP::UserAgent;
		my $ua = LWP::UserAgent->new(agent=>$c->{user_agent},timeout=>300);
		my $req = HTTP::Request::Common::POST( "$file->{srv_cgi_url}/api.cgi", Content_Type => 'form-data', Content => $h);
		my $res = $ua->request($req)->content;
		unlink($thumb);
		return $ses->message("Upload error: $res") unless $res=~/^OK$/i;
		return $ses->redirect("?op=file_edit&file_code=$file->{file_code}&newshot=1");
	}

	my $res = $ses->api2($file->{srv_id},{
							op => 'gen_snapshots',
							file_code	=> $file->{file_real},
							file_id		=> $file->{file_real_id}||$file->{file_id},
							disk_id		=> $file->{disk_id},
							file_length	=> $file->{file_length},
							m_s_samples	=> $c->{m_s_samples},
							});
	return $ses->message($res) unless $res=~/^\d+/;
	my $cx;
	my @list = map { {url=>"$file->{srv_htdocs_url}/i/tmp/$file->{file_real}/$_.jpg", 'ss'=>$_, 'tr'=>$cx++%2} } grep {$_} split /\n/, $res;

	$ses->PrintTemplate("my_snapshot.html",
						%$file,
						list => \@list,
						m_s_upload => $c->{m_s_upload},
						);
}

sub MyFilesDeleted
{
	if($f->{hide})
	{
		$db->Exec("UPDATE FilesTrash SET hide=1 WHERE usr_id=?",$ses->getUserId);
		return $ses->redirect("?op=my_files_deleted");
	}
	if($f->{restore} && $f->{file_code})
	{
		my $ids = join("','",grep{/^\w{12}$/}@{ARef($f->{file_code})});
		return $ses->redirect($c->{site_url}) unless $ids;
		my $list = $db->SelectARef("SELECT * FROM FilesTrash WHERE usr_id=? AND file_code IN ('$ids')",$ses->getUserId);
		for my $x (@$list)
		{
			unless($x->{del_by}==$ses->getUserId)
			{
				$x->{file_code} = $ses->randchar(12);
				while($db->SelectOne("SELECT file_id FROM Files WHERE file_code=? OR file_real=?",$x->{file_code},$x->{file_code})){$x->{file_code} = $ses->randchar(12);}
			}
			delete @$x{'file_deleted', 'del_by', 'hide', 'cleaned'};
			$x->{file_fld_id}=0 unless $db->SelectOne("SELECT fld_id FROM Folders WHERE fld_id=? AND usr_id=?",$x->{file_fld_id},$ses->getUserId);
			
			my (@par,@val);
			for(keys %$x)
			{
				push @par, "$_=?";
				push @val, $x->{$_};
			}
			$db->Exec("INSERT INTO Files SET ".join(',',@par), @val);

			$db->Exec("DELETE FROM FilesTrash WHERE file_id=? AND usr_id=?",$x->{file_id},$ses->getUserId);
			$db->Exec("DELETE FROM QueueDelete WHERE file_real_id=?",$x->{file_real_id});
		}
		return $ses->redirect_msg("?op=my_files_deleted",@$list." files were restored");
	}
	my $files = $db->SelectARef("SELECT f.*, UNIX_TIMESTAMP()-UNIX_TIMESTAMP(file_deleted) as ago
								FROM FilesTrash f 
								WHERE f.usr_id=?
								AND hide=0
								ORDER BY file_deleted DESC",$ses->getUserId);
	my $reals= join "','", map{$_->{file_real}} @$files;
	my $canrestore1 = $db->SelectARef("SELECT DISTINCT file_real FROM Files WHERE file_real IN ('$reals')");
	my $canrestore2 = $db->SelectARef("SELECT DISTINCT file_real FROM QueueDelete WHERE file_real IN ('$reals')");

	my %can = map{ $_->{file_real}=>1 } @$canrestore1,@$canrestore2;

	for(@$files)
	{
		$_->{ago} = sprintf("%.0f",$_->{ago}/60);
		$_->{ago} = $_->{ago}<180 ? "$_->{ago} mins" : sprintf("%.0f hours",$_->{ago}/60);
		$_->{restore} = $can{$_->{file_real}};
		$_->{own}=" style='color:green'" if $_->{del_by}==$ses->getUserId;
	}
	$ses->PrintTemplate("my_files_deleted.html",
						files => $files,
						);
}

sub ModeratorReports
{
	return $ses->message("Access denied") if !$ses->getUser->{usr_adm} && !($c->{m_d} && $ses->getUser->{usr_mod} && $c->{m_d_a});

	if($f->{file_code})
	{
		return $ses->message("Not allowed in Demo mode") if $c->{demo_mode};
		my $ids = join "','", grep{/^\w{12}$/} @{ARef($f->{file_code})};
		my $files = $db->SelectARef("SELECT * FROM Files WHERE file_code IN ('$ids')") if $ids;
		if($files)
		{
			if($f->{delete_selected})
			{
				$_->{del_money}=$c->{del_money_file_del} for @$files;
				$ses->DeleteFilesMass($files);
			}
			$db->Exec("DELETE FROM Reports WHERE file_code IN ('$ids')");
		}
		return $ses->redirect("?op=moderator_reports");
	}

	my $list = $db->SelectARef("SELECT r.*, f.*, INET6_NTOA(ip) as ip,
								(SELECT u.usr_login FROM Users u WHERE f.usr_id=u.usr_id) as usr_login
								FROM Reports r 
								LEFT JOIN Files f ON r.file_code = f.file_code
								ORDER BY r.created DESC".$ses->makePagingSQLSuffix($f->{page}));
	my $total = $db->SelectOne("SELECT COUNT(*)
								FROM Reports r");
	for(@$list)
	{
		$_->{site_url} = $c->{site_url};
		$_->{info} =~ s/\n/<br>/gs;
	}
	$ses->PrintTemplate("moderator_reports.html",
						'list'	=> $list,
						'paging'  => $ses->makePagingLinks($f,$total),
						);
}

sub ModeratorComments
{
	return $ses->message("Access denied") unless $c->{m_d} && $ses->getUser->{usr_mod} && $c->{m_d_c};
	if($f->{del_selected} && $f->{cmt_id})
	{
		my $ids = join(',',grep{/^\d+$/}@{ARef($f->{cmt_id})});
		return $ses->redirect($c->{site_url}) unless $ids;
		$db->Exec("DELETE FROM Comments WHERE cmt_id IN ($ids)");
		return $ses->redirect("?op=moderator_comments");
	}
	if($f->{rr})
	{
		return $ses->redirect( CommentRedirect(split(/-/,$f->{rr})) );
	}
	my $filter;
	$filter="WHERE c.cmt_ip=INET6_ATON('$f->{ip}')" if $f->{ip}=~/^[\d\.]+$/;
	$filter="WHERE c.usr_id=$f->{usr_id}" if $f->{usr_id}=~/^\d+$/;
	$filter="WHERE c.cmt_name LIKE '%$f->{key}%' OR c.cmt_email LIKE '%$f->{key}%' OR c.cmt_text LIKE '%$f->{key}%'" if $f->{key}=~/^[\w-]+$/;
	my $list = $db->SelectARef("SELECT c.*, INET6_NTOA(c.cmt_ip) as ip, u.usr_login, u.usr_id
								FROM Comments c
								LEFT JOIN Users u ON c.usr_id=u.usr_id
								$filter
								ORDER BY created DESC".$ses->makePagingSQLSuffix($f->{page},$f->{per_page}));
	my $total = $db->SelectOne("SELECT COUNT(*) FROM Comments c $filter");
	$ses->PrintTemplate("moderator_comments.html",
						'list'	=> $list,
						'key'	=> $f->{key}, 
						'paging' => $ses->makePagingLinks($f,$total),
						);
}

sub AddToPlaylist
{
	print"Content-type:text/html\n\n";
	my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=?",$f->{file_code});
	print("ERROR: file not found"),return unless $file;
	print("ERROR: token error"),return unless $ses->checkToken;
	if($f->{new})
	{
		$f->{new} = $ses->SecureStr($f->{new});
		my $code = $ses->randchar(6);
		while($db->SelectOne("SELECT pls_id FROM Playlists WHERE pls_code=?",$code)){$code = $ses->randchar(6);}
		$db->Exec("INSERT INTO Playlists SET usr_id=?, pls_code=?, pls_name=?", $ses->getUserId, $code, $f->{new} );
		$f->{pls_id} = $db->getLastInsertId;
	}
	if($f->{pls_id} eq 'watchlater')
	{
		$f->{pls_id} = $db->SelectOne("SELECT pls_id FROM Playlists WHERE usr_id=? AND pls_name='Watch later'",$ses->getUserId);
		unless($f->{pls_id})
		{
			my $code = $ses->randchar(6);
			while($db->SelectOne("SELECT pls_id FROM Playlists WHERE pls_code=?",$code)){$code = $ses->randchar(6);}
			$db->Exec("INSERT INTO Playlists SET usr_id=?, pls_code=?, pls_name=?", $ses->getUserId, $code, 'Watch later' );
			$f->{pls_id} = $db->getLastInsertId;
		}
	}
	my $plist = $db->SelectRow("SELECT * FROM Playlists WHERE pls_id=? AND usr_id=?", $f->{pls_id}, $ses->getUserId );
	print("ERROR: playlist not found"),return unless $plist;

	$db->Exec("INSERT IGNORE INTO Files2Playlists SET pls_id=?, file_id=?", $f->{pls_id}, $file->{file_id} );

	print"<b>File added to playlist <a href='$c->{site_url}/playlist/$plist->{pls_code}'>$plist->{pls_name}</a></b>";
	return;
}

sub MyPlaylists
{
	if($f->{del_playlist}=~/^\d+$/ && $f->{token} && $ses->checkToken)
	{
		my $plist = $db->SelectRow("SELECT * FROM Playlists WHERE pls_id=? AND usr_id=?", $f->{del_playlist}, $ses->getUserId );
		return $ses->message("Playlist not found") unless $plist;
		$db->Exec("DELETE FROM Files2Playlists WHERE pls_id=?",$plist->{pls_id});
		$db->Exec("DELETE FROM Playlists WHERE pls_id=?",$plist->{pls_id});
		return $ses->redirect("?op=my_playlists");
	}
	my $list = $db->SelectARef("SELECT p.*, COUNT(f.file_id) as num
								FROM Playlists p
								LEFT JOIN Files2Playlists f ON p.pls_id=f.pls_id
								WHERE p.usr_id=? GROUP BY pls_id", $ses->getUserId );

	$ses->PrintTemplate("my_playlists.html",
						list  => $list,
						token => $ses->genToken,
						);
}

sub MyPlaylistFiles
{
	my $plist = $db->SelectRow("SELECT * FROM Playlists WHERE pls_id=? AND usr_id=?", $f->{pls_id}, $ses->getUserId );
	return $ses->message("Playlist not found") unless $plist;
	if($f->{remove} && $f->{file_id})
	{
		my $ids = join(',',grep{/^\d+$/}@{ARef($f->{file_id})}) || 0;
		$db->Exec("DELETE FROM Files2Playlists WHERE pls_id=? AND file_id IN ($ids)", $f->{pls_id} );
		return $ses->redirect("?op=my_playlist_files&pls_id=$f->{pls_id}");
	}
	my $files = $db->SelectARef("SELECT * FROM Files f, Files2Playlists f2p WHERE f2p.pls_id=? AND f2p.file_id=f.file_id", $plist->{pls_id} );
	for(@$files)
	{
		$_->{file_descr} = $ses->shortenString( $_->{file_descr}, 50 );

		$_->{file_title_txt} = $ses->shortenString( $_->{file_title}||$_->{file_name}, $c->{display_max_filename} );

		$_->{download_link} = $ses->makeFileLink($_);

		$ses->getVideoInfo($_);
	}
	$ses->PrintTemplate("my_playlist_files.html",
						files  => $files,
						token  => $ses->genToken,
						pls_id => $plist->{pls_id},
						%$plist,
						);
}

sub getAffiliate
{
	my $usr_id = $ses->getUser ? $ses->getUserId : 0;

	my $aff_id;
	$aff_id = $ses->getCookie('aff')||0;
	$aff_id = 0 if $aff_id==$usr_id;
	my $aff_id_db = $db->SelectOneCached("SELECT usr_aff_id FROM Users WHERE usr_id=?",$usr_id) if $usr_id;
	$aff_id = $aff_id_db if $aff_id_db && !$aff_id;
	return($aff_id||0);
}

sub AjaxNewFolder
{
	$f->{create_new_folder} = $ses->SecureStr($f->{create_new_folder});
	return $ses->amessage("Invalid folder name!") unless $f->{create_new_folder};
	return $ses->amessage("Invalid parent folder") if $f->{fld_id} && !$db->SelectOne("SELECT fld_id FROM Folders WHERE usr_id=? AND fld_id=?",$ses->getUserId,$f->{fld_id});
	return $ses->amessage("You already have folder with this name!") if $db->SelectOne("SELECT fld_id FROM Folders WHERE usr_id=? AND fld_parent_id=? AND fld_name=?",$ses->getUserId,$f->{fld_id},$f->{create_new_folder});
	return $ses->amessage("$c->{max_folders_limit} folders limit reached!") if $db->SelectOne("SELECT COUNT(*) FROM Folders WHERE usr_id=?",$ses->getUserId) >= $c->{max_folders_limit};
	my $code = $ses->randchar(10);
	while($db->SelectOne("SELECT fld_id FROM Folders WHERE fld_code=?",$code)){$code = $ses->randchar(10);}
	$db->Exec("INSERT INTO Folders SET usr_id=?, fld_parent_id=?, fld_name=?, fld_code=?",$ses->getUserId,$f->{fld_id}||0,$f->{create_new_folder},$code);
	my $fld_id = $db->getLastInsertId;
	$db->PurgeCache( "ufld-$f->{fld_id}-".$ses->getUserId );
	return $ses->amessage("<option value='$fld_id'>$f->{create_new_folder}</option>");
}

sub UploadSRT
{
	$ses->{xframe}=1;
	$ses->{form}->{no_hdr}=1;
	return $ses->message("Mod not enabled") unless $c->{m_g};
	return $ses->message("Invalid code") unless $f->{file_code}=~/^\w{12}$/;
	if($f->{srt} || $f->{url})
	{
		my $ok = saveSRT();
		print"Content-type:text/html\n\n";
		print"<script>window.parent.location.reload(false);</script>" if $ok;
		return;
	}

	#my @langs = map{{value=>$_}} split /\s*\,\s*/, $c->{srt_langs};
	my @srt_langs = map{/^(\w+)=(\w+)$/;{value=>$1,title=>"$2 ($1)"}} split /\s*\,\s*/, $c->{srt_auto_langs};

	$ses->setCookie("srt_cook",$ses->randchar(6),"+90d") unless $ses->getCookie("srt_cook");

	$ses->PrintTemplate("upload_srt.html",
						file_code => $f->{file_code},
						srt_langs => \@srt_langs,
						srt_allow_url_upload => $c->{srt_allow_url_upload},
						);
}

sub saveSRT
{
	my ($local_file) = @_;
	return $ses->message("Language required") unless $f->{srt_lang}=~/^\w+$/i;
	my $file = $db->SelectRow("SELECT * 
								FROM Files f, Servers s
								WHERE f.file_code=?
								AND f.srv_id=s.srv_id",$f->{file_code});
	return $ses->message("No file") unless $file;
	return $ses->message("Not your file") if $f->{op} ne 'upload_srt' && $ses->getUserId!=$file->{usr_id};

	my $srt_cook='';
	if($f->{op} eq 'upload_srt')
	{
		$srt_cook = $ses->getCookie("srt_cook");
		return $ses->message("No SRT cook") unless $srt_cook=~/^\w{6}$/;
		$srt_cook="_$srt_cook";
		$srt_cook='' if $file->{usr_id}==$ses->getUserId;
	}

	my $dx = sprintf("%05d",$file->{file_real_id}/$c->{files_per_folder});
	my $dir = "$c->{site_path}/srt/$dx";
	mkdir($dir,0777) unless -d $dir;

	my $ext;
	if($f->{srt})
	{
		($ext) = $f->{srt}=~/\.(srt|vtt)$/i;
		return $ses->message("Not SRT/VTT file") unless $ext;
	}
	else
	{
		($ext) = $f->{url}=~/\.(srt|vtt)$/i;
		$ext||='srt';
	}
	$ext = lc $ext;

	my $data;
	if($local_file && -s $local_file)
	{
		open(SRT,$local_file);
		$data = join '', <SRT>;
		close SRT;
	}
	elsif($f->{srt})
	{
		my $fh = $ses->{cgi_query}->upload('srt');
		$data = join '', <$fh>;
	}
	elsif($f->{url} && $c->{srt_allow_url_upload})
	{
		my $reqs = $ses->checkEventRate($ses->getUserId, 'srturl', 2 ); # requests per minute limit
		return $ses->message("Too many requests from you!") if $reqs >= 2;
		require LWP::UserAgent;
		my $lwp = LWP::UserAgent->new( agent => $c->{lwp_user_agent}, timeout => 10 );
		#$lwp->proxy(https => 'http://user:pass@proxy');
		$data = $lwp->get($f->{url})->content;
	}

	return $ses->message("No subtitle data") unless $data;

	if( $c->{srt_max_size_kb} && length($data) > $c->{srt_max_size_kb}*1024 )
	{
		return $ses->message("Max subtitle size is $c->{srt_max_size_kb}KB");
	}

	if( $data=~/\<\?php/i )
	{
		return $ses->message("Invalid file format");
	}

	#if($ext eq 'srt')
	unless($data=~/WEBVTT/i)
	{
		#utf8::decode($data);
		
		require Encode;
		#Encode::from_to($data,'cp1252','utf8');

		# check if SRT is UTF8, else decode from CP1252
		my $content;
		eval { $content = Encode::decode('utf-8', $data, 1); };
		Encode::from_to($data,'cp1252','utf8') unless $content;
		$data||=$content;

		$data=~s/\r//gs;
		$data=~s/^\D+\d\n//;
		$data=~s/(\d\d:\d\d:\d\d),(\d\d\d)/$1\.$2/gi;
		$data="WEBVTT\n\n$data";
		$data=~s/\n\d+\n/\n/gs;
		
		#utf8::encode($data);
	}

	if($srt_cook)
	{
		open (VTT,  ">$dir/$file->{file_code}_$f->{srt_lang}$srt_cook.vtt") || die"can't open vtt file:$!";
		#binmode(VTT, ":utf8");
		print VTT $data;
		close VTT;
	}
	else
	{
		my $no_db_update = 1; #$file->{file_captions} && $f->{srt_lang}=~m/$file->{file_captions}/ ? 1 : 0;
		$db->Exec("UPDATE Files 
					SET file_captions = CASE WHEN LENGTH(file_captions)=0 THEN ? ELSE CONCAT(file_captions,'|',?) END 
						WHERE file_id=?", $f->{srt_lang}, $f->{srt_lang}, $file->{file_id} );
		$db->Exec("INSERT INTO QueueVTT 
						SET file_real_id=?,
						file_code=?,
						host_id=?,
						disk_id=?,
						language=?,
						no_db_update=?,
						data=?",
						$file->{file_real_id},
						$file->{file_code},
						$file->{host_id},
						$file->{disk_id},
						$f->{srt_lang},
						$no_db_update,
						$data);
	}

	return 1;
}

sub MyFilesDMCA
{
	if($f->{new_code}=~/^\w{12}$/)
	{
		my $file = $db->SelectRow("SELECT * FROM Files WHERE file_code=? AND usr_id=?", $f->{new_code}, $ses->getUserId);
		print("Content-type:text/html\n\nNo file"),return unless $file;
		my $code = $ses->randchar(12);
		while($db->SelectOne("SELECT file_id FROM Files WHERE file_code=? OR file_real=?",$code,$code)){$code = $ses->randchar(12);}
		$db->Exec("DELETE FROM FilesDMCA WHERE file_id=?", $file->{file_id});
		$db->Exec("UPDATE Files SET file_status='OK', file_code=? WHERE file_code=?", $code, $file->{file_code});
		$file->{file_code} = $code;
		my $link = $ses->makeFileLink($file);
		print("Content-type:text/html\n\n<tt>$file->{file_code}</tt>\t<a href='$link' x2style='margin-left:10px'>link</a>"),return;
	}
	my $files = $db->SelectARef("SELECT *, UNIX_TIMESTAMP()-UNIX_TIMESTAMP(created) as ago, UNIX_TIMESTAMP(del_time)-UNIX_TIMESTAMP() as 'left'
								FROM FilesDMCA d, Files f 
								WHERE d.usr_id=?
								AND d.file_id=f.file_id
								ORDER BY del_time",$ses->getUserId);
	for(@$files)
	{
		$_->{ago} = sprintf("%.0f",$_->{ago}/60);
		$_->{ago} = $_->{ago}<180 ? "$_->{ago} mins" : sprintf("%.0f hours",$_->{ago}/60);

		$_->{left} = sprintf("%.0f",$_->{left}/60);
		$_->{left} = $_->{left}<180 ? "$_->{left} mins" : sprintf("%.0f hours",$_->{left}/60);

		$_->{dl_link} = $ses->makeFileLink($_);
	}
	$ses->PrintTemplate("my_files_dmca.html",
						files => $files,
						);
}

sub MyFilesDMCARenamed
{
	if($f->{clear})
	{
		$db->Exec("DELETE FROM FilesDMCARenamed WHERE usr_id=?", $ses->getUserId );
		return $ses->redirect('?op=my_files');
	}
	my $files = $db->SelectARef("SELECT *, UNIX_TIMESTAMP()-UNIX_TIMESTAMP(created) as ago
								FROM FilesDMCARenamed d, Files f 
								WHERE d.usr_id=?
								AND d.file_id=f.file_id",$ses->getUserId);
	for(@$files)
	{
		$_->{ago} = sprintf("%.0f",$_->{ago}/60);
		$_->{ago} = $_->{ago}<180 ? "$_->{ago} mins" : sprintf("%.0f hours",$_->{ago}/60);
		$_->{dl_link} = $ses->makeFileLink($_);
	}
	$ses->PrintTemplate("my_files_dmca_renamed.html",
						files => $files,
						);
}

sub resizeGD
{
	my ($im,$w2,$h2,$file) = @_;
	my ($w,$h) = $im->getBounds();
	if($w>$h){ $h2 = int $w2/$w*$h; } else { $w2 = int $h2/$h*$w; }
	my $im2 = new GD::Image($w2, $h2);
	#$im2->transparent( $im->transparent() ); 
	$im2->copyResampled($im, 0,0, 0,0, $w2,$h2, $w,$h );
	open OUT, ">$file" or die"cant open file for write: $!";
	print OUT $im2->jpeg(95);
	close OUT;
}

sub StreamForm
{
	my $stream={};
	if($f->{stream_id}=~/^\d+$/)
	{
		$stream = $db->SelectRow("SELECT * 
									FROM Streams s
									LEFT JOIN Hosts h ON s.host_id=h.host_id
									WHERE s.stream_id=?
									",$f->{stream_id});
		unless( streamFindHost($stream->{host_id}||0) )
		{
			$stream->{host_id} = streamFindHost();
			return $ses->message("No streaming servers are available at the moment") unless $stream->{host_id};
			$db->Exec("UPDATE Streams SET host_id=? WHERE stream_id=?",$stream->{host_id},$stream->{stream_id});
			return $ses->redirect("?op=stream_form&stream_id=$stream->{stream_id}");
		}
		$stream->{rtmp_url} = $stream->{host_cgi_url};
		$stream->{rtmp_url}=~s/^https?/rtmp/i;
		$stream->{rtmp_url}=~s/\/cgi-bin//i;
		$stream->{rtmp_url}=~s/:\d+$//i;
	}
	$stream->{host_id} ||= streamFindHost();
	$stream->{m_q_allow_recording} = $c->{m_q_allow_recording};
	return $ses->message("No streaming servers are available at the moment") unless $stream->{host_id};
	$ses->PrintTemplate("stream_form.html",
								%$stream,
							  );
}

sub streamFindHost
{
	my ($host_id) = @_;
	my $filter_host="AND h.host_id=$host_id" if defined $host_id;
	return $db->SelectOne("SELECT h.host_id 
							FROM Hosts h, Servers s 
							WHERE h.host_live=1 
							AND h.host_id=s.host_id
							AND s.srv_status IN ('ON','READONLY')
							AND srv_disk <= srv_disk_max*0.95 
							$filter_host
							GROUP BY host_id
							ORDER BY host_out/host_net_speed 
							LIMIT 1");
}

sub StreamSave
{
	$f->{stream_id}=~s/\D+//g;
	$f->{stream_title}  = $ses->SecureStr($f->{stream_title});
	$f->{stream_descr} = $ses->SecureStr($f->{stream_descr});
	$f->{stream_record}=0 unless $c->{m_q_allow_recording};
	if($f->{stream_id})
	{
		$db->Exec("UPDATE Streams 
					SET stream_title=?, 
						stream_descr=?,
						stream_record=?
					WHERE stream_id=? 
						AND usr_id=?", $f->{stream_title}, $f->{stream_descr}, $f->{stream_record}||'', $f->{stream_id}, $ses->getUserId);
	}
	else
	{
		return $ses->message("You have too many streams") if $db->SelectOne("SELECT COUNT(*) FROM Streams WHERE usr_id=?",$ses->getUserId) >= 10;
		my $code = $ses->randchar(10);
		  while($db->SelectOne("SELECT stream_id FROM Streams WHERE stream_code=?",$code)){$code = $ses->randchar(10);}
		  my $key = $ses->randchar(6);
		$db->Exec("INSERT INTO Streams 
					SET stream_title=?, 
						stream_descr=?,
						stream_record=?,
						stream_code=?,
						stream_key=?,
						usr_id=?,
						host_id=?,
						created=NOW()",
						$f->{stream_title},
						$f->{stream_descr},
						$f->{stream_record}||'',
						$code,
						$key,
						$ses->getUserId,
						$f->{host_id},
						);
		$f->{stream_id} = $db->getLastInsertId;
	}
	return $ses->redirect_msg("?op=stream_form&stream_id=$f->{stream_id}","Changes saved");
}

sub MyStreams
{
	 return $ses->message("You're not allowed to create streams") unless $ses->checkModSpecialRights('m_q');
	 if($f->{del}=~/^\d+$/ && $f->{token} && $ses->checkToken)
	 {
		  my $stream = $db->SelectRow("SELECT * FROM Streams WHERE stream_id=? AND usr_id=?", $f->{del}, $ses->getUserId );
		  return $ses->message("Stream not found") unless $stream;
		  $db->Exec("DELETE FROM Streams WHERE stream_id=?",$stream->{stream_id});
		  $db->Exec("DELETE FROM Stream2IP WHERE stream_id=?",$stream->{stream_id});
		  return $ses->redirect_msg("?op=my_streams","Stream deleted.");
	 }
	 my $list = $db->SelectARef("SELECT s.*,
	 							(SELECT COUNT(*) FROM Stream2IP i WHERE i.stream_id=s.stream_id AND i.created>NOW()-INTERVAL 60 SECOND) as watchers
								FROM Streams s
								WHERE s.usr_id=?", $ses->getUserId );

	 $ses->PrintTemplate("my_streams.html",
								list  => $list,
								token => $ses->genToken,
							 );
}

sub uploadMoveFile
{
	my ($name,$file) = @_;
	require File::Copy;
	File::Copy::move( $ses->{cgi_query}->tmpFileName($ses->{cgi_query}->upload($name)), $file ) || return 0;
	return 1;
}

sub TicketCreate
{
	 return $ses->redirect($c->{site_url}) unless $c->{m_e};
	 if($f->{save})
	 {
		  return $ses->message("Title and Message are required fields") unless $f->{ti_title} && $f->{message};

		  $f->{category}=~s/\W+//g;

		  $db->Exec("INSERT INTO Tickets 
		  			SET usr_id=?,
		  			ti_title=?,
		  			category=?,
		  			created=NOW(),
		  			updated=NOW(),
		  			open=1,
		  			unread_adm=1
		  			", $ses->getUserId, 
		  			$f->{ti_title},
		  			$f->{category} );
		  my $ti_id = $db->getLastInsertId;

		  $db->Exec("INSERT INTO TicketMessages
		  			SET ti_id=?,
		  			usr_id=?,
		  			msg_ip=INET6_ATON(?),
		  			message=?, 
		  			created=NOW()", $ti_id, $ses->getUserId, $ses->getIP, $f->{message} );

		  return $ses->redirect("?op=ticket_view&ti_id=$ti_id");
	 }
	 my @categories = map{{category => $_}} split /\s*,\s*/, $c->{ticket_categories};
	 $ses->PrintTemplate("ticket_create.html",
	 					categories => \@categories,
	 					);
}

sub TicketReply
{
	return $ses->redirect($c->{site_url}) unless $c->{m_e};
	my $t = $db->SelectRow("SELECT * FROM Tickets WHERE ti_id=? AND usr_id=?", $f->{ti_id}, $ses->getUserId );
	return $ses->message("No such ticket") unless $t;

	return $ses->redirect("?op=ticket_view&ti_id=$t->{ti_id}") unless length($f->{message})>1;

	$db->Exec("INSERT INTO TicketMessages
				SET ti_id=?,
		  		usr_id=?,
		  		msg_ip=INET6_ATON(?),
		  		message=?, 
		  		created=NOW()", $t->{ti_id}, $ses->getUserId, $ses->getIP, $f->{message} );

	$db->Exec("UPDATE Tickets SET updated=NOW(), open=1, unread_adm=unread_adm+1, replied=0 WHERE ti_id=?", $t->{ti_id} );

	if($c->{ticket_email_admin})
	{
		# Send email to Admin
		my $adm_usr_id = $db->SelectOne("SELECT usr_id FROM TicketMessages WHERE ti_id=? AND usr_id<>? ORDER BY msg_id DESC LIMIT 1", $t->{ti_id}, $ses->getUserId );
		$adm_usr_id  ||= $db->SelectOne("SELECT usr_id FROM Users WHERE usr_adm=1");
		my $adm_email = $db->SelectOneCached("SELECT usr_email FROM Users WHERE usr_id=?",$adm_usr_id);
		my $tt = $ses->CreateTemplate("ticket_reply_email.html");
		$tt->param( 'ti_id'=> $t->{ti_id}, 
					message => $f->{message} );
		$ses->SendMailQueue($adm_email, $c->{email_from}, "$c->{site_name}: Ticket $t->{ti_id} replied", $tt->output);
	}

	return $ses->redirect("?op=ticket_view&ti_id=$t->{ti_id}");
}

sub TicketList
{
	 return $ses->redirect($c->{site_url}) unless $c->{m_e};
	 my $list = $db->SelectARef("SELECT * 
	 							FROM Tickets 
	 							WHERE usr_id=? 
	 							AND open=1
	 							ORDER BY updated DESC 
	 							LIMIT 30", $ses->getUserId );

	 for(@$list)
	{
	  $_->{updated}=~s/:\d\d$//;
	}

	 $ses->PrintTemplate("ticket_list.html", 
	 					list => $list 
	 					);
}

sub TicketView
{
	return $ses->redirect($c->{site_url}) unless $c->{m_e};
	my $t = $db->SelectRow("SELECT * FROM Tickets WHERE ti_id=? AND usr_id=?", $f->{ti_id}, $ses->getUserId );
	return $ses->message("No such ticket") unless $t;

	if($f->{close})
	{
		$db->Exec("UPDATE Tickets SET updated=NOW(), open=0 WHERE ti_id=?", $t->{ti_id} );
		return $ses->redirect("?op=ticket_list");
	}

	my $messages = $db->SelectARef("SELECT m.*, u.usr_login FROM TicketMessages m, Users u 
									WHERE m.ti_id=? 
									AND m.usr_id=u.usr_id
									ORDER BY created", $f->{ti_id} );


	for(@$messages)
	{
	  $_->{message}=~s/\n/<br>/g;
	  $_->{created}=~s/:\d\d$//;
	  $_->{mine} = $_->{usr_id}==$ses->getUserId ? 1 : 0;
	}

	$db->Exec("UPDATE Tickets SET unread=0 WHERE ti_id=?", $t->{ti_id} ) if $t->{unread};

	 $ses->PrintTemplate("ticket_view.html", 
	 					%$t,
	 					messages => $messages,
	 					);
}

###

sub AdminTicketList
{
	 my $is_moderator = $c->{ticket_moderator_ids} && $ses->getUserId=~/^$c->{ticket_moderator_ids}$/ ? 1 : 0;
	 return $ses->message("Access denied") unless $ses->getUser->{usr_adm} || $is_moderator;

	 my $filter_open = $f->{show_closed} ? "" : "AND open=1";
	 my $filter_replied = $f->{show_replied}||$f->{show_closed} ? "" : "AND replied=0";
	 my $filter_days = $f->{days}=~/^\d+$/ ? " AND updated>NOW()-INTERVAL $f->{days} DAY" : "";
	 if($f->{usr_login})
	 {
		 $f->{usr_id} = $db->SelectOne("SELECT usr_id FROM Users WHERE usr_login=?", $f->{usr_login} );
		 $f->{usr_login}='';
	 }
	 my $filter_usr_id = $f->{usr_id}=~/^\d+$/ ? " AND t.usr_id=$f->{usr_id}" : "";
	 my $filter_ids;
	 if($f->{key})
	 {
		 my @ids;
		 my $ids1 = $db->SelectARef(qq|SELECT ti_id FROM Tickets WHERE ti_title LIKE "%$f->{key}%" $filter_days $filter_usr_id|);
		 push @ids, map{ $_->{ti_id} } @$ids1;
		 my $filter_days2 = $f->{days}=~/^\d+$/ ? " AND created>NOW()-INTERVAL $f->{days} DAY" : "";
		 my $ids2 = $db->SelectARef(qq|SELECT DISTINCT ti_id FROM TicketMessages t WHERE message LIKE "%$f->{key}%" $filter_days2 $filter_usr_id|);
		 push @ids, map{ $_->{ti_id} } @$ids2;
		 $filter_ids = "AND ti_id IN (".join(',',@ids).")" if @ids;
	 }
	 my $filter_category="AND category='$f->{category}'" if $f->{category}=~/^\w+$/;
	 my $filter_moderator="";
	 if($is_moderator && $c->{ticket_moderator_categories})
	 {
	 	my $cats = join ',', map{"'$_'"} split /\s*\,\s*/, $c->{ticket_moderator_categories};
	 	$filter_moderator="AND category IN ($cats)" if $cats;
	 }

	 my $list = $db->SelectARef("SELECT t.*, u.usr_login
	 							FROM Tickets t, Users u
	 							WHERE t.usr_id=u.usr_id
	 							$filter_open
	 							$filter_replied
	 							$filter_days
	 							$filter_usr_id
	 							$filter_ids
	 							$filter_category
	 							$filter_moderator
	 							ORDER BY updated DESC 
	 							".$ses->makePagingSQLSuffix($f->{page}) );

	my $total = $db->SelectOne("SELECT COUNT(*) FROM Tickets t 
								WHERE 1
								$filter_open
								$filter_replied
								$filter_days
								$filter_usr_id
								$filter_ids
								$filter_category
								$filter_moderator
								");

	for(@$list)
	{
	  $_->{updated}=~s/:\d\d$//;
	}

	my @categories = map{{category => $_, selected=>$_ eq $f->{category}?1:0}} split /\s*,\s*/, $c->{ticket_categories};

	 $ses->PrintTemplate("admin_ticket_list.html", 
	 					list => $list,
	 					paging => $ses->makePagingLinks($f,$total), 
	 					show_closed	=> $f->{show_closed},
	 					show_replied=> $f->{show_replied},
	 					days		=> $f->{days},
	 					usr_id		=> $f->{usr_id},
	 					key			=> $f->{key},
	 					categories	=> \@categories,
	 					);
}

sub AdminTicketView
{
	my $is_moderator = $c->{ticket_moderator_ids} && $ses->getUserId=~/^$c->{ticket_moderator_ids}$/ ? 1 : 0;
	 return $ses->message("Access denied") unless $ses->getUser->{usr_adm} || $is_moderator;

	 my $filter_moderator="";
	 if($is_moderator && $c->{ticket_moderator_categories})
	 {
	 	my $cats = join ',', map{"'$_'"} split /\s*\,\s*/, $c->{ticket_moderator_categories};
	 	$filter_moderator="AND category IN ($cats)" if $cats;
	 }

	my $t = $db->SelectRow("SELECT t.*, u.usr_login 
							FROM Tickets t, Users u 
							WHERE t.ti_id=? 
							AND t.usr_id=u.usr_id
							$filter_moderator", $f->{ti_id} );
	return $ses->message("No such ticket") unless $t;

	if($f->{close})
	{
		$db->Exec("UPDATE Tickets SET updated=NOW(), open=0 WHERE ti_id=?", $t->{ti_id} );
		return $ses->redirect("?op=admin_ticket_list");
	}

	my $messages = $db->SelectARef("SELECT m.*, u.usr_login, INET6_NTOA(m.msg_ip) as ip
									FROM TicketMessages m, Users u 
									WHERE m.ti_id=? 
									AND m.usr_id=u.usr_id
									ORDER BY created", $f->{ti_id} );


	for(@$messages)
	{
	  $_->{message}=~s/\n/<br>/g;
	  $_->{created}=~s/:\d\d$//;
	  $_->{mine} = $_->{usr_id}==$ses->getUserId ? 1 : 0;
	}

	$db->Exec("UPDATE Tickets SET unread_adm=0 WHERE ti_id=?", $t->{ti_id} ) if $t->{unread_adm};

	 $ses->PrintTemplate("admin_ticket_view.html", 
	 					%$t,
	 					messages => $messages,
	 					);
}

sub AdminTicketReply
{
	my $is_moderator = $c->{ticket_moderator_ids} && $ses->getUserId=~/^$c->{ticket_moderator_ids}$/ ? 1 : 0;
	 return $ses->message("Access denied") unless $ses->getUser->{usr_adm} || $is_moderator;

	 my $filter_moderator="";
	 if($is_moderator && $c->{ticket_moderator_categories})
	 {
	 	my $cats = join ',', map{"'$_'"} split /\s*\,\s*/, $c->{ticket_moderator_categories};
	 	$filter_moderator="AND category IN ($cats)" if $cats;
	 }
	
	my $t = $db->SelectRow("SELECT * FROM Tickets t, Users u 
							WHERE t.ti_id=? 
							AND t.usr_id=u.usr_id
							$filter_moderator", $f->{ti_id} );
	return $ses->message("No such ticket") unless $t;

	$db->Exec("INSERT INTO TicketMessages
				SET ti_id=?,
		  		usr_id=?,
		  		msg_ip=INET6_ATON(?),
		  		message=?, 
		  		created=NOW()", $t->{ti_id}, $ses->getUserId, $ses->getIP, $f->{message} );

	$db->Exec("UPDATE Tickets SET updated=NOW(), open=1, unread=unread+1, unread_adm=0, replied=1 WHERE ti_id=?", $t->{ti_id} );

	if($c->{ticket_email_user})
	{
		# Send email to User
		my $tt = $ses->CreateTemplate("admin_ticket_reply_email.html");
		$tt->param( 'ti_id'=> $t->{ti_id}, 
					message => $f->{message} );
		$ses->SendMailQueue($t->{usr_email}, $c->{email_from}, "$c->{site_name}: Ticket $t->{ti_id} replied", $tt->output);
	}

	return $ses->redirect("?op=admin_ticket_view&ti_id=$t->{ti_id}");
}

sub APIReference
{
	return $ses->message("API disabled") unless $c->{m_6};
	my $user = $ses->getUser || {};
	$user->{$_} = $c->{$_} for qw(m_6 m_6_clone m_6_direct m_6_delete custom_snapshot_upload srt_allow_url_upload);
	$user->{usr_id}||=45;
	$user->{usr_api_key} ||= $ses->randchar(15);
	$user->{usr_api_key} = "$user->{usr_id}$user->{usr_api_key}";
	$user->{api_url}="$c->{site_url}/api";
	$ses->PrintTemplate("api_reference.html", 
	 					%$user,
	 					);
}

sub MyAds
{
	#$ses->loadUserData();
	return $ses->message("You're not allowed to use this mod") unless $ses->checkModSpecialRights('m_9');

	my $usr_id = $ses->getUserId;
	$usr_id = $f->{usr_id} if $f->{usr_id} && $ses->getUser->{usr_adm};
	
	if($f->{delete_id}=~/^\d+$/)
	{
		$db->Exec("DELETE FROM Ads WHERE ad_id=? AND usr_id=?", $f->{delete_id}, $usr_id );
		return $ses->redirect("?op=my_ads");
	}

	my $ads = $db->SelectARef("SELECT * FROM Ads WHERE usr_id=? AND ad_adult=0",$usr_id);
	my $sum;
	$sum+=$_->{ad_weight} for @$ads;
	$sum||=1;
	for(@$ads)
	{
		$_->{percent} = sprintf("%.0f", 100 * $_->{ad_weight} / $sum );
	}

	my $ads2 = $db->SelectARef("SELECT * FROM Ads WHERE usr_id=? AND ad_adult=1",$usr_id);
	my $sum2;
	$sum2+=$_->{ad_weight} for @$ads2;
	$sum2||=1;
	for(@$ads2)
	{
		$_->{percent} = sprintf("%.0f", 100 * $_->{ad_weight} / $sum2 );
	}

	$ses->PrintTemplate("my_ads.html", 
	 					usr_id	=> $usr_id,
	 					ads		=> $ads,
	 					ads_adult	=> $ads2,
	 					);
}

sub MyAdsForm
{
	if($f->{save})
	{
		my $usr_id = $ses->getUserId;
		$f->{ad_adult}=~s/\D+//g;
		$f->{ad_weight}=~s/\D+//g;
		$f->{ad_disabled}=~s/\D+//g;
		if($f->{ad_id})
		{
			$db->Exec("UPDATE Ads SET
						ad_code=?,
						ad_title=?,
						ad_adult=?,
						ad_weight=?,
						ad_disabled=?
						WHERE usr_id=? AND ad_id=?
					",  
						$ses->{cgi_query}->param('ad_code'),
						$f->{ad_title},
						$f->{ad_adult}||0,
						$f->{ad_weight}||0,
						$f->{ad_disabled}||0,
						$usr_id,
						$f->{ad_id},
					);
		}
		else
		{
			$db->Exec("INSERT INTO Ads SET
						usr_id=?,
						ad_code=?,
						ad_title=?,
						ad_adult=?,
						ad_weight=?,
						ad_disabled=?
					",  $usr_id,
						$ses->{cgi_query}->param('ad_code'),
						$f->{ad_title},
						$f->{ad_adult}||0,
						$f->{ad_weight}||0,
						$f->{ad_disabled}||0,
					);
		}
		return $ses->redirect("?op=my_ads");
	}

	my $ad;
	if($f->{ad_id})
	{
		$ad = $db->SelectRow("SELECT * FROM Ads WHERE ad_id=?",$f->{ad_id});
	}
	$ses->PrintTemplate("my_ads_form.html", 
	 					%$ad,
	 					);
}

sub Msg
{
	return $ses->PrintTemplate("message.html");
}

sub MyDomains
{
	return $ses->message("You're not allowed to use this mod") unless $ses->checkModSpecialRights('m_y');
	$ses->loadUserData();
	if($f->{default_save})
	{
		if($f->{default_domain} eq '')
		{
			$db->Exec("DELETE FROM UserData WHERE usr_id=? AND name='usr_custom_domain'",$ses->getUserId);
			$ses->redirect_msg("?op=my_domains","Custom Domain disabled");
		}
		my $d = $db->SelectRow("SELECT * FROM Domains WHERE dom_domain=? AND usr_id=?",$f->{default_domain},$ses->getUserId);
		return $ses->message("Domain not found") unless $d;
		$db->Exec("INSERT INTO UserData
					SET usr_id=?, name='usr_custom_domain', value=?
					ON DUPLICATE KEY UPDATE value=?
					", $ses->getUserId, $d->{dom_domain}, $d->{dom_domain});
		$ses->redirect_msg("?op=my_domains","Custom Domain changed to $d->{dom_domain}");
	}
	if($f->{del_dom})
	{
		return $ses->message("Invalid token") unless $ses->checkToken;
		my $d = $db->SelectRow("SELECT * FROM Domains WHERE dom_id=? AND usr_id=?",$f->{del_dom},$ses->getUserId);
		return $ses->message("Domain not found") unless $d;
		if($d->{dom_cf_id})
		{
			$db->Exec("UPDATE Domains SET dom_status='TODELETE' WHERE dom_id=?",$d->{dom_id});
			$ses->redirect_msg("?op=my_domains","Domain queued for deletion");
		}
		else
		{
			$db->Exec("DELETE FROM Domains WHERE dom_id=?",$d->{dom_id});
			$ses->redirect_msg("?op=my_domains","Domain deleted successfully");
		}
	}
	if($f->{new})
	{
		return $ses->message("Invalid token") unless $ses->checkToken;
		$f->{new}=~s/\s+//g;
		$f->{new}=~s/^https?:\/\///i;
		$f->{new}=~s/\/+//;
		return $ses->message("Invalid domain") unless $f->{new}=~/[\w\-]+\w+\.\w{2,}/;
		my $reqs = $ses->checkEventRate($ses->getUserId, 'domadd', 2 ); # 2 requests per minute limit
		return $ses->message("Too many requests from you!") if $reqs >= 2;
		$db->Exec("INSERT INTO Domains 
					SET usr_id=?,
					dom_domain=?,
					dom_status='INIT',
					created=NOW()
					",$ses->getUserId,
					$f->{new});
		$ses->redirect_msg("?op=my_domains","Domain added.<br>Reload page in a few minutes and apply NS servers for this domain.");
	}

	my $list = $db->SelectARef("SELECT * FROM Domains WHERE usr_id=?",$ses->getUserId);
	my @active = grep{$_->{dom_status} eq 'ACTIVE'} @$list;
	$_->{selected}=$_->{dom_domain} eq $ses->getUser->{usr_custom_domain} ? ' selected' : '' for @active;
	$ses->PrintTemplate("my_domains.html",
					list  => $list,
					active => \@active,
					);
}

1;
