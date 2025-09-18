package Plugins::Player::Plyr;
use strict;
use XFileConfig;
use vars qw($ses $c);

sub makePlayerCode {
   my ($self, $f, $file, $c, $player) = @_;
   return if $player ne 'plyr';

   my (@sources, @tracks, $extra_html_pre, $extra_html, $extra_js, $ontime_func, $extra_pause, $js_code_pre);

   # Thumbnail previews (ported from JW8)
   if ($c->{m_z} && $c->{time_slider} && $file->{img_timeslide_url}) {
      my $frames = $c->{m_z_cols} * $c->{m_z_rows};
      my $dt = $file->{file_length} / $frames;
      $extra_js .= qq[
         player.previewThumbnails = {
            enabled: true,
            src: '$file->{img_timeslide_url}'
         };
      ];
   }

   # Video time limit and preview (ported from JW8)
   my $show_box_after_limit = $c->{video_time_limit} ? qq[\$('#play_limit_box').show();] : '';
   my $show_box_after_preview = $file->{preview} ? qq[\$('#over_player_msg').show();] : '';
   my $time_fadein = $c->{player_ads_fadein} || 0;
   my $vtime = int($file->{vid_length} * $c->{track_views_percent} / 100);
   my $x2time = int($vtime / 2);
   my $stop_code = $c->{video_time_limit} ? qq[
      setTimeout(function() {
         player.pause();
         $show_box_after_limit
      }, $c->{video_time_limit} * 1000);
   ] : '';

   # HLS support with quality selection (ported from JW8)
   if ($file->{hls_direct}) {
      push @sources, { src => $file->{hls_direct}, type => 'application/x-mpegURL' };
      $extra_html .= qq[<script src="$c->{cdn_url}/player/hlsjs/hls.js"></script>];
      my @qlabels;
      for my $q ('o', reverse @{$c->{quality_letters}}) {
         next unless $file->{"file_spec_$q"};
         my $vi = $ses->vInfo($file, $q);
         my $bitrate = ($vi->{vid_bitrate} + $vi->{vid_audio_bitrate}) - 1;
         my $qname = $c->{quality_labels}->{$q};
         push @qlabels, qq["$bitrate": "$qname"];
      }
      $extra_js .= qq[
         if (Hls.isSupported()) {
            var hls = new Hls({
               maxBufferLength: 30,
               maxBufferSize: $c->{hls_preload_mb}*1024*1024,
               liveSyncDurationCount: 7,
               maxMaxBufferLength: 600,
               capLevelToPlayerSize: true
            });
            hls.loadSource('$file->{hls_direct}');
            hls.on(Hls.Events.MANIFEST_PARSED, function(event, data) {
               var availableQualities = hls.levels.map(l => l.height);
               availableQualities.unshift(0);
               player.quality = {
                  default: 0,
                  options: availableQualities,
                  forced: true,
                  onChange: function(newQuality) {
                     if (newQuality === 0) {
                        hls.currentLevel = -1;
                     } else {
                        hls.levels.forEach((level, index) => {
                           if (level.height === newQuality) {
                              hls.currentLevel = index;
                           }
                        });
                     }
                  }
               };
               player.i18n = {
                  qualityLabel: {
                     0: 'Auto',
                     @{[join(',', @qlabels)]}
                  }
               };
               hls.on(Hls.Events.LEVEL_SWITCHED, function(event, data) {
                  var span = document.querySelector(".plyr__menu__container [data-plyr='quality'][value='0'] span");
                  if (hls.autoLevelEnabled) {
                     span.innerHTML = `AUTO (\${hls.levels[data.level].height}p)`;
                  } else {
                     span.innerHTML = `AUTO`;
                  }
               });
            });
            hls.attachMedia(document.querySelector('#player'));
            window.hls = hls;
         } else {
            document.querySelector('#player').src = '$file->{hls_direct}';
         }
      ];
   }
   elsif ($file->{dash_direct}) {
      push @sources, { src => $file->{dash_direct}, type => 'application/dash+xml' };
   }
   elsif ($file->{direct_links}) {
      my $links = $file->{direct_links};
      if (ref($links) eq 'ARRAY') {
         for (@$links) {
            if (ref($_) eq 'HASH' && $_->{direct_link}) {
               push @sources, { src => $_->{direct_link}, type => 'video/mp4', label => $_->{label} };
            } elsif (!ref($_)) {
               push @sources, { src => $_, type => 'video/mp4' };
            }
         }
      }
   }

   # Playback rate controls (ported from JW8)
   if ($c->{player_playback_rates}) {
      my @rates = map { sprintf("%.2f", $_) } split /\s*,\s*/, $c->{player_playback_rates};
      $extra_js .= qq[player.speed = { selected: 1, options: [@{[join(',', @rates)]}] };];
   }

   # Captions with styling (ported from JW8)
   if ($c->{srt_on}) {
      my $srt_opacity = $c->{srt_opacity} / 100;
      my $srt_font_size = int($c->{srt_size} / 100 * 15);
      $extra_html .= qq[
         <style>
            .plyr__captions {
               font-size: ${srt_font_size}px;
               opacity: $srt_opacity;
               color: $c->{srt_color};
               font-family: "$c->{srt_font}";
               text-shadow: 1px 1px 2px $c->{srt_shadow_color};
               background: $c->{srt_back_color};
               --plyr-captions-background: $c->{srt_back_color};
               --plyr-captions-text-color: $c->{srt_color};
            }
         </style>
      ];
      $extra_js .= qq[player.captions.active = true;] if $c->{srt_auto_enable};
      for (@{$file->{captions_list}}) {
         my $default_attr = $c->{srt_auto_enable} && !@tracks ? ' default' : '';
         push @tracks, {
            src => $_->{url},
            label => $_->{title},
            srclang => $_->{language},
            kind => 'captions',
            default => $default_attr ? 1 : 0
         };
         $c->{srt_auto_enable} = 0;
      }
      if ($c->{srt_allow_anon_upload}) {
         push @tracks, {
            src => "/srt/empty.srt",
            label => "Upload captions",
            srclang => "en",
            kind => "captions"
         };
         $extra_js .= qq[
            player.on('captionschanged', function(event) {
               var currentTrack = player.currentTrack;
               if (currentTrack !== -1 && player.media.textTracks[currentTrack].label === 'Upload captions') {
                  player.pause();
                  player.currentTrack = -1;
                  showCCform();
               }
            });
            function showCCform() {
               var \$dd = \$("<div />").css({
                  position: "absolute",
                  width: "100%",
                  height: "100%",
                  left: 0,
                  top: 0,
                  zIndex: 1000000,
                  background: "rgba(10%, 10%, 10%, 0.4)",
                  "text-align": "center"
               });
               \$("<iframe />").css({
                  width: "60%",
                  height: "60%",
                  zIndex: 1000001,
                  "margin-top": "50px"
               }).prop({
                  'src': '$c->{site_url}/?op=upload_srt&file_code=$file->{file_code}',
                  'frameborder': '0',
                  'scrolling': 'no'
               }).appendTo(\$dd);
               \$dd.click(function() { \$(this).remove(); player.play(); });
               \$dd.appendTo(\$('#vplayer'));
            }
         ];
      }
   }

   # P2P support (ported from JW8)
   if ($file->{p2p} && $file->{hls_direct}) {
      if ($c->{p2p_provider} eq 'streamroot') {
         $extra_html .= qq[<script src="//cdn.streamroot.io/plyr-hlsjs-provider/stable/plyr-hlsjs-provider.js"></script>];
         $extra_js .= qq[
            player.p2pConfig = {
               streamrootKey: '$c->{p2p_streamroot_key}',
               contentId: '$file->{file_code}',
               cacheSize: '250',
               mobileBrowserEnabled: false
            };
         ];
      }
      elsif ($c->{p2p_provider} eq 'peer5') {
         $extra_html_pre .= qq[
            <script src="//cdn.vdosupreme.com/vdo.js?id=$c->{p2p_peer5_key}"></script>
            <script src="//cdn.vdosupreme.com/vdo.plyr.plugin.js"></script>
            <script>
               peer5.configure({
                  contentIdReplacer: function(url) {
                     var aa = url.split(/\\//);
                     var hash = aa[4];
                     if (hash === '$file->{hash_n}') {
                        return url.replace(hash, '$file->{file_real}-n');
                     } else if ('$file->{hash_h}' && hash === '$file->{hash_h}') {
                        return url.replace(hash, '$file->{file_real}-h');
                     } else if ('$file->{hash_l}' && hash === '$file->{hash_l}') {
                        return url.replace(hash, '$file->{file_real}-l');
                     } else if ('$file->{hash_x}' && hash === '$file->{hash_x}') {
                        return url.replace(hash, '$file->{file_real}-x');
                     } else if ('$file->{hash_o}' && hash === '$file->{hash_o}') {
                        return url.replace(hash, '$file->{file_real}-o');
                     }
                     return url;
                  }
               });
            </script>
         ];
      }
      elsif ($c->{p2p_provider} eq 'self') {
         $extra_html_pre .= qq[
            <script src="/player/plyr/p2p-media-loader-core.min.js"></script>
            <script src="/player/plyr/p2p-media-loader-hlsjs.min.js"></script>
            <script src="/player/plyr/provider.hlsjs.js"></script>
         ];
         $js_code_pre .= qq[
            const p2pconfig = {
               segments: {
                  forwardSegmentCount: 60,
                  swarmId: "$file->{file_real}"
               },
               loader: {
                  trackerAnnounce: '$c->{p2p_self_tracker_url}',
                  cachedSegmentExpiration: 86400000,
                  cachedSegmentsCount: 500,
                  requiredSegmentsPriority: 2,
                  p2pDownloadMaxPriority: 50,
                  simultaneousP2PDownloads: 20,
                  simultaneousHttpDownloads: 2,
                  httpUseRanges: true,
                  httpDownloadMaxPriority: 9,
                  httpDownloadProbability: 0.06,
                  httpDownloadProbabilityInterval: 1000,
                  httpDownloadProbabilitySkipIfNoPeers: true
               }
            };
            var engine = new p2pml.hlsjs.Engine(p2pconfig);
            var loaded_http = 0, loaded_p2p = 0;
            engine.on("peer_connect", peer => console.log("p2p_peer_connect", peer.id, peer.remoteAddress));
            engine.on("peer_close", peerId => console.log("p2p_peer_close", peerId));
            engine.on("segment_loaded", function(segment, peerId) {
               console.log(segment.data.byteLength + " bytes", "p2p_segment_loaded from", peerId ? `peer \${peerId}` : "HTTP", segment.url);
               if (peerId) loaded_p2p += segment.data.byteLength; else loaded_http += segment.data.byteLength;
               console.log("Total HTTP:" + loaded_http + " P2P:" + loaded_p2p);
            });
         ];
         $extra_js .= qq[
            const iid = setInterval(() => {
               if (window.hls && window.hls.config) {
                  clearInterval(iid);
                  p2pml.hlsjs.initHlsJsPlayer(window.hls);
               }
            }, 200);
         ];
      }
   }

   # Player logo (ported from JW8)
 if ($c->{player_logo_url}) {
   my $logohide = $c->{player_logo_hide} ? 'opacity: 0;' : '';
   $extra_html .= qq[
      <style>
         .plyr__custom-watermark {
            background-image: url('$c->{player_logo_url}');
            background-size: contain;
            background-repeat: no-repeat;
            position: absolute;
            margin-top: 5px;
            margin-right: 5px;
            width: 145px;
            height: 26px;
            cursor: pointer;
            $logohide
            z-index: 10;
            top: 0;
            right: 0;
         }
         .plyr__custom-watermark:hover {
            opacity: 0.8;
         }
      </style>
      <div class="plyr__custom-watermark" aria-label="Watermark"></div>
   ];
   $extra_js .= qq[
      document.querySelector('.plyr__custom-watermark').addEventListener('click', function() {
         window.open('$c->{player_logo_link}', '_blank');
      });
   ];
}



   # Player color customization (ported from JW8)
   if ($c->{player_color}) {
      $extra_html .= qq[
         <style>
            .plyr--video .plyr__control.plyr__control--overlaid,
            .plyr--video .plyr__control:hover,
            .plyr--video .plyr__volume__bar,
            .plyr--video .plyr__menu__container {
               background: $c->{player_color} !important;
            }
            .plyr--full-ui input[type=range] {
               color:  $c->{player_color};
            }
            .plyr--video .plyr__control,
            .plyr--video .plyr__menu__container [data-plyr],
            .plyr--video .plyr__menu__container label {
               color: $c->{player_color} !important;
            }
            .plyr--video .plyr__progress__buffer::-webkit-progress-value,
            .plyr--video .plyr__volume__bar::-webkit-progress-value {
               background: $c->{player_color} !important;
            }
            .plyr--video .plyr__progress__buffer::-moz-progress-bar,
            .plyr--video .plyr__volume__bar::-moz-progress-bar {
               background: $c->{player_color} !important;
            }
            .plyr__menu__container [data-plyr="settings"] span:not(.plyr__menu__value) {
               color: #000000 !important;
            }
            .plyr__menu__container [data-plyr="speed"] span {
               color: #000000 !important;
            }
            .plyr__control svg {
               fill:  #FFFFFF !important;
            }
         </style>
      ];
   }

   # Forward and rewind buttons (ported from JW8)
   if ($c->{player_forward_rewind} && !$ses->isMobile) {
      $extra_html .= qq[
         <style>
            .plyr__control--custom {
               display: inline-flex;
               align-items: center;
               justify-content: center;
               padding: 5px;
               margin: 0 5px;
               cursor: pointer;
            }
            .plyr__control--custom svg {
               width: 20px;
               height: 20px;
               fill: #fff;
            }
         </style>
      ];
      $extra_js .= qq[
         const controlsContainer = document.querySelector('.plyr__controls');
         const rewindButton = document.createElement('button');
         rewindButton.className = 'plyr__control plyr__control--custom';
         rewindButton.setAttribute('data-plyr', 'rewind');
         rewindButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240"><path d="M113.2,131.078a21.589,21.589,0,0,0-17.7-10.6,21.589,21.589,0,0,0-17.7,10.6,44.769,44.769,0,0,0,0,46.3,21.589,21.589,0,0,0,17.7,10.6,21.589,21.589,0,0,0,17.7-10.6,44.769,44.769,0,0,0,0-46.3Zm-17.7,47.2c-7.8,0-14.4-11-14.4-24.1s6.6-24.1,14.4-24.1,14.4,11,14.4,24.1S103.4,178.278,95.5,178.278Zm-43.4,9.7v-51l-4.8,4.8-6.8-6.8,13-13a4.8,4.8,0,0,1,8.2,3.4v62.7l-9.6-.1Zm162-130.2v125.3a4.867,4.867,0,0,1-4.8,4.8H146.6v-19.3h48.2v-96.4H79.1v19.3c0,5.3-3.6,7.2-8,4.3l-41.8-27.9a6.013,6.013,0,0,1-2.7-8,5.887,5.887,0,0,1,2.7-2.7l41.8-27.9c4.4-2.9,8-1,8,4.3v19.3H209.2A4.974,4.974,0,0,1,214.1,57.778Z"></path></svg>';
         rewindButton.addEventListener('click', () => {
            let time = player.currentTime - 10;
            if (time < 0) time = 0;
            player.currentTime = time;
         });
         const forwardButton = document.createElement('button');
         forwardButton.className = 'plyr__control plyr__control--custom';
         forwardButton.setAttribute('data-plyr', 'fast-forward');
         forwardButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240"><path d="m 25.993957,57.778 v 125.3 c 0.03604,2.63589 2.164107,4.76396 4.8,4.8 h 62.7 v -19.3 h -48.2 v -96.4 H 160.99396 v 19.3 c 0,5.3 3.6,7.2 8,4.3 l 41.8,-27.9 c 2.93574,-1.480087 4.13843,-5.04363 2.7,-8 -0.57502,-1.174985 -1.52502,-2.124979 -2.7,-2.7 l -41.8,-27.9 c -4.4,-2.9 -8,-1 -8,4.3 v 19.3 H 30.893957 c -2.689569,0.03972 -4.860275,2.210431 -4.9,4.9 z m 163.422413,73.04577 c -3.72072,-6.30626 -10.38421,-10.29683 -17.7,-10.6 -7.31579,0.30317 -13.97928,4.29374 -17.7,10.6 -8.60009,14.23525 -8.60009,32.06475 0,46.3 3.72072,6.30626 10.38421,10.29683 17.7,10.6 7.31579,-0.30317 13.97928,-4.29374 17.7,-10.6 8.60009,-14.23525 8.60009,-32.06475 0,-46.3 z m -17.7,47.2 c -7.8,0 -14.4,-11 -14.4,-24.1 0,-13.1 6.6,-24.1 14.4,-24.1 7.8,0 14.4,11 14.4,24.1 0,13.1 -6.5,24.1 -14.4,24.1 z m -47.77056,9.72863 v -51 l -4.8,4.8 -6.8,-6.8 13,-12.99999 c 3.02543,-3.03598 8.21053,-0.88605 8.2,3.4 v 62.69999 z"></path></svg>';
         forwardButton.addEventListener('click', () => {
            player.currentTime = player.currentTime + 10;
         });
         const rewindIcon = document.querySelector('.plyr__control[data-plyr="rewind"]');
         if (rewindIcon) {
            rewindIcon.parentNode.insertBefore(rewindButton, rewindIcon.nextSibling);
            rewindIcon.parentNode.insertBefore(forwardButton, rewindButton.nextSibling);
            rewindIcon.style.display = 'none';
         }
      ];
   }

   # Multi-audio track support (ported from JW8)
   if ($c->{multi_audio_on}) {
      my $lhash;
      map { /^(\w+)=(\w+)$/; $lhash->{$1} = $2; } split(/,\s*/, $c->{multi_audio_user_list});
      my $alang = $lhash->{$file->{usr_default_audio_lang}} || $c->{player_default_audio_track};
      my $audio_sticky = $c->{player_default_audio_sticky} && !$alang ? qq[
         player.on("audioTrackChanged", function(event) {
            localStorage.setItem('default_audio', event.tracks[event.currentTrack].name);
         });
         if (localStorage.getItem('default_audio')) {
            setTimeout(() => audio_set(localStorage.getItem('default_audio')), 300);
         }
      ] : '';
      my $set_default_audio = $alang ? qq[if (!localStorage.getItem('default_audio')) setTimeout(() => audio_set('$alang'), 300);] : '';
      $extra_js .= qq[
         player.on('ready', function() {
            var audioTracks = window.hls ? window.hls.audioTracks : [];
            if (audioTracks.length > 1) {
               var settingId = document.querySelector(".plyr__menu__container").id.replace("plyr-settings-", "");
               var audioMenu = 'plyr-settings-' + settingId + '-audio';
               var audioButtons = '';
               var audioDefault = '';
               var audioChecked = 'false';
               var \$homeSetting = \$("#plyr-settings-" + settingId + "-home");
               \$.each(audioTracks, function(i, e) {
                  if (e.default && audioDefault === "") {
                     audioDefault = e.name;
                     audioChecked = 'true';
                  } else {
                     audioChecked = 'false';
                  }
                  audioButtons += '<button data-plyr="audio" type="button" role="menuitemradio" class="plyr__control" aria-checked="' + audioChecked + '" value="' + e.id + '"><span>' + e.name + '<span class="plyr__badge">' + (e.lang ? e.lang.toUpperCase() : e.groupId.replace("audio-", "").toUpperCase()) + '</span></span></span></button>';
               });
               \$homeSetting.find('div[role=menu]').prepend('<button data-plyr="audio-settings" type="button" class="plyr__control plyr__control--forward" role="menuitem" aria-haspopup="true"><span>Audio<span class="plyr__menu__value">' + audioDefault + '</span></span></button>');
               \$homeSetting.after('<div id="' + audioMenu + '" hidden><button type="button" class="plyr__control plyr__control--back"><span aria-hidden="true">Audio</span><span class="plyr__sr-only">Go back to previous menu</span></button><div role="menu">' + audioButtons + '</div></div>');
               \$('button[data-plyr="audio-settings"]').click(function() {
                  \$('#' + audioMenu).prop('hidden', false);
                  \$homeSetting.prop('hidden', true);
               });
               \$('#' + audioMenu + ' .plyr__control--back').click(function() {
                  \$('#' + audioMenu).prop('hidden', true);
                  \$homeSetting.prop('hidden', false);
               });
               \$('button[data-plyr="audio"]').click(function() {
                  window.hls.audioTrack = \$(this).val();
                  \$('button[data-plyr="audio"]').attr('aria-checked', "false");
                  \$(this).attr('aria-checked', "true");
                  \$('button[data-plyr="audio-settings"]').find('.plyr__menu__value').text(\$(this).text().replace(\$(this).find('.plyr__badge').text(), '').trim());
                  \$('#' + audioMenu).prop('hidden', true);
                  \$homeSetting.prop('hidden', false);
               });
            }
            $audio_sticky
            $set_default_audio
         });
         function audio_set(audio_name) {
            var audioTracks = window.hls ? window.hls.audioTracks : [];
            if (audioTracks.length > 1) {
               for (let i = 0; i < audioTracks.length; i++) {
                  if (audioTracks[i].name === audio_name) {
                     if (i === window.hls.audioTrack) return;
                     window.hls.audioTrack = i;
                     break;
                  }
               }
            }
         }
      ];
   }

   # Player sharing (ported from JW8)
   if ($c->{player_sharing}) {
      require URL::Encode;
      my $embed_code = URL::Encode::url_encode($file->{embed_code});
      $embed_code =~ s/\+/ /g;
      $file->{download_link} ||= $ses->makeFileLink($file);
      $extra_js .= qq[
         player.sharing = {
            code: "$embed_code",
            link: "$file->{download_link}",
            sites: []
         };
         document.querySelector('.plyr__menu').insertAdjacentHTML('beforeend', '<button data-plyr="sharing" type="button" class="plyr__control" aria-label="Share"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.92-2.92-2.92z"/></svg></button>');
         document.querySelector('[data-plyr="sharing"]').addEventListener('click', () => {
            navigator.share ? navigator.share({
               title: '$file->{file_title}',
               url: '$file->{download_link}'
            }) : alert('Copy embed code: ' + player.sharing.code);
         });
      ];
   }

   # Download button for embed (ported from JW8)
   if ($f->{embed} && $c->{player_embed_dl_button}) {
      $file->{download_link} ||= $ses->makeFileLink($file);
      $extra_js .= qq[
         document.querySelector('.plyr__controls').insertAdjacentHTML('beforeend', '<button data-plyr="download" type="button" class="plyr__control" aria-label="Download"><img src="/images/download2.png" style="width:20px;height:20px;"/></button>');
         document.querySelector('[data-plyr="download"]').addEventListener('click', () => {
            window.open('$file->{download_link}', '_blank').focus();
         });
      ];
   }

   # Remember player position (ported from JW8)
   if ($c->{remember_player_position}) {
      $ontime_func .= qq[
         if (player.currentTime >= lastt + 5 || player.currentTime < lastt) {
            lastt = player.currentTime;
            ls.set('tt$file->{file_code}', Math.round(lastt), { ttl: 60*60*24*7 });
         }
      ];
      $extra_js .= qq[
         var lastt = ls.get('tt$file->{file_code}');
         if (lastt > 0) { player.currentTime = lastt; }
      ];
      $extra_html .= qq[<script src="/js/localstorage-slim.js"></script>];
      $extra_js .= qq[
         player.on('ended', function() {
            ls.remove('tt$file->{file_code}');
         });
      ];
   }

   # Skip intro button (ported from JW8)
   if ($file->{file_skip_time} =~ /^\d+$/) {
      $extra_html .= qq[
         <style>
            #si11 {
               position: absolute;
               padding: 7px;
               border: 1px solid #fff;
               border-radius: 3px;
               bottom: 7em;
               right: 1em;
               opacity: 0.9;
               background: transparent;
               color: #fff;
               cursor: pointer;
            }
         </style>
      ];
      $extra_js .= qq[
         var si11 = 1;
         document.querySelector('.plyr__controls').insertAdjacentHTML('beforeend', '<button type="button" id="si11" class="si11" style="position:absolute;padding:7px;border:1px solid #fff;border-radius:3px;bottom:7em;right:1em;opacity:0.9;background:transparent;color:#fff;">SKIP INTRO</button>');
         document.querySelector('#si11').addEventListener('click', () => {
            player.currentTime = $file->{file_skip_time};
         });
         player.on('timeupdate', function() {
            if (si11 == 1 && player.currentTime >= $file->{file_skip_time}) {
               document.querySelector('#si11').style.display = 'none';
               si11 = 0;
            }
         });
      ];
   }

   # Views tracking mode 2 (ported from JW8)
   if ($c->{views_tracking_mode2}) {
      $ontime_func .= qq[
         if (player.isVisible) {
            let dt = player.currentTime - prevt;
            if (dt > 5) dt = 1;
            tott += dt;
         }
         prevt = player.currentTime;
         if (tott >= $vtime && !v2done) {
            v2done = 1;
            \$.post('/dl', {op: 'view2', hash: '$file->{ophash}', embed: '$f->{embed}', adb: adb, w: tott}, function(data){});
         }
      ];
   }

   # Player hidden link with tear (ported from JW8)
   if ($c->{player_hidden_link}) {
      $file->{ophash2} = $ses->HashSave($file->{file_id}, 0);
      $extra_html .= qq[<script src="$c->{cdn_url}/js/tear.js"></script>] if $c->{player_hidden_link_tear};
      my $tear = $c->{player_hidden_link_tear} ? qq[
         data[0]['seed'] = data[0]['seed'].replace(/[012567]/g, m => chars[m]);
         data[0]['file'] = decrypt(data[0]['file'], data[0]['seed']);
      ] : '';
      $extra_js .= qq[
         var vvbefore;
         if (vvbefore) return;
         vvbefore = 1;
         player.pause();
         \$.post('/dl', {op: 'playerddl', file_code: '$file->{file_code}', hash: '$file->{ophash2}'}, function(data) {
            var chars = {'0':'5', '1':'6', '2':'7', '5':'0', '6':'1', '7':'2'};
            $tear
            data[0]['file'] = data[0]['file'].replace(/[012567]/g, m => chars[m]);
            player.source = data[0]['file'];
         });
      ];
   }

   # Chromecast support (ported from JW8)
   if ($c->{player_chromecast}) {
      $extra_html .= qq[<script src="https://www.gstatic.com/cast/sdk/libs/receiver/2.0.0/cast_receiver.js"></script>];
      $extra_js .= qq[player.cast = {};];
   }

   # About text and link (ported from JW8)
   if ($c->{player_about_text} && $c->{player_about_link}) {
      $extra_js .= qq[
         document.querySelector('.plyr__menu').insertAdjacentHTML('beforeend', '<button data-plyr="about" type="button" class="plyr__control" aria-label="About"><span>About</span></button>');
         document.querySelector('[data-plyr="about"]').addEventListener('click', () => {
            window.open('$c->{player_about_link}', '_blank');
         });
      ];
   }

   # Related videos (ported from JW8)
   if ($c->{player_related}) {
      $extra_js .= qq[
         player.on('ended', function() {
            \$.get('/dl?op=related&code=$file->{file_code}', function(data) {
               var relatedDiv = document.createElement('div');
               relatedDiv.id = 'related-videos';
               relatedDiv.style.position = 'absolute';
               relatedDiv.style.top = '0';
               relatedDiv.style.left = '0';
               relatedDiv.style.width = '100%';
               relatedDiv.style.height = '100%';
               relatedDiv.style.background = 'rgba(0,0,0,0.8)';
               relatedDiv.innerHTML = data;
               document.querySelector('#vplayer').appendChild(relatedDiv);
            });
         });
      ];
   }

   # Autostart (ported from JW8)
   $extra_js .= qq[player.autoplay = 'viewable';] if $file->{autostart};

   # Debug and background image handling
   $extra_js .= qq[
      player.on('ready', function() {
         console.log('Plyr tracks:', player.config.tracks);
         console.log('Thumbnail URL:', '$file->{player_img}');
         console.log('HLS audio tracks:', window.hls ? window.hls.audioTracks : 'HLS not initialized');
      });
      player.on('error', function(e) {
         console.log('Plyr error:', e);
      });
      player.on('play', function() {
         document.querySelector('#vplayer').style.backgroundImage = 'none';
      });
   ];

   # Main JavaScript code
   my $js_code = qq[
      $js_code_pre
      var vvplay, x2ok = 0, lastt = 0, prevt = 0, tott = 0, v2done = 0;
      player.on('timeupdate', function() {
         if ($time_fadein > 0 && player.currentTime >= $time_fadein) {
            \$('div.video_ad_fadein').fadeIn('slow');
         }
         if (x2ok == 0 && player.currentTime >= $x2time && player.currentTime <= ($x2time + 2)) {
            x2ok = player.currentTime;
         }
         $ontime_func
      });
      player.on('play', function() { doPlay(); });
      player.on('ended', function() {
         \$('div.video_ad').show();
         $show_box_after_limit
         $show_box_after_preview
      });
      player.on('pause', function() { $extra_pause });
      function doPlay() {
         \$('div.video_ad').hide();
         \$('#over_player_msg').hide();
         if (vvplay) return;
         vvplay = 1;
         adb = 0;
         if (window.cRAds === undefined) { adb = 1; }
         \$.get('$c->{site_url}/dl?op=view&file_code=$file->{file_code}&hash=$file->{ophash}&embed=$f->{embed}&adb=' + adb, function(data) {
            \$('#fviews').html(data);
         });
         $stop_code
         $extra_js
      }
   ];

   # Sources and tracks
   my $sources_code = join(',', map {
      ref($_) eq 'HASH' ? "{ src: '$_->{src}', type: '$_->{type}'" . ($_->{label} ? ", label: '$_->{label}'" : '') . " }" : "{ src: '$_', type: 'video/mp4' }"
   } @sources);
   my $tracks_code = @tracks ? ', tracks: [' . join(',', map {
      "{ src: '$_->{src}', label: '$_->{label}', srclang: '$_->{srclang}', kind: '$_->{kind}'" .
      ($_->{default} ? ', default: true' : '') . '}'
   } @tracks) . ']' : '';

   # HTML output
   my $html = qq[
      $extra_html_pre
      <script type="text/javascript" src="$c->{cdn_url}/player/plyr/plyr.js"></script>
      <link rel="stylesheet" href="$c->{cdn_url}/player/plyr/plyr.css" />
      $extra_html
      <div id="vplayer" style="width:100%;height:100%;text-align:center;@{[$file->{player_img} ? "background-image: url('$file->{player_img}'); background-size: contain; background-position: center; background-repeat: no-repeat; background-color: #000;" : "background-color: #000;"]}">
         <video id="player" playsinline controls crossOrigin="anonymous" style="width:100%;height:100%;object-fit:$c->{player_image_stretching};">
            @{[join('', map {
               ref($_) eq 'HASH' ?
                  qq[<source src="$_->{src}" type="$_->{type}" />] :
                  qq[<source src="$_" type="video/mp4" />]
            } @sources)]}
            @{[join('', map {
               qq[<track src="$_->{src}" label="$_->{label}" srclang="$_->{srclang}" kind="$_->{kind}"@{[ $_->{default} ? ' default' : '' ]} />]
            } @tracks)]}
         </video>
      </div>
      <style>
         .plyr__poster { display: none; }
         .plyr { width: 100%; height: 100%; }
         .plyr__video-wrapper { background: transparent; }
         .plyr__menu__container [data-plyr="audio-settings"] .plyr__menu__value {
            margin-left: auto;
            font-size: 13px;
            color: #fff;
         }
         .plyr__menu__container [data-plyr="audio"] .plyr__badge {
            margin-left: 5px;
            font-size: 11px;
            background: rgba(255, 255, 255, 0.2);
            padding: 2px 5px;
            border-radius: 3px;
         }
      </style>
   ];

   $html .= qq[<script src="$c->{cdn_url}/js/dnsads.js"></script>] if $c->{adb_no_money};

   my $code = qq[
      var player = new Plyr('#player', {
         controls: ['play-large', 'play', 'progress', 'current-time', 'mute', 'volume', 'captions', 'settings', 'pip', 'airplay', 'cast', 'fullscreen', 'download', 'sharing', 'about'],
         settings: ['captions', 'quality', 'speed', 'audio']
         $tracks_code
      });
      $js_code
   ];

   return ($html, $code);
}

1;