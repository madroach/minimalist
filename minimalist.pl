#!/usr/bin/perl -Tw
#
# Minimalist - Minimalistic Mailing List Manager.
# Copyright (c) 1999-2005 Vladimir Litovka <vlitovka@gmail.com>
# Copyright (c) 2012 Christopher Zimmermann <madroach@gmerlin.de>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

use v5.10;
use strict;
use integer;
use Fcntl ':flock';	# LOCK_* constants
use Carp;
use Net::Config qw(%NetConfig);
use Net::SMTP;
require File::Spec;
require Digest::MD5;
require MIME::QuotedPrint;
require MIME::Base64;
require Sys::Hostname;
require POSIX;

    $ENV{SMTPHOST} = '127.0.0.1';
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
$ENV{'PATH'} = '/bin:/usr/bin';

my $version = '3.1';
my $config = "/etc/minimalist.conf";

#####################################################
# Prototypes
#
sub send_message ($$$;$);
sub verify ($$);
sub logCommand ($$);
sub subscribe ($$;$);
sub unsubscribe ($$;$);
sub chgSettings ($$$$;@);
sub genAdminReport ($$$);
sub archive ($$$);
sub arch_pipe ($$);
sub read_config ($$);
sub load_config ($);
sub load_language ();
sub read_info ($$);
sub genAuth ($$$$;@);
sub getAuth ($);

# Lists' status bits
my $OPEN = 0;
my $RO = 1;
my $CLOSED = 2;
my $MANDATORY = 4;

#####################################################
# Various regular expressions
#
# for matching rounding spaces

my $spaces = '^\s*(.*?)\s*$';

# for parsing two forms of mailing addresses:
#
# 1st form: Vladimir Litovka <doka@kiev.sovam.com>
# 2nd form: doka@kiev.sovam.com (Vladimir Litovka)

my $addr = qr/[[:graph:]]+@[[:graph:]]+/;

my $first = qr/((.*?)\s*<($addr)>)(.*)/;	# $2 - gecos, $3 - address, $4 - rest
my $second = qr/(($addr)\s*\((.*?)\))(.*)/;	# $2 - address, $3 - gecos, $4 - rest

#####################################################
# Default values
#

my $domain = Sys::Hostname::hostname();
my %global_conf = (
  domain => $domain,
  admin => "postmaster\@$domain",
  adminpwd => undef,
  listpwd => undef,
  archive => 'no',
  archpgm => 'BUILTIN',
  arcsize => 0,
  auth_scheme => 'password',
  auth_valid => 24,
  background => 'no',
  blocked_robots => 'CurrentlyWeAreBlockingNoRobot-Do__NOT__leaveThisBlank',	# -VTV-
  cc_on_subscribe => 'no',	# -VTV-
  charset => 'us-ascii',
  copy_sender => 'yes',
  delay => 0,
  directory => '/var/db/minimalist',
  errors_to => 'drop',
  translationpath => 'translations',
  language => 'en',
  list_gecos => '',
  listdir => 'lists',
  listinfo => 'yes',
  logfile => undef,
  logmessages => 'no',
  maxrcpts => 20,
  maxsize => 0,		# Maximum allowed size for message (incl. headers)
  maxusers => 0,
  me => "minimalist\@$domain",
  mesender => "minimalist\@$domain",	# For substitute in X-Sender header
  modify_msgid => 'no',
  modify_subject => 'yes',
  outgoing_from => '',
  remove_resent => 'no',
  reply_to_list => 'no',
  security => 'careful',
  sendmail => undef,
  status => $OPEN,
  strip_rrq => 'no',
  to_recipient => 'no',
  xtrahdr => ''
);
undef $domain;

#####################################################
# Other global variables
#
my $smtp;
END { $smtp->quit() if(defined $smtp) }
my $password = 0;
my $maketext;
my %msgtxt;
# HASH of known lists - key is lowercase listname, value list directory.
my %lists;
my @blacklist;
my @trusted;


########################################################
# >>>>>>>>>>>>>>>>>>> CONFIGURING <<<<<<<<<<<<<<<<<<<< #
########################################################

srand; # Seed random number generator while /dev/urandom is accessible

my %conf = read_config($config, 'global');
@global_conf{keys %conf} = values %conf;
%conf = %global_conf;

if (defined $conf{logfile}) {
  open LOG, '>>', "$conf{logfile}" or warn "Can't open $conf{logfile}: $!" }
else {
  open LOG, '>', File::Spec->devnull or warn "Can't open null device: $!" }

unless(-t STDERR) {
  open STDOUT, ">&LOG" or warn "Can't redirect STDOUT: $!";
  open STDERR, ">&LOG" or warn "Can't redirect STDERR: $!";
  select LOG;
}

load_language();

push @{$NetConfig{smtp_hosts}}, 'localhost' unless($#{$NetConfig{smtp_hosts}} >= 0);
unless (defined $smtp || defined $conf{sendmail}) {
  $smtp = Net::SMTP->new()
    or warn "SMTP connect failed. SMTP connection specified in local chrooted config?";
  $conf{sendmail} = undef;
}


#########################################################
# >>>>>>>>>>>>>>>>>>>>>>> MAKETEXT <<<<<<<<<<<<<<<<<<<< #
#########################################################

chdir $conf{directory} or die "Cannot chdir to $conf{directory}.";

# Convenience wrapper
sub mt (@) { $maketext->maketext(@_) }

$maketext = Translation::en->new() || die "Language?";


################################################################
# >>>>>>>>>>>>>>> CHROOT AND DROP PRIVILEGES <<<<<<<<<<<<<<<<< #
################################################################

-d $conf{directory} or die "$conf{directory} is not a directory.";

# $< and $( are real [ug]id, $> and $) are effective [ug]id
if ($> == 0 && $< != 0) {
  my $uid;
  my $gid = getgrnam('nogroup');
  defined $gid or die "Could not get gid of nogroup.";
  if (defined $conf{user}) {
    $uid = getpwnam($conf{user});
    defined $uid or die "Could not get uid of $conf{user}.";
  }
  else { $uid = $< }

  # drop group privileges
  $) = "$gid $gid";
  die "Error while dropping group privileges: $!" unless($) eq "$gid $gid");
  POSIX::setgid($gid) or die "setgid failed: $!";;

  # chroot
  chroot $conf{directory} or die "Could not chroot to $conf{directory}: $!";
  chdir '/' or die "Cannot chdir to / in chroot ($conf{directory}).";
  $conf{directory} = '/';

  # drop user privileges
  POSIX::setuid($uid) or die "setuid failed: $!";

  # This may be too paranoid, but check
  # that privileges are really dropped permanently
  POSIX::setuid(0);
  POSIX::setgid(0);
  my $groups = qr/^$gid( $gid)?$/;
  if ($< == 0 || $> == 0 || $( !~ $groups || $) !~ $groups) {
    die "Could not drop privileges permanently." }
}
@INC = ('.');

####################################################################
# >>>>>>>>>>>>>>>>>>>>>> PREPARE HASH OF LISTS <<<<<<<<<<<<<<<<<<< #
####################################################################

opendir(LISTDIR, $conf{listdir}) || die "Cannot open $conf{listdir}!";
while (readdir LISTDIR) {
  warn "$_ list is found twice - maybe in differing case?" if (exists $lists{lc $_});
  $lists{lc $1} = $1 if(/^([^\.].*)$/ && -d "$conf{listdir}/$_");
}
closedir LISTDIR;


####################################################################
# >>>>>>>>>>>>>>>>>>>>>>>> CHECK CONFIGURATION <<<<<<<<<<<<<<<<<<< #
####################################################################

if (defined $ARGV[0] && $ARGV[0] eq '-') {
  my $msg;
  my %lconf = %conf;
  print "\nMinimalist v$version, pleased to meet you.\n".
        "Using \"$config\" as main configuration file\n\n";
  print	"================= Global configuration ================\n".
	"Directory: $lconf{directory}\n".
	"User: $lconf{user}\n".
	"Administrative password: ".(defined $lconf{adminpwd} ? "ok\n" : "not defined\n").
	"Logging: $lconf{logfile}\n".
	"Language: $lconf{language}\n".
	"Log info about messages: $lconf{logmessages}\n".
	"Background execution: $lconf{background}\n".
	"Authentication request valid at least $lconf{auth_valid} hours\n".
        "Blocked robots:";
  if ($lconf{blocked_robots} !~ /__NOT__/) {
    foreach (split(/\|/, $lconf{blocked_robots})) {
      print "\n\t$_"; }
   }
  else { print " no one"; }

  if ( @blacklist ) {
    print "\nGlobal access list is:\n";
    foreach (@blacklist) {
      if ( $_ =~ s/^!(.*)//g ) { print "\t - ".$1." allowed\n" }
      else { print "\t - ".$_." disallowed\n" }
     };
   };


  print "\n\n";
  while ( $ARGV[0] ) {
    @trusted = ();

    if ($ARGV[0] ne '-') {
      $ARGV[0] =~ /^([[:graph:]]+)$/;
      my $list = $1;
      if (exists $lists{lc $list}) {
	$list = $lists{lc $list};
      }
      else {
	print " * There isn't such list \U$list\E\n\n";
	shift; next;
      }

      my %nconf = read_config("$conf{listdir}/$list/config", 'list');
      %lconf = %conf;
      @lconf{keys %nconf} = values %nconf;
      undef %nconf;

      print "================= \U$list\E ================\n";
      print "Administrators: ";
      if ( @trusted ) {
	print "\n";
	foreach (@trusted) { print "\t . ".$_."\n"; }
      }
      else { print "not defined\n"; }
      print "Administrative password: ".(! $conf{listpwd} ? "empty" :
	$conf{listpwd} =~ /^_.*_$/ ? "not defined" : "Ok")."\n";
    }

    print
	"Domain: $lconf{domain}\n".
	"Security: $lconf{security}\n".
	"Archiving: $lconf{archive}\n".
	($lconf{archive} ne 'no' ? " * Archiver: $lconf{archpgm}\n" . ($lconf{arcsize} != 0 ? " * Maximum message size: $lconf{arcsize} bytes\n" : "") : "")
	.
	"Status:";
    if ($lconf{status}) {
      print " read-only" if ($lconf{status} & $RO);
      print " closed" if ($lconf{status} & $CLOSED);
      print " mandatory" if ($lconf{status} & $MANDATORY);
     }
    else { print " open"; }
    print "\nCopy to sender: $lconf{copy_sender}\n".
	"Reply-To list: $lconf{reply_to_list}\n".
	"List GECOS: ".($lconf{list_gecos} ? $lconf{list_gecos} : "empty")."\n".
	"Substitute From: ".($lconf{outgoing_from} ? $lconf{outgoing_from} : "none")."\n".
	"Admin: $lconf{admin}\n".
	"Errors from MTA: ".($lconf{errors_to} eq 'drop' ? "drop" :
	          ($lconf{errors_to} eq 'verp' ? "generate VERP" : "return to $lconf{errors_to}"))."\n".
		"Modify subject: $lconf{modify_subject}\n".
		"Modify Message-ID: $lconf{modify_msgid}\n".
		"Notify on subscribe/unsubscribe event: $lconf{cc_on_subscribe}\n".
		"Maximal users per list: ".($lconf{maxusers} ? $lconf{maxusers} : "unlimited")."\n".
		"Maximal recipients per message: ".($lconf{maxrcpts} ? $lconf{maxrcpts} : "unlimited")."\n".
		"Delay between deliveries: ".($lconf{delay} ? $lconf{delay} : "none")."\n".
		"Maximal size of message: ".($lconf{maxsize} ? "$lconf{maxsize} bytes" : "unlimited")."\n".
		"Strip 'Return Receipt' requests: $lconf{strip_rrq}\n".
		"List information: ".($lconf{listinfo} eq 'no' ? "no" : "yes".
				($lconf{listinfo} ne 'yes' ? ", archive at: $lconf{listinfo}" : ""))."\n".
	"Charset: $lconf{charset}\n".
	"Language: $lconf{language}\n".
	"Fill To: with recipient's address: $lconf{to_recipient}\n".
	"Extra Header(s):".($lconf{xtrahdr} ? "\n\n$lconf{xtrahdr}" : " none")."\n\n";
    
    # Various checks
    $msg .= " * $lconf{directory} doesn't exist!\n" if (! -d $lconf{directory});
    $msg .= " * Invalid 'log messages' value '$lconf{logmessages}'\n" if ($lconf{logmessages} !~ /^yes$|^no$/i);
    $msg .= " * Invalid 'background' value '$lconf{background}'\n" if ($lconf{background} !~ /^yes$|^no$/i);
    $msg .= " * Invalid security level '$lconf{security}'\n" if ($lconf{security} !~ /^none$|^careful$|^paranoid$/i);
    $msg .= " * Invalid 'copy to sender' value '$lconf{copy_sender}'\n" if ($lconf{copy_sender} !~ /^yes$|^no$/i);
    $msg .= " * Invalid 'modify subject' value '$lconf{modify_subject}'\n" if ($lconf{modify_subject} !~ /^yes$|^no$|^more$/i);
    $msg .= " * Invalid 'modify message-id' value '$lconf{modify_msgid}'\n" if ($lconf{modify_msgid} !~ /^yes$|^no$/i);
    $msg .= " * Invalid 'cc on subscribe' value '$lconf{cc_on_subscribe}'\n" if ($lconf{cc_on_subscribe} !~ /^yes$|^no$/i);
    $msg .= " * Invalid 'reply-to list' value '$lconf{reply_to_list}'\n" if ($lconf{reply_to_list} !~ /^yes$|^no$|\@/i);
    $msg .= " * Invalid 'from' value '$lconf{outgoing_from}'\n" if ($lconf{outgoing_from} !~ /\@|^$/i);
    $msg .= " * Invalid authentication request validity time: $lconf{auth_valid}\n" if ($lconf{auth_valid} !~ /^[0-9]+$/);
    $msg .= " * Invalid archiving strategy '$lconf{archive}'\n" if ($lconf{archive} !~ /^no$|^daily$|^monthly$|^yearly$|^pipe$/i);
    $msg .= " * Invalid 'strip rrq' value '$lconf{strip_rrq}'\n" if ($lconf{strip_rrq} !~ /^yes$|^no$/i);
    $msg .= " * Invalid 'remove resent' value '$lconf{remove_resent}'\n" if ($lconf{remove_resent} !~ /^yes$|^no$/i);
    my $translation = "$lconf{translationpath}/$lconf{language}";
    $msg .= " * Invalid 'to recipient' value '$lconf{to_recipient}'\n" if ($lconf{to_recipient} !~ /^yes$|^no$/i);
    $msg .= " * Translation file $translation not available'\n" unless (-f $translation || $lconf{language} eq "en");
    if ($lconf{archive} eq 'pipe') {
      (my $arpg, ) = split(/\s+/, $lconf{archpgm}, 2);
      $msg .= " * $arpg doesn't exists!\n" unless (-x $arpg);
     }

    goto CfgCheckEnd if ($msg);
    shift;
   }

  CfgCheckEnd:

  print "\t=== FAILURE ===\n\nErrors are:\n".$msg."\n" if ($msg);
  exit;
}


####################################################################
# >>>>>>>>>>>>>>>>>>>>>>>>> START HERE <<<<<<<<<<<<<<<<<<<<<<<<<<< #
####################################################################

{
  # Clean old authentication requests
  cleanAuth();

  my ($message, $header, $body);

  while (<STDIN>) {
    s/\r//g;		# Remove Windooze's \r, it is safe to do this
    $message .= $_;
  }
  ($header, $body) = split(/\n\n/, $message, 2); $header .= "\n";

  undef $message;		# Clear memory, it isn't used anymore

  my $list = my $from;
  my $sender = my $xsender = my $orig_subj = my $subject = '';

# Check SysV-style "From ". Stupid workaround for messages from robots, but
# with human-like From: header. In most cases "From " is the only way to
# find out envelope sender of message.
  if ($header =~ /^From (.*)\n/i) {
    exit 0 if ($1 =~ /(MAILER-DAEMON|postmaster)@/i); }

# Extract $list from command line or Delivered-To:
  if ($ARGV[0]) { $list = $ARGV[0] }
  elsif ($header =~ /(^|\n)delivered-to: (.*)\n/i) {
    $list = $2; $list =~ s/@.*//; }
  else {
    die "no list specified on commond line and ".
	"could not find \"delivered-to:\" header." }
  undef $list if($list eq "minimalist");

# Extract From:
  if ($header =~ /(^|\n)from:\s+(.*\n([ \t]+.*\n)*)/i) {
    $from = $2; $from =~ s/$spaces/$1/ogs;
    $from =~ s/\n//g; $from =~ s/\s{2,}/ /g; }
  else {
    die "Could not find \"from:\" header." }

# Sender and X-Sender are interesting only when generated by robots
# (Minimalist, MTA, etc), which (I think :) don't produce multiline headers.

  if ($header =~ /(^|\n)sender: (.*)\n/i) { $sender = $2; }
  if ($header =~ /(^|\n)x-sender: (.*)\n/i) { $xsender = $2; }

# If there is Reply-To, use this address for replying
  my $mailto;
  if ($header =~ /(^|\n)reply-to:\s+(.*\n([ \t]+.*\n)*)/i) {
    $mailto = $2; $mailto =~ s/$spaces/$1/gs }
  else {
    $mailto = $from }

# Preparing From:
  if ($from =~ s/$first/$3/og) { ;}
  elsif ($from =~ s/$second/$2/og) { ;}
  $from =~ s/\s+//gs; $from = lc($from);

  exit 0 if (($xsender eq $conf{mesender}) || ($from eq $conf{mesender}));	# LOOP detected
  exit 0 if (($from =~ /(MAILER-DAEMON|postmaster)@/i) ||		# -VTV-
    ($sender =~ /(MAILER-DAEMON|postmaster)@/i) ||
    ($xsender =~ /(MAILER-DAEMON|postmaster)@/i));	# ignore messages from MAILER-DAEMON

  exit 0 if ( $header =~ /^($conf{blocked_robots}):/);			# disable loops from robots -VTV-

  foreach (@blacklist) {				# Parse access control list
    if ( $_ =~ s/^!(.*)//g ) {
      last if ( $from =~ /$1$/i || $sender =~ /$1$/i || $xsender =~ /$1$/i) }
    else {
      exit if ( $from =~ /$_$/i || $sender =~ /$_$/i || $xsender =~ /$_$/i) }
  };

  my $qfrom = quotemeta($from);	# For use among with 'grep' function

# Look for user's supplied password
# in header (in form: '{pwd: blah-blah}' )
  while ($header =~ s/\{pwd:[ \t]*(\w+)\}//i) {
    $password = $1; }
# in body, as very first '*password: blah-blah'
  if (!$password && $body =~ s/^\*password:[ \t]+(\w+)\n+//i) {
    $password = $1; }

# Get (multiline) subject
  if ($header =~ /(^|\n)subject:[ \t]+(.*\n([ \t]+.*\n)*)/i) {
    $subject = $2;
    $subject .= substr($^X,0,0); # taint $subject
    $orig_subj = $subject =~ s/$spaces/$1/gs; }

  $body =~ s/\n*$/\n/g;
  $body =~ s/\n\.\n/\n \.\n/g;	# Single '.' treated as end of message

#########################################################################
########################## Message to list ##############################
#########################################################################

  if ($list) {
    my $msg;
    my @hdrcpt;
    my @members;
    my @rcpts;
    my @readonly;
    my @recip;
    my @recipients;
    my @rw;
    my @writeany;

    # normalize to exact directory name.
    if (exists $lists{lc $list}) {
      $list = $lists{lc $list};
    }
    else {
      $msg = <<_EOF_ ;
ERROR:
    Minimalist was called with the '$list' argument, but there is no such list.

SOLUTION:
    Check your 'aliases' file - there is a possible typo.

_EOF_
      send_message('Subject: Possible error in system settings', $msg, $conf{admin});
      exit;
    }

    ##################################
    # Go to background, through fork #
    ##################################

    if ($conf{background} eq 'yes') {

      $msg = <<_EOF_ ;
ERROR:
    Minimalist can not fork due to the following reason:
_EOF_
      my $forks = 0;

      FORK: {

	if (++$forks > 4) {
	  $msg .= "\n    Can't fork for more than 5 times\n\n";
	  send_message('Subject: Can not fork', $msg, $conf{admin});
	  exit;
	}
	my $pid;
	if ($pid = fork) {
	  # OK, parent here, exiting
	  exit 0;
	}
	elsif (defined $pid) {
	  # OK, child here. Detach and do
	  close STDIN;
	  close STDOUT;
	  close STDERR;
	}
	elsif ($! =~ /No more process/i) {
	  # EAGAIN, supposedly recoverable fork error, but no more than 5 times
	  sleep 5;
	  redo FORK;
	}
	else {
	  # weird fork error, exiting
	  $msg .= "\n    $!\n\n";
	  send_message('Subject: Can not fork', $msg, $conf{admin});
	  exit;
	}
      } # Label FORK
    }  # if ($conf{background})

    load_config($list);

    # Remove or exit per List-ID
    exit 0 if ($header =~ s/(^|\n)list-id:\s+(.*)\n/$1/i && $2 =~ /$list.$conf{domain}/i);

    if ($conf{modify_subject} ne 'no') {
      $orig_subj = $subject;
      if ($conf{modify_subject} eq 'more') {	# Remove leading "Re: "
	$subject =~ s/^.*:\s+(\[$list\])/$1/ig }
      else {				# change anything before [...] to Re:
	$subject =~ s/^(.*:\s+)+(\[$list\])/Re: $2/ig; }

      # Modify subject if it don't modified before
      if ($subject !~ /^(.*:\s+)?\[$list\] /i) {
	$subject = "[$list] ".$subject; }
    }

    open LIST, "$conf{listdir}/$list/list" and do {
      while (my $ent = <LIST>) {
	if ( $ent =~ /^(?!#)([[:graph:]]+@[[:graph:]]+)$/ ) {
	  $ent = lc($1);

	  # Get and remove per-user settings from e-mail
	  $ent =~ s/(>.*)$//; my $userSet = $1;

	  # Check for '+' (write access) or '-' (read only access)
	  if (defined $userSet && $userSet =~ /-/) { push (@readonly, $ent); }
	  elsif (defined $userSet && $userSet =~ /\+/) { push (@writeany, $ent); }

	  # If user's maxsize
	  my $usrMaxSize;
	  if (defined $userSet && $userSet !~ /#ms([0-9]+)/) { undef $usrMaxSize }
	  else { $usrMaxSize = $1 }

	  # If suspended (!) or maxsize exceeded, do not put in @members
	  if (defined $userSet && $userSet =~ /!/ || ($usrMaxSize && length($body) > $usrMaxSize)) {
	    push (@rw, $ent); }
	  else {
	    push (@members, $ent); }
	}
      }
      close LIST;
    };

    # If sender isn't admin, prepare list of allowed writers
    if (($conf{security} ne 'none') && ! verify($from, $password)) {
      push (@rw, @members);
      open LIST, "$conf{listdir}/$list/list-writers" and do {
	while (my $ent = <LIST>) {
	  if ( $ent && $ent !~ /^#/ ) {
	    chomp($ent); $ent = lc($ent);

	    # Get and remove per-user settings from e-mail
	    $ent =~ s/(>.*)$//; my $userSet = $1;

	    # Check for '+' (write access) or '-' (read only access)
	    if (defined $userSet && $userSet =~ /-/) { push (@readonly, $ent); }
	    elsif (defined $userSet && $userSet =~ /\+/) { push (@writeany, $ent); }

	    push (@rw, $ent); }
	}
	close LIST;
      }
    }

    # If sender isn't admin and not in list of allowed writers
    if (($conf{security} ne 'none') && ! verify($from, $password) && !grep(/^$qfrom$/i, @rw)) {
      my $body =
	mt('ERROR:'). "\n\t".
	mt('You([_1]) are not subscribed to this list([_2]).', $from, $list).
	"\n\n".
	mt('SOLUTION:'). "\n\t".
	mt("Send a message to [_1] with a subject of 'help' (no quotes) for information about howto subscribe.",
	  "$conf{me}").
	"\n\n".
	mt('Your message follows:').
	'==========================================================================='.
	$body.
	'===========================================================================';

      send_message("Subject: $subject", $body, $mailto)
    } 

  # If list or sender in read-only mode and sender isn't admin and not
  # in allowed writers
  elsif (($conf{status} & $RO || grep(/^$qfrom$/i, @readonly)) && !verify($from, $password) && !grep(/^$qfrom$/i, @writeany)) {
    my $body =
      mt('ERROR:'). "\n\t".
      mt('You([_1]) are not allowed to write to this list.', $from). "\n\n".
      mt('Your message follows:').
      '==========================================================================='.
      $body.
      '===========================================================================';

    send_message("Subject: $subject", $body, $mailto)
  }
  elsif ($conf{maxsize} && (length($header) + length($body) > $conf{maxsize})) {
    my $body =
      mt('ERROR:'). "\n\t".
      mt('Message size is larger than maximum allowed ([_1] bytes).',
	$conf{maxsize}).
      "\n\n".
      mt('SOLUTION:'). "\n\t".
      mt('Either send a smaller message or split your message into multiple smaller ones.').
      "\n\n".
      mt('Your message header follows:').
      '==========================================================================='.
      $header.
      '===========================================================================';

    send_message("Subject: $subject", $body, $mailto)
  }
  else {		# Ok, all checks done.
    logCommand($from, "L=\"$list\" T=\"$orig_subj\" S=".(length($header) + length($body))) if ($conf{logmessages} ne 'no');

    $conf{archive} = 'no' if ($conf{arcsize} && length ($body) > $conf{arcsize});
    if ($conf{archive} eq 'pipe') { arch_pipe($header, $body); }
    elsif ($conf{archive} ne 'no') { archive($list, $header, $body); }

    # Extract and remove all recipients of message. This information will be
    # used later, when sending message to members except those who already
    # received this message directly.

    my $rc;
    if ($header =~ s/(^|\n)to:\s+(.*\n([ \t]+.*\n)*)/$1/i) { $rc = $2 }
    if ($header =~ s/(^|\n)cc:\s+(.*\n([ \t]+.*\n)*)/$1/i) { $rc .= ",".$2 }

    if ($rc) {
      foreach $rc (split /,/, $rc) {
	if ($rc =~ s/$first/$4/) { push (@recip, $1) }
	elsif ($rc =~ s/$second/$4/) { push (@recip, $1) }
	else { $rc =~ s/$spaces/$1/; push (@recip, $rc); }
      }
    }

    my $to_gecos;
    # Search for user's supplied GECOS
    foreach my $trcpt (@recip) {
      $trcpt =~ s/$spaces/$1/gs;
      next if (! $trcpt);  # In case "To: e@mail, \n" - don't push spaces, which are between ',' and '\n'

      push(@hdrcpt, $trcpt);

      my $tmp_to_gecos = undef;
      if ( $trcpt =~ s/$first/$3/g ) { ($tmp_to_gecos = $2) =~ s/$spaces/$1/gs; }
      elsif ( $trcpt =~ s/$second/$2/g ) { ($tmp_to_gecos = $3) =~ s/$spaces/$1/gs; }
      push(@rcpts, $trcpt = lc($trcpt));

      $to_gecos = $tmp_to_gecos if ($tmp_to_gecos && $trcpt =~ /$list\@$conf{domain}/i);
    }

    # If there was To: and Cc: headers, put them back in message's header
    if (@hdrcpt && $conf{to_recipient} eq 'no') {
      # If there is administrator's supplied GECOS, use it instead of user's supplied
      if ($conf{list_gecos}) {
	for (my $i=0; $i<@hdrcpt; $i++) {
	  if ($hdrcpt[$i] =~ /$list\@$conf{domain}/i) {	# Yes, list's address
	    $hdrcpt[$i] =~ s/$second/$2/g if (! ($hdrcpt[$i] =~ s/$first/$3/g));
	    $hdrcpt[$i] = "$conf{list_gecos} <$hdrcpt[$i]>";
	  }
	}
	$to_gecos = $conf{list_gecos};
      }

      chomp $header;
      $header .= "\nTo: $hdrcpt[0]\n";
      if (@hdrcpt > 1) {
	$header .= "Cc: $hdrcpt[1]";
	for (my $i=2; $i<@hdrcpt; $i++) {
	  $header .= ",\n\t$hdrcpt[$i]";
	}
	$header .= "\n";
      }
    }

    # Remove conflicting headers
    $header =~ s/(^|\n)x-list-server:\s+.*\n([ \t]+.*\n)*/$1/ig;
    $header =~ s/(^|\n)precedence:\s+.*\n/$1/ig;

    if ($conf{remove_resent} eq 'yes') {
      $header =~ s/(^|\n)(resent-.*\n([ \t]+.*\n)*)*/$1/ig;
    }

    if ($conf{strip_rrq} eq 'yes') {		# Return Receipt requests
      $header =~ s/return-receipt-to:\s+.*\n//ig;
      $header =~ s/disposition-notification-to:\s+.*\n//ig;
      $header =~ s/x-confirm-reading-to:\s+.*\n//ig;
    }

    if ($conf{modify_msgid} eq 'yes') {	# Change Message-ID in outgoing message
      $header =~ s/message-id:\s+(.*)\n//i;
      my $old_msgid = $1; $old_msgid =~ s/$first/$3/g;
      my $msgid = "MMLID_".int(rand(100000));
      $header .= "Message-ID: <$msgid-$old_msgid>\n";
    }

    chomp ($header);
    $header .= "\nPrecedence: list\n";		# For vacation and similar programs

    # Remove original From_ line unconditionally
    $header =~ s/^From .*\n//;

    # Remove original Reply-To unconditionally, set configured one if it is
    $header =~ s/(^|\n)reply-to:\s+.*\n([ \t]+.*\n)*/$1/ig;
    if ($conf{reply_to_list} eq 'yes') { $header .= "Reply-To: $to_gecos <$list\@$conf{domain}>\n"; }
    elsif ($conf{reply_to_list} ne 'no') { $header .= "Reply-To: $conf{reply_to_list}\n"; }

    if ($conf{modify_subject} ne 'no') {
      $header =~ s/(^|\n)subject:\s+.*\n([ \t]+.*\n)*/$1/ig;
      $header .= "Subject: $subject\n";
    }
    if ($conf{outgoing_from} ne '') {
      $header =~ s/(^|\n)from:\s+.*\n([ \t]+.*\n)*/$1/ig;
      $header .= "From: $conf{outgoing_from}\n";
    }
    if ($conf{listinfo} ne 'no') {
      # --- Preserve List-Archive if it's there
      my $listarchive;
      if ($header =~ s/(^|\n)List-Archive:\s+(.*\n([ \t]+.*\n)*)/$1/i) { $listarchive = $2; }
      # --- Remove List-* headers
      $header =~ s/(^|\n)(List-.*\n([ \t]+.*\n)*)*/$1/ig;

      $header .= "List-Help: <mailto:$conf{me}?subject=help>\n";
      $header .= "List-Subscribe: <mailto:$conf{me}?subject=subscribe%20$list>\n";
      $header .= "List-Unsubscribe: <mailto:$conf{me}?subject=unsubscribe%20$list>\n";
      $header .= "List-Post: <mailto:$list\@$conf{domain}>\n";
      $header .= "List-Owner: <mailto:$list-owner\@$conf{domain}>\n";

      if ($conf{listinfo} ne 'yes') {
	$header .= "List-Archive: $conf{listinfo}\n"; }
      elsif ($listarchive) {
	$header .= "List-Archive: $listarchive\n"; }
    }
    $header .= "List-ID: <$list.$conf{domain}>\n";
    $header .= "X-List-Server: Minimalist v$version <http://www.mml.org.ua/>\n";
    $header .= "X-BeenThere: $list\@$conf{domain}\n";	# This header deprecated due to RFC2919 (List-ID)
    if ($conf{xtrahdr}) {
      $conf{xtrahdr} =~ s/\\a/$conf{admin}/ig;
      $conf{xtrahdr} =~ s/\\d/$conf{domain}/ig;
      $conf{xtrahdr} =~ s/\\l/$list/ig;
      $conf{xtrahdr} =~ s/\\o/$list-owner\@$conf{domain}/ig;
      $conf{xtrahdr} =~ s/\\n/\n/ig;
      $conf{xtrahdr} =~ s/\\t/\t/ig;
      $conf{xtrahdr} =~ s/\\s/ /ig;
      chomp $conf{xtrahdr};
      $header .= "$conf{xtrahdr}\n";
    }

    # Convert plain/text messages to multipart/mixed or
    # append footer to existing MIME structure
    #
    if (my $footer = read_info($list, 'footer')) {
      my $encoding = '7bit';

      $header =~ /(^|\n)Content-Type:\s+(.*\n(\s+.*\n)*)/i;
      my $ctyped = $2;
      # Check if there is Content-Type and it isn't multipart/*
      if (!$ctyped || $ctyped !~ /^multipart\/(mixed|related)/i) {
	$ctyped =~ /charset="?(.*?)"?[;\s]/i;
	my $msgcharset = lc($1);
	$encoding = lc($2)
	if ($header =~ /(^|\n)Content-Transfer-Encoding:[ \t]+(.*\n([ \t]+.*\n)*)/i);

	# If message is 7/8bit text/plain with same charset without preset headers in
	# footer, then simply add footer to the end of message
	if ($ctyped =~ /^text\/plain/i &&
	    $encoding =~ /[78]bit|quoted-printable/i &&
	    ($conf{charset} eq $msgcharset || $conf{charset} eq 'us-ascii') &&
	    $footer !~ /^\*hdr:[ \t]+/i)
	  {
	    given ($encoding) {
	      when (/[78]bit/) {
		$body .= "\n\n$footer" }
	      when (/quoted-printable/) {
		$body .= MIME::QuotedPrint::encode_qp("\n\n$footer") }
	      default {
		die "Unknown encoding \"$encoding\"" }
	    }
	  }
	else {
	  # Move Content-* fields to MIME entity
	  my @ctypeh;
	  while ($header =~ s/(^|\n)(Content-[\w\-]+:[ \t]+(.*\n([ \t]+.*\n)*))/$1/i) {
	    push (@ctypeh, $2) 
	  }
	  my $boundary = "MML_".time()."_$$\@".int(rand(10000)).".$conf{domain}";
	  $header .= "MIME-Version: 1.0\n" if ($header !~ /(^|\n)MIME-Version:/);
	  $header .= "Content-Type: multipart/mixed;\n\tboundary=\"$boundary\"\n";

	  if ($footer !~ s/^\*hdr:[ \t]+// && $conf{charset}) {
	    $footer = "Content-Type: text/plain; charset=$conf{charset}\n".
	    "Content-Disposition: inline\n".
	    "Content-Transfer-Encoding: 8bit\n\n".$footer;
	  }

	  # Make body
	  $body = "\nThis is a multi-part message in MIME format.\n".
	  "\n--$boundary\n".
	  join ('', @ctypeh).
	  "\n$body".
	  "\n--$boundary\n".
	  $footer.
	  "\n--$boundary--\n";
	}
      }
      else {	# Have multipart message
	$ctyped =~ /boundary="?(.*?)"?[;\s]/i;
	my @boundary;
	my $level = 1; $boundary[0] = $boundary[1] = $1; my $pos = 0;

	THROUGH_LEVELS:
	while ($level) {
	  my $hdrpos = index ($body, "--$boundary[$level]", $pos) + length($boundary[$level]) + 3;
	  my $hdrend = index ($body, "\n\n", $hdrpos);
	  my $entity_hdr = substr ($body, $hdrpos,  $hdrend - $hdrpos)."\n";

	  $entity_hdr =~ /(^|\n)Content-Type:[ \t]+(.*\n([ \t]+.*\n)*)/i;
	  $ctyped = $2;

	  if ($ctyped =~ /boundary="?(.*?)"?[;\s]/i) {
	    $level++; $boundary[$level] = $1; $pos = $hdrend + 2;
	    next;
	  }
	  else {
	    my $process_level = $level;
	    while ($process_level == $level) {
	      # Looking for nearest boundary
	      $pos = index ($body, "\n--", $hdrend);

	      # If nothing found, then if it's last entity, add footer
	      # to end of body, else return error
	      if ($pos == -1) {
		if ($level == 1) { $pos = length ($body); }
		last THROUGH_LEVELS;
	      }

	      $hdrend = index ($body, "\n", $pos+3);
	      my $bound = substr ($body, $pos+3, $hdrend-$pos-3);

	      my $difflevel;
	      # End of current level?
	      if ($bound eq $boundary[$level]."--") { $difflevel = 1; }
	      # End of previous level?
	      elsif ($bound eq $boundary[$level-1]."--") { $difflevel = 2; }
	      else { $difflevel = 0; }

	      if ($difflevel) {
		$pos += 1; $level -= $difflevel;
		if ($level > 0) {
		  $pos += length ("--".$boundary[$level]."--"); }
	      }
	      # Next part of current level
	      elsif ($bound eq "$boundary[$level]") {
		$pos += length ("$boundary[$level]") + 1;
	      }
	      # Next part of previous level
	      elsif ($bound eq "$boundary[$level-1]") {
		$pos++; $level--;
	      }
	      # else seems to be boundary error, but do nothing
	    }	 
	  }
	}	# while THROUGH_LEVELS

	if ($pos != -1) {
	  # If end of last level not found, workaround this
	  if ($pos == length($body) && $body !~ /\n$/) {
	    $body .= "\n"; $pos++; }

	  # Modify last boundary - it will not be last
	  substr($body, $pos, length($body)-$pos) = "--$boundary[1]\n";

	  # Prepare footer and append it with really last boundary
	  if ($footer !~ s/^\*hdr:[ \t]+// && $conf{charset}) {
	    $footer = "Content-Type: text/plain; charset=$conf{charset}; name=\"footer\"\n".
	    "Content-Transfer-Encoding: 8bit\n\n".$footer;
	  }
	  $body .= $footer."\n--$boundary[1]--\n";
	}
	# else { print "Non-recoverable error while processing input file\n"; }
      }
    }

    if ($conf{copy_sender} eq 'no') { push (@rcpts, $from) }	# @rcpts will be _excluded_

    # Sort by domains
    my @t;
    @members = sort @t = Invert ('@', '!', @members);
    @rcpts =   sort @t = Invert ('@', '!', @rcpts);

    for (my $r = my $m = 0; $m < @members; ) {
      if ($r >= @rcpts || $members[$m] lt $rcpts[$r]) {
	push (@recipients, $members[$m++]); }
      elsif ($members[$m] eq $rcpts[$r]) { $r++; $m++; }
      elsif ($members[$m] gt $rcpts[$r]) { $r++ };
    }

    @recipients = Invert ('!', '@', @recipients);

    #########################################################
    # Send message to recipients ($conf{maxrcpts} per message)

    warn "Empty recipient" if(grep($_ eq '', @recipients));

    my $maxrcpts =
      ($conf{errors_to} eq 'verp' || $conf{to_recipient} eq 'yes')
      ? 1 : $conf{maxrcpts};
    while (@recipients) {
      my @bcc = splice(@recipients, 0, $maxrcpts);
      my $hdr = $header;

      my $verp_bcc = $bcc[0]; $verp_bcc =~ s/\@/=/g;

      $hdr .= "To: $bcc[0]\n" if ($conf{to_recipient} eq 'yes');

      my $envelope_sender;
      given ($conf{errors_to}) {
	when('drop') { $envelope_sender = "$conf{me}"; }
	when('admin') { $envelope_sender = "$conf{admin}"; }
	when('verp') { $envelope_sender = "$list-owner-$verp_bcc\@$conf{domain}"; }
	when($_ ne 'sender') { $envelope_sender = $conf{errors_to} }
	default { $envelope_sender = ""; }
      }

      send_message($hdr, $body, \@bcc, $envelope_sender);

      sleep $conf{delay} if ($conf{delay});
    }


    $msg = '';	# Clear message, don't send anything anymore
  }

}
else {

#########################################################################
######################## Message to Minimalist ##########################
#########################################################################
# Allowed commands:
#	subscribe <list> [<e-mail>]
#	unsubscribe <list> [<e-mail>]
#	mode <list> <e-mail> <set> [<setParam>]
#	suspend <list>
#	resume <list>
#	maxsize <list> <maxsize>
#	auth <code>
#	which [<e-mail>]
#	info [<list>]
#	who <list>
#	body
#	help

  my @Commands;

  $subject =~ s/^.*?:\s+//g;	# Strip leading 'Anything: '

  if ($subject eq 'body' || $subject eq '') {
    @Commands = split (/\n+/, $body); }
  else {
    @Commands = $subject; }

  my $body;

  foreach my $line (@Commands) {
    my @cmd = split /\s+/, $line;
    my $msg = '';
    %conf = %global_conf;

    #TODO: reset config to global config after each iteration.
    given (shift @cmd) {
      when ([qw/stop exit end thanks --/]) { last }

      when ('help') { $msg .= "\n".mt('_USAGE') }

      when ('auth') {
	my $authcode = shift @cmd;

	my ($cmd, $list, $email, @params) = getAuth($authcode);

	if ($cmd && exists $lists{lc $list}) { # authentication code is valid and $list exists
	  $list = $lists{lc $list};
	  load_config($list);

	  given ($cmd) {
	    when ('subscribe') {
	      $msg .= subscribe($list, $from, $email); }
	    when ('unsubscribe') {
	      $msg .= unsubscribe($list, $from, $email); }
	    when ('mode') {
	      $msg .= chgSettings(shift @params, $list, $email, $email, @params); }
	    default {
	      $msg .=
	      mt('Internal error while processing your request; report sent to administrator.').
	      "\n".
	      mt('Please note that subscription status for [_1] on [_2] did not change.',
		$email, $list);
	      break;
	    }
	  }

	  logCommand($from, "$cmd $list".($email eq $from ? "" : " $email")." @params");
	}
	else { $msg .=
	  "\n".
	  mt('ERROR:'). "\n\t".
	  mt('There is no authentication request with such code ([_1]) or the requst is invalid.',
	    $authcode).
	  "\n\n".
	  mt('SOLUTION:'). "\n\t".
	  mt('Resend your request to Minimalist.');
	}
      }

      when ('which') {
	my $email = shift @cmd;
	$email = $1 if (defined $email && $email =~/^($addr)/);

	if (defined $email && ($email ne $from) && ! verify($from, $password)) {
	  $msg .=
	  mt('ERROR:'). ' '.
	  mt('You are not allowed to get subscriptions of other users.');
	}
	else {
	  logCommand($from, $line);
	  $email = $from unless (defined $email);

	  $msg .= mt('Current subscriptions of [_1]:', $email). "\n\n";

	  # Quote specials (+)
	  $email =~ s/\+/\\\+/g;	# qtemail

	  opendir DIR, ".";
	  while (my $dir = readdir DIR) {
	    if (-d $dir && $dir !~ /^\./) {	# Ignore entries starting with '.'
	      foreach my $f ("", "-writers") {
		open LIST, "$dir/list".$f and do {
		  while (<LIST>) {
		    chomp($_);
		    if ($_ =~ /$email(>.*)?$/i) {
		      $msg .= "* \U$dir\E$f: ".&txtUserSet($1). "\n";
		      last;
		    }
		  }
		  close LIST;
		}	# open LIST
	      }	# foreach
	    }
	  }		# readdir
	  closedir DIR;
	}
      }

      when ('info') {
	logCommand($from, $line);
	my @lists;
	if (my $list = shift @cmd) {
	  # Process only specified list
	  if (exists $lists{lc $list}) {
	    $lists[0] = $list;
	  }
	  else {
	    $msg .=
	    mt('ERROR:'). "\n\t".
	    mt('There is no list ([_1]) here.', uc $list). "\n\n".
	    mt('SOLUTION:'). "\n\t".
	    mt("Send a message to [_1] with a subject of 'info' (no quotes) for a list of available mailing lists.",
	      "$conf{me}");
	  }
	}
	else {
	  @lists = values %lists;
	}
	foreach my $list (@lists) {
	  my $info = read_info($list, 'info');
	  $msg .=
	  mt('Description of list [_1]:', uc $list).
	  "\n\n".
	  (defined($info) ? $info : mt('No description available.'). "\n").
	  "\n\n";
	}
	chomp $msg;
      }

      #####################################################################
      # The rest operates with obligatory list parameter

      my $list = shift @cmd;
      my $owner;

      unless(defined $list) {
	$msg = mt('ERROR:'). ' '. mt('Bad syntax or unknown instruction.');
	break;
      }

      if ( exists $lists{lc $list}) {
	$list = $lists{lc $list};
	load_config($list);

	$owner = "$list-owner\@$conf{domain}";
      }
      else {
	$msg .=
	mt('ERROR:'). ' '. mt('There is no list [_1] here.', uc $list).
	"\n\n".
	mt('SOLUTION:'). "\n\t".
	mt("Send a message to [_1] with a subject of 'info' (no quotes) for a list of available mailing lists.",
	  "$conf{me}");
	break;
      }

      when ('who') {
	if (verify($from, $password)) {
	  my @whoers;
	  logCommand($from, $line);
	  if (open(LIST, "$conf{listdir}/$list/list")) {
	    while (my $ent = <LIST>) {
	      chomp $ent;
	      push (@whoers, $ent) if ($ent !~ /^#/);
	    }
	    if (@whoers) {
	      my @t;
	      @whoers = sort @t = Invert ('@', '!', @whoers);
	      @whoers = Invert ('!', '@', @whoers);
	    }
	    close LIST;
	    $msg .= "\n".
	    mt('[*,_1,user is,users are,No user is] subscribed to [_2]:',
	      scalar @whoers, uc $list).
	    "\n\n";
	    foreach my $ent (@whoers) {
	      $ent =~ s/(>.*)?$//;
	      $msg .= $ent. ': '. &txtUserSet($1). "\n";
	    }
	  }
	}
	else { $msg .=
	  mt('ERROR:'). ' '.
	  mt('You are not allowed to get a listing of subscribed users.');
	}
      }

      when ('subscribe') {
	my $email = shift @cmd;
	$email = $1 if (defined $email && $email =~/^($addr)/);
	
	if (verify($from, $password)) {
	  $msg .= subscribe($list, $from, $email);
	  logCommand($from, $line);
	}
	elsif ($conf{status} & $CLOSED) {
	  $msg .=
	  mt('ERROR:'). ' '. mt('Sorry, this list is closed for you.'). "\n\n".
	  mt('SOLUTION:'). ' '.
	  mt('Please send any comments or questions to [_1].', $owner);
	}
	elsif ((defined $email) && ($email ne $from)) {
	  $msg .=
	  mt('ERROR:'). ' '.
	  mt("You aren't allowed to subscribe other people.");
	}
	else {
	  if ($conf{security} ne 'paranoid') {
	    $msg .= subscribe($list, $from, $email);
	    logCommand($from, $line);
	  }
	  else {
	    genAuth($list, $from, $line, $_);
	  }
	}
      }

      when ('unsubscribe') {
	my $email = shift @cmd;
	$email = $1 if (defined $email && $email =~/^($addr)/);
	
	if (verify($from, $password)) {
	  $msg .= unsubscribe($list, $from, $email);
	  logCommand($from, $line);
	}
	elsif ($conf{status} & $MANDATORY) {
	  $msg .=
	  mt('ERROR:'). ' '. mt('Sorry, this list is mandatory for you.').
	  "\n\n".
	  mt('SOLUTION:'). ' '.
	  mt('Please send any comments or questions to [_1].', $owner);
	}
	elsif ((defined $email) && ($email ne $from)) {
	  $msg .=
	  mt('ERROR:'). ' '.
	  mt("You aren't allowed to subscribe other people.");
	}
	else {
	  if ($conf{security} ne 'paranoid') {
	    unsubscribe($list, $from, $email);
	    logCommand($from, $line);
	  }
	  else {
	    genAuth($list, $from, $line, $_);
	  }
	}
      }

      # obsoleted by mode ?
      if (0) {
      when ('suspend' || 'resume') {
	if (verify($from, $password) || $conf{security} ne 'paranoid') {
	  $msg = chgSettings($msg, $_, $list, $from, $from);
	  logCommand($from, $line);
	}
	else { genAuth($list, $from, $line, $_); }
      }

      # obsoleted by mode ?
      when ('maxsize') {
	if ((shift @cmd) =~ /^\d+$/) {
	  if (verify($from, $password) || $conf{security} ne 'paranoid') {
	    $msg = chgSettings($_, $list, $from, $from, $1);
	    logCommand($from, $line);
	  }
	  else { genAuth($list, $from, $line, $_, $1); }
	}
	else {
	  $msg = mt('ERROR:'). ' '. mt('Bad syntax or unknown instruction.');
	  break;
	}
      }
      }

      when ('mode') {
	my $mode = shift @cmd;
	unless (defined $mode) {
	  $msg = mt('ERROR:'). ' '. mt('Bad syntax or unknown instruction.');
	  break;
	}

	my $userallowed = 0;
	my @args;
	given ($mode) {
	  when ('suspend') { $userallowed = 1 }
	  when ('resume') { $userallowed = 1 }
	  when ('maxsize') {
	    my $size = shift @cmd;
	    if (defined $size && $size =~ /^(\d+)$/) {
	      $userallowed = 1;
	      push(@args, $1) }
	    else {
	      $msg = mt('ERROR:'). ' '. mt('Bad syntax or unknown instruction.');
	      break;
	    }
	  }
	}
	my $email = shift @cmd;
	if (defined $email) {
	  if ($email =~/^($addr)$/) {
	    $email = $1 }
	  else {
	    $msg = mt('ERROR:'). ' '. mt('Bad syntax or unknown instruction.');
	    break;
	  }
	}
	else {
	  $email = $from }

	if (verify($from, $password)) {
	  $msg .= chgSettings($mode, $list, $from, $email, $args[0]);
	  logCommand($from, $line);
	}
	elsif ($userallowed && $email eq $from && $conf{security} ne 'paranoid') {
	  $msg .= chgSettings($mode, $list, $from, $email, $args[0]);
	  logCommand($from, $line);
	}
	elsif ($userallowed && $email eq $from) {
	  genAuth($list, $from, $line, $_, $mode, @args); }
	else { # Not permitted to set mode
	  $msg .=
	  mt('ERROR:'). ' '.
	  mt('You are not allowed to change settings of other people.');
	}
      }

      default {
	$msg = mt('ERROR:'). ' '. mt('Bad syntax or unknown instruction.');
	break;
      }
    }

    $body .=
    (defined $body ? "\n\n": '').
    "############################################################\n".
    "# $line\n\n".
    $msg
    if($msg);
  }

  send_message("Subject: Re: $subject", $body, $mailto) if($body);
}

}

#########################################################################
######################## Supplementary functions ########################

sub send_message ($$$;$) {
  my ($header, $body, $to, $envelope_sender) = @_;
  my @to;

  return unless($body);

  if (ref $to eq 'ARRAY') {
    @to = @$to }
  else {
    @to = ($to) }

  my %headers = (
    From => $envelope_sender ? $envelope_sender : "Minimalist Manager <$conf{me}>",
    To => $#to == 0 ? $to[0] : undef,
    'MIME-Version' => "1.0",
    'Content-Type' => "text/plain; charset=$conf{charset}",
    'Content-Transfer-Encoding' => '8bit',
    'X-Sender' => $conf{mesender},
    'X-List-Server' => "Minimalist v$version <http://www.mml.org.ua/>",
  );

  $header =~ s/\n*$/\n/s;

  while (my ($key, $value) = each(%headers)) {
    $header .= "$key: $value\n" unless($header =~ /^$key: /m) }

  $body .= "\n\n-- \n". mt('Sincerely, the Minimalist'). "\n"
  unless(defined $envelope_sender); #TODO: This is a really ugly hack.

  $envelope_sender = $conf{me} unless($envelope_sender);

  if (defined $smtp) {
    $smtp->mail($envelope_sender);
    #TODO: Do something sensible when recipients are rejected.
    $smtp->recipient(@to, { SkipBad => 1 });
    $smtp->data($header, "\n", $body);
  }
  else {
    open MAIL, "| $conf{sendmail} -f $envelope_sender ". join(' ', @to);
    print MAIL $header. "\n". $body;
    close MAIL;
  }
}

sub verify ($$) {
  my $qfrom = shift;
  my $password = shift;
  return (
    grep(/^$qfrom$/i, @trusted) ||
    defined $password && defined $conf{listpwd} && $password eq $conf{listpwd} ||
    defined $password && defined $conf{adminpwd} && $password eq $conf{adminpwd}
  )
}

#................... SUBSCRIBE .....................
sub subscribe ($$;$) {

  my ($list, $from, $email) = @_;
  my $msg;
  my $cause;
  my $deny = 0;
  my $owner = "$list-owner\@$conf{domain}";

  # Clear any spoofed settings
  $email =~ s/>.*$//;

  $email = $from unless(defined $email);

  if (open LIST, "$conf{listdir}/$list/list") {
    my $users = '';
    $users .= $_ while (<LIST>);
    close LIST;
    my @members = split ("\n", $users);
    my $eml = quotemeta($email);
    # Note comments (#) and settings
    if (grep(/^#*$eml(>.*)?$/i, @members)) {
      $deny = 1;
      $cause = mt('you are already subscribed to [_1].', uc $list);
    }
    elsif ($conf{maxusers} > 0 && @members >= $conf{maxusers}) {
      $deny = 2;
      $cause = mt('there are already the maximum number of [*,_1,subscriber] subscribed to [_2].',
      $conf{maxusers}, uc $list);
    }
    open LIST, ">>$conf{listdir}/$list/list" unless ($deny);
  }

  $msg .= mt('Dear [_1],', $email). "\n\n";

  if (! $deny) {
    &lockf(*LIST, 'lock'); print LIST "$email\n"; &lockf(*LIST);
    $msg .= mt('you have subscribed to [_1] successfully.', uc $list).
    "\n\n".
    mt('Description of the list:'). "\n".
    read_info($list, 'info');
  }
  else {
    $msg .=
    mt('you have not been subscribed to [_1] due to the following reason:',
      uc $list).
    "\n\n".
    '* '. $cause.
    "\n\n".
    mt('Please send any comments or questions to [_1].',
      "$list-owner\@$conf{domain}");
  }

    my $subject = 'Subject: '. mt('You have been subscribed to [_1]', uc $list);
  if (! $deny) {
    send_message($subject, $msg, $email) if($email ne $from);
    send_message($subject, $msg, $owner) if($conf{cc_on_subscribe} =~ /yes/i);
  }
  elsif ($deny == 2) {
    send_message($subject, $msg, $owner);
  }

  return $msg;
}

#................... UNSUBSCRIBE .....................
sub unsubscribe ($$;$) {

  my ($list, $from, $email) = @_;
  my $msg;

  $email = $from unless($email);
  my $owner = "$list-owner\@$conf{domain}";

  if (open LIST, "$conf{listdir}/$list/list") {
    my $users;
    $users .= $_ while (<LIST>);
    close LIST;

    my $ok;
    my $qtemail = $email;
    $qtemail =~ s/\+/\\\+/g;	# Change '+' to '\+' (by Volker)
    if ($users =~ s/(^|\n)$qtemail(>.*)?\n/$1/ig) {
      rename "list", "list".".bak";
      open LIST, ">$conf{listdir}/$list/list";
      &lockf(*LIST, 'lock'); $ok = print LIST $users; &lockf(*LIST);
      if ($ok) {
	$msg .= mt('User [_1] has been unsubscribed sucessfully from [_2].',
	  $email, $list). "\n";
	unlink "list".".bak"; }
      else {
	rename "list".".bak" , "list";
	&genAdminReport('unsubscribe', $email);
	$msg .=
	mt('Internal error while processing your request; report sent to administrator.').
	"\n".
	mt('Please note that subscription status for [_1] on [_2] did not change.',
	  $email, $list);
      }
    }
    else {
      $msg .= mt('User [_1] is not a registered member of list [_2].',
	$email, uc $list). "\n";
      $ok = 0;
    }

    if ($ok) {
      my $subject = 'Subject: '. mt('You have been unsubscribed from [_1]',
	uc $list);
      send_message($subject, $msg, $email) if($email ne $from);
      send_message($subject, $msg, $owner) if($conf{cc_on_subscribe} =~ /yes/i);
    }
  }

  return $msg;
}

sub genAdminReport ($$$) {
  my ($rqtype, $list, $email) = @_;

  my $headers =
  'Subject: '. mt('Error processing'). "\n".
  'Precedence: High';

  my $body = 
  mt('ERROR:'). "\n".
  mt("Minimalist was unable to process '[_1]' request on [_2] for [_3].",
    $rqtype, $list, $email).
  mt('There was an error while writing into file "list"');

  send_message($headers, $body, $conf{admin});
}

# returns user settings in plain/text format
sub txtUserSet {

  my $userSet = shift;
  my $usrmsg;
  my $i = 0;

  if ($userSet) {
    # Permissions
    if ($userSet =~ /\+/) { $usrmsg .= mt('posts are allowed'); $i++; }
    elsif ($userSet =~ /-/) { $usrmsg .= mt('posts are not allowed'); $i++; }
    # Suspend
    if ($userSet =~ /!/) {
      $usrmsg .= ($i++ ? '; ' : ''). mt('subscription suspended');
    };
    # Maxsize
    if ($userSet =~ /#ms([0-9]+)/) {
      $usrmsg .= ($i++ ? ';' : '').
      mt('maximum message size is [_1] bytes', $1)
    }
  }
  else {
    $usrmsg .= mt('there are no specific settings'); }

  return $usrmsg;
}

# Changes specified user settings, preserves other 
sub chgUserSet ($$;$) {

 my ($curSet, $pattern, $value) = @_;

 $curSet = '>' if (! $curSet);		# If settings are empty, prepare delimiter

 $curSet =~ s/$pattern//g;
 $curSet .= $value if ($value);

 $curSet = '' if ($curSet eq '>');	# If settings are empty, remove delimiter

 return $curSet;
}

sub chgSettings ($$$$;@) {
  my $msg;
  my ($mode, $list, $from, $email, @params) = @_;
  my $currentSet;
  my $newSet;
  my @members;

  $email = $from unless($email);

  if (open LIST, "$conf{listdir}/$list/list") {
    while (<LIST>) { chomp ($_); push (@members, lc($_)); }
    close LIST;

    # Quote specials
    my $qtemail = $email;
    $qtemail =~ s/\+/\\\+/g;

    for (my $i=0; $i < @members; $i++) {
      if ($members[$i] =~ /^($qtemail)(>.*)?$/) {
	$currentSet = $2;
	# Ok, user found
	given ($mode) {
	  when ('reset') {
	    $newSet = chgUserSet($currentSet, '.*'); }
	  when ('usual') {
	    $newSet = chgUserSet($currentSet, '[-\+]+'); }
	  when ('reader') {
	    $newSet = chgUserSet($currentSet, '[-\+]+', '-'); }
	  when ('writer') {
	    $newSet = chgUserSet($currentSet, '[-\+]+', '+'); }
	  when ('suspend') {
	    $newSet = chgUserSet($currentSet, '!+', '!'); }
	  when ('resume') {
	    $newSet = chgUserSet($currentSet, '!+'); }
	  when ('maxsize') {
	    if ($params[0]+0 == 0) {
	      $newSet = chgUserSet($currentSet, '(#ms[0-9]+)+'); }
	    else {
	      $newSet = chgUserSet($currentSet, '(#ms[0-9]+)+', "#ms".($params[0]+0)); }
	  }
	}

	$members[$i] = $email.$newSet;
	$currentSet = '>';	# Indicate, that user found, even if there are no settings
	last;
      }
    }
  };	# open LIST ... do

  my $ok;
  if ($currentSet) {		# means, that user found
    my $users = join("\n", @members). "\n";

    rename "list", "list".".bak";
    open LIST, ">$conf{listdir}/$list/list";
    &lockf(*LIST, 'lock'); $ok = print LIST $users; &lockf(*LIST);
    close LIST;

    if ($ok) {
      $msg .= mt('Settings for user [_1] on list [_2]:',
	$email, uc $list). ' '.
      &txtUserSet($newSet, 1). "\n";
      unlink "list".".bak";
    }
    else {	# Write unsuccessfull, report admin
      rename "list".".bak", "list";
      &genAdminReport('mode', $email);
      $msg .=
      mt('Internal error while processing your request; report sent to administrator.').
      "\n".
      mt('Please note that settings for [_1] on [_2] did not change.',
	$email, $list);
    }
    # TODO create better subject
    send_message('Subject: '. mt('Settings changed'), $msg, $email)
    if($ok && $email ne $from);
  }
  else { # User not found
    $msg .= mt('User [_1] is not a registered member of list [_2].',
      $email, uc $list). "\n";
  }

  return $msg;
}

##########################################################################

#................... READ CONFIG .....................
sub read_config ($$) {
  my ($fname, $scope) = @_;
  my $adminChanged;
  my %nconf;

  $scope = "list" unless (defined $scope && $scope eq 'global');

  if (open(CONF, $fname)) {
    while (<CONF>) {
      chomp $_;
      next if (/^\s*(#.*)?$/); #Ignore Comments and empty lines

      # Match assignment with optional comment: $1 = $2 #$3
      if (/^\s*([[:print:]]+?)\s*=\s*([^#]*?)\s*(#.*)?$/i) {
	my $value = $2;

	given ($1) {
	  if ($scope eq 'global') {
	    # Only global
	    when ('background') { $nconf{background} = lc($value); }
	    when ('blacklist') {
	      $value =~ s/\s//g;
	      @blacklist = expand_lists(split(':', $value)); }
	    when ('blocked robots') { $nconf{blocked_robots} = $value; }
	    when ('directory') { $nconf{directory} = $value;}
	    when ('logfile') { $nconf{logfile} = $value; }
	    when ('log messages') { $nconf{logmessages} = $value; }
	    when ('password') { $nconf{adminpwd} = $value; }
	    when ('request valid') { $nconf{auth_valid} = lc($value); }
	    when ('user') {
	      my ($mode, $uid) = (stat CONF)[2,4];
	      if (defined $uid && defined $mode &&
		  $uid == 0 && !($mode & 0022)) {
		$nconf{user} = $value }
	    }
	  }
	  else {
	    # Only local
	    when ('auth') {
	      $value =~ /^(.*?)\s+(.*)$/;
	      my $auth_args = $2;

	      if ($1 eq 'mailfrom') {
		$auth_args =~ s/\s//g;
		@trusted = expand_lists(split(':', $auth_args)); }
	      elsif ($1 eq 'password') {
		$conf{listpwd} = $auth_args; }
	      else {
		warn "Unknown authentication method \"$1\"";
	      }
	    }
	    when ('list gecos') { $nconf{list_gecos} = $value; }
	    when ('to recipient') { $nconf{to_recipient} = lc($value); }
	  }
	  # Both: local and global
	  when ('delivery') {
	    $smtp->quit() if(defined $smtp);
	    $smtp = undef;
	    if ($value =~ /(\w+):(\d+)/) {
	      $smtp = Net::SMTP->new(Host => $1, Port => $2)
		or die "SMTP connect failed. SMTP connection specified in local chrooted config?";
	      $nconf{sendmail} = undef }
	    else {
	      $nconf{sendmail} = $value }
	  }
	  when ('domain') {
	    $nconf{domain} = $value;
	    $nconf{me} = "minimalist\@$value";
	    $nconf{admin} = "postmaster\@$value" unless (defined $value);
	  }
	  when ('admin') { $nconf{admin} = $value; }
	  when ('errors to') { $nconf{errors_to} = lc($value); }
	  when ('security') { $nconf{security} = lc($value); }
	  when ('archive size') { $nconf{arcsize} = $value; }
	  when ('archive') {
	    if ($value =~ /^pipe\s+(.*)$/i) {
	      $nconf{archpgm} = $1;
	      $nconf{archive} = "pipe"; }
	    else {
	      $nconf{archpgm} = 'BUILTIN';
	      $nconf{archive} = lc($value);
	    }
	  }
	  when ('status') {
	    # Calculate mask for status
	    my %strel = ("open", $OPEN, "ro", $RO, "closed", $CLOSED, "mandatory", $MANDATORY);
	    $value =~ s/\s//g;
	    $nconf{status} = 0;
	    foreach (split(/,/, lc($value))) { $nconf{status} += $strel{$_}; }

	  }
	  when ('copy to sender') { $nconf{copy_sender} = lc($value); }
	  when ('reply-to list') { $nconf{reply_to_list} = lc($value); }
	  when ('from') { $nconf{outgoing_from} = $value; }
	  when ('modify subject') { $nconf{modify_subject} = lc($value); }
	  when ('maxusers') { $nconf{maxusers} = $value; }
	  when ('maxrcpts') {
	    $nconf{maxrcpts} = 20 if ($value < 1);
	    $nconf{maxrcpts} = 50 if ($value > 50);
	  }
	  when ('delay') { $nconf{delay} = $value; }
	  when ('maxsize') { $nconf{maxsize} = $value; }
	  when ('language') { $nconf{language} = lc $value; }
	  when ('list information') {
	    # Make lowercase if value isn't URL
	    $nconf{listinfo} = lc($value) if ($value =~ /^(yes|no)$/i);
	    # In global config only 'yes' or 'no' allowed
	    $nconf{listinfo} = 'no' if ($scope eq 'global' && $nconf{listinfo} ne 'yes');
	  }
	  when ('strip rrq') { $nconf{strip_rrq} = lc($value); }
	  when ('modify message-id') { $nconf{modify_msgid} = lc($value); }
	  when ('remove resent') { $nconf{remove_resent} = lc($value); }
	  when ('extra header') { $nconf{xtrahdr} .= $value . "\n"; }
	  when ('cc on subscribe') { $nconf{cc_on_subscribe} = lc($value); }
	  when ('charset') { $nconf{charset} = lc($value); }
	  default { 
	    warn "Unknown key \"$_\" or not allowed in $scope config scope";
	  }
	}
      }
      else {
	chomp $_;
	warn "Could not parse \"$_\" in $fname line $.";
      }
    }

    close CONF;

    return %nconf;
  }
  else {
    warn "Could not open $fname: $!";
    return ( ) }
}

sub load_config ($) {
  my $list = shift;
  my %nconf = read_config("$conf{listdir}/$list/config", 'list');

  @conf{keys %nconf} = values %nconf;

  load_language();
}

#..........................................................
sub expand_lists {
 my @junk = @_;
 my @result;

 foreach my $s (@junk) {
   if ( $s =~ s/^\@// ) {	# Expand items, starting with '@'
     if (open(IN, $s)) {
       while (<IN>) {
         chomp $_; $result[@result] = $_; }
       close IN;
      }
    }
   elsif ($s ne '') { $result[@result] = $s; }
  }
 @result;
}

#.......... Read file and substitute all macros .........
sub read_info ($$) {
 my ($list, $file) = @_;
 my $fname = "$conf{listdir}/$list/$file";
 my $tail;

 if (open(TAIL, $fname)) {
   $tail .= $_ while (<TAIL>);
   close TAIL;

   if ($tail) {
     $tail =~ s/\\a/$conf{admin}/ig;
     $tail =~ s/\\d/$conf{domain}/ig;
     $tail =~ s/\\l/$list/ig;
     $tail =~ s/\\o/$list-owner\@$conf{domain}/ig;
    }
  }

  return $tail;
}

#.................... Built-in archiver ..........................
sub archive ($$$) {

 my ($list, $header, $body) = @_;

 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
 $year += 1900;
 $mon++;

 my $path = "$conf{listdir}/$list/archive/";
 mkdir($path, 0755) if (! -d $path);

 my @types = ("yearly", "monthly", "daily");
 my %rel = ($types[0], $year, $types[1], $mon, $types[2], $mday);

 foreach my $key (@types) {
   $path .= $rel{$key}."./";
   mkdir($path, 0755) if (! -d $path);
   last if ($key eq $conf{archive});
  }

 my $msgnum;
 if (open(NUM, $path."SEQUENCE")) {
   read NUM, $msgnum, 16;
   $msgnum = int($msgnum);
   close NUM;
  }
 else { $msgnum = 0 }

 open ARCHIVE, ">$path".$msgnum;
 print ARCHIVE $header."\n".$body;
 close ARCHIVE;

 open NUM, ">$path"."SEQUENCE";
 print NUM $msgnum+1;
 close NUM;
}

#.................... External archiver ..........................
sub arch_pipe ($$) {
  my ($header, $body) = @_;

  open (ARCHIVE, "| $conf{archpgm}");
  print ARCHIVE $header."\n".$body;
  close (ARCHIVE);
}

#.................... Generate authentication code ...............
sub genAuth ($$$$;@) {
  my ($list, $from, $subject, $cmd, @params) = @_;

  my $authcode = Digest::MD5::md5_hex(int(rand(2**32)));

  mkdir ("auth", 0750) if (! -d 'auth');

  open AUTH, ">auth/$authcode";
  print AUTH "$cmd $list $from ". join(' ', @params). "\n";
  close AUTH;

  send_message("Subject: auth $authcode",
    mt("Your request '[_1]' must be authenticated. To accomplish this, send another request to [_2] with the following subject:", $subject, $conf{me}).
    "\n\n\t auth $authcode\n\n".
    mt('Or simply use the reply function of your mail reader.'). "\n".
    mt('This authentication request is valid for the next [*,_1,hour] from now on and then will be discarded.',
      $conf{auth_valid}). "\n",
    $from
  );
}

#................. Check for authentication code ...............
sub getAuth ($) {

  my ($cmd, $list, $email, @params);
  my $authcode = shift;

  if ($authcode =~ /^([\dabcdef]+)$/) {
    my $authfile = "auth/$1";
    if (open AUTH, $authfile) {
      my $authtask = <AUTH>; chomp $authtask;
      close AUTH; unlink $authfile;

      ($cmd, $list, $email, @params) = split(/\s+/, $authtask);

      return ($cmd, $list, $email, @params);
    }
  }
}

#............... Clean old authentication requests .............
sub cleanAuth {

 my $now = time;
 my $dir = "auth";
 my $mark = "$dir/.lastclean";
 my $auth_seconds = $conf{auth_valid} * 3600;	# Convert hours to seconds

 if (! -f $mark) { open LC, "> $mark"; close LC; return; }
 else {
   my @ftime = stat(_);
   return if ($now - $ftime[9] < $auth_seconds);	# Return if too early
 }

 utime $now, $now, $mark;	# Touch .lastclean
 opendir DIR, $dir;
 while (my $entry = readdir DIR) {
   if ($entry =~ /^([^\.].*)$/ && -f "$dir/$entry") {
     $entry = $1;
     my @ftime = stat(_);
     unlink "$dir/$entry" if ($now - $ftime[9] > $auth_seconds);
    }
  }
 closedir DIR;
}

#............................ Locking .........................
sub lockf {
 my ($FD, $lock) = @_;

 if ($lock) {		# Lock FD
   flock $FD, LOCK_EX;
   seek $FD, 0, 2;
  }
 else {			# Unlock FD and close it
   flock $FD, LOCK_UN;
   close $FD;
  }
}

#......................... Logging activity ....................
sub logCommand ($$) {

 my ($from, $command) = @_;

 $command =~ s/\n+/ /g; $command =~ s/\s{2,}/ /g;	# Prepare for logging

 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
 $year += 1900;

 printf LOG "%s %02d %02d:%02d %d %s\n",
   (qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec))[$mon],
   $mday, $hour, $min, $year, "$from: $command";
}

#..................... Swap username & domain ...................
sub Invert {
 my $delim = shift;
 my $newdelim = shift;
 my @var = @_;
 my $restdelim = '>';	# And remember about user's specific flags, which are delimited by '>'
 my ($i, $us, $dom, $usdom, $rest) = 0;

 for (; $i < @var; $i++) {
   ($usdom, $rest) = split ($restdelim, $var[$i]);
   ($us, $dom) = split ($delim, $usdom);
   $var[$i] = $dom.$newdelim.$us.($rest ? $restdelim.$rest : "");
  }

 @var;
}

sub load_language () {
  require "translations/$conf{language}.pm" unless($conf{language} eq 'en');
  
  $maketext =
  "Translation::$conf{language}"->new($conf{language}) || die "Language?";
}

{
  package Translation::en;
  use parent 'Locale::Maketext';

  sub new () {
    my $class = shift;
    my $self = $class->SUPER::new();
    $self->{encoding} = 'iso-8859-1';
    bless ($self, $class);
    return $self;
  }

  our %Lexicon;
  INIT {
    %Lexicon = (
      _AUTO => 1,
      _USAGE => <<_EOF_,
This is the Minimalist Mailing List Manager.

Commands may be either in subject of message (one command per message)
or in body (one or more commands, one per line). Batched processing starts
when subject either empty or contains command 'body' (without quotes) and
stops when either arrives command 'stop' or 'exit' (without quotes) or
gets 10 incorrect commands.

Supported commands are:

subscribe <list> ~[<email>~] :
    Subscribe user to <list>.

unsubscribe <list> ~[<email>~] :
    Unsubscribe user from <list>.

auth <code> :
    Confirm command, used in response to subscription requests in some cases.
    This command isn't standalone, it must be used only in response to a
    request by Minimalist.

mode <list> <mode> <email> :
    Set mode for specified user on specified list. Allowed only for
    administrator. Mode can be (without quotes):
      * 'reader' - read-only access to the list for the user;
      * 'writer' - user can post messages to the list regardless of list's
		   status
      * 'usual' -  clear any two above mentioned modes
      * 'suspend' - suspend user subscription
      * 'resume' - resume previously suspended permission
      * 'maxsize <size>' - set maximum size (in bytes) of messages, which
			   user wants to receive
      * 'reset' - clear all modes for specified user

suspend <list> :
    Stop receiving of messages from specified mailing list

resume <list> :
    Restore receiving of messages from specified mailing list

maxsize <list> <size> :
    Set maximum size (in bytes) of messages, which user wants to receive

which ~[<email>~] :
    Return list of lists to which user is subscribed

info ~[<list>~] :
    Request information about all existing lists or about <list>

who <list> :
    Return the list of users subscribed to <list>

help :
    This message

Note, that commands with <email>, 'who' and 'mode' can only be used by
administrators (users identified in the 'mailfrom' authentication scheme or
who used a correct password - either global or local). Otherwise command will
be ignored. Password must be supplied in any header of message as fragment of
the header in the following format:

{pwd: list_password}

For example:

To: MML Discussion {pwd: password1235} <mml-general\@kiev.sovam.com>

This fragment, of course, will be removed from the header before sending message
to subscribers.
_EOF_
    );
  }

  1;
}
