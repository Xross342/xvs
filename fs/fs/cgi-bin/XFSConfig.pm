package XFSConfig;
use strict;
#use Net::SSL;
use lib 'Modules';
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;
use Exporter ();
@XFSConfig::ISA    = qw(Exporter);
@XFSConfig::EXPORT = qw($c);
use vars qw( $c );


$c=
{
### Manually configure keys below ###
 cgi_dir => '/var/www/cgi-bin',

 htdocs_dir => '/var/www/htdocs',

 # nginx port (to parse number of current connections)
 nginx_port => '443',

#####################################

 dl_key => '',

 user_agent => '',

 main_server_ip => '',

 host_id => '',

 # Your Main site URL, witout trailing /
 site_url => '',

 # Your Main site cgi-bin URL, witout trailing /
 site_cgi => '',

 # Maximum upload Filesize in Mbytes (0 to disable)
 max_upload_filesize_prem => '1000',

 # Banned IPs
 # Use \d+ for wildcard *
 ip_not_allowed => '^(10.0.0.182)$',

 #Files per dir, do not touch since server start
 files_per_folder => 5000,

 # Video extensions
 video_extensions => 'avi|mkv|mpg|mpeg|vob|wmv|flv|mp4|mov|m4v|m2v|3gp|webm|ogv|ogg',

 # max enc.pl processes
 host_max_enc => '2',

 # max transfer.pl processes
 host_max_trans => '1',

 # max upload_url.pl processes
 host_max_url => '1',

 m_t => '',

 m_z => '',
 m_z_cols => '5',
 m_z_rows => '5',

 thumb_width => '200',
 thumb_height => '112',
 thumb_position => '30%',

 save_html_results => '',

 srt_auto => '',

 custom_snapshot_upload => '300',

 m_f_sync_files_after => '3',

 thumb_quality => '80',

 no_ffmpeg_timeout => '1',

 dirlinks_allowed_referers => '',

 allow_non_video_uploads => '',

};

1;
