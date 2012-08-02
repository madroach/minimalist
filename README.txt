=========================== Minimalist =============================

I. Common information

Minimalist is a MINImalist MAiling LIST manager. It is fast, extremely easy
to setup and support. It is written in Perl and fully tested on FreeBSD and
Linux, where it works pretty well. However there aren't causes not to use
Minimalist on any other Unix system, because it doesn't use any
system-dependent features.

Minimalist has these features:

 . subscribe/unsubscribe users by request
    * including write-only option of subscription
 . several levels of security
 . read-only/closed/mandatory lists
 . information about list; users, subscribed to list; lists, to which user
    subscribed
 . per-user options:
    * read-only (for open lists)
    * write allow (for read-only lists))
    * maximum message size
 . susped/resume subscription
 . archiving lists (internal and external), with maximum size of archived
    message
 . multilanguage support
 . process MIME-encoded messages
    * including support for local charset (for reports and footer)
 . hook for bounce processing (using VERP - Variable Envelope Return-Path)
 . external delivery of processed message
 . blacklist
 . logging activity

Minimalist has a notion of 'administrators' (global and per-list). They
have full rights to manipulate subscription of other users and get any
information, related to lists and users.

Basic language of Minimalist is English, additional languages can be found
either in distribution (in directory languages/) or on Web, at
http://www.mml.org.ua/languages/. There is also README, which explains how
to use these languages.

Commands may be either in subject of message (one command per message)
or in body (one or more commands, one per line). Batched processing starts
when subject either empty or contains command 'body' (without quotes) and
stops when either arrives command 'stop' or 'exit' (without quotes) or
gets 10 incorrect commands.

Supported commands are:

subscribe <list> [<email>] :
    Subscribe user to <list>. If <list> contains suffix '-writers', user
    will be able to write to this <list>, but will not receive messages
    from it.

unsubscribe <list> [<email>] :
    Unsubscribe user from <list>. Can be used with suffix '-writers' (see
    above description for subscribe)

auth <code> :
    Confirm command, used in response to subscription requests in some cases.
    This command isn't standalone, it must be used only in response to a
    request by Minimalist.

mode <list> <email> <mode> :
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

which [<email>] :
    Return list of lists to which user is subscribed

info [<list>] :
    Request information about all existing lists or about <list>

who <list> :
    Return the list of users subscribed to <list>

help :
    Return list of supported commands with brief description about every
    command

Note, that commands with <email>, 'who' and 'mode' can only be used by
administrators (users identified in the 'mailfrom' authentication scheme or
who used a correct password - either global or local). Otherwise command will
be ignored. Password must be supplied in any header of message as fragment
of the header in the following format:

{pwd: list_password}

For example:

To: MML Discussion {pwd: password1235} <mml-general\@kiev.sovam.com>

This fragment, of course, will be removed from the header before sending
message to subscribers.

----------------------------------------------------------------------------
II. Install

To install, place minimalist.pl somewhere (in /usr/local/sbin for example).
This path must be accessible for MTA and minimalist.pl must be executable
by your MTA.

Then copy minimalist.conf-sample to /usr/local/etc/minimalist.conf. If you
wish to have it in different location, you will use '-c' command-line
directive, followed by full path and name of file, where appropriate config
located (for example: minimalist.pl -c /etc/minimalist.conf ). Set
variables in config accordingly to your needs (defaults are useful in most
cases).

The next step is to create alias for minimalist, which pipes received
message to the program. The often place of aliases file is /etc/aliases.
Add this line at the end of file:

minimalist:		"|/usr/local/sbin/minimalist.pl"

and, if your MTA requires, do all it need to actualize changes.

After this you must create directory which Minimalist will use for work.
It is defined in the minimalist.conf by directive 'directory'. This
directory must be *WRITABLE* by your MTA (check next section for information
on how to detect Minimalist's EUID/EGID).

----------------------------------------------------------------------------
III. Creating lists

1. In the main Minimalist's directory create directory, named exactly as
list you creating. This directory and it's contents must be owned by
uid/gid of your MTA (it's because Minimalist will write here some control
information - subscribed users, archived messages, etc). The simple and right
method to know MTA's euid/egid is:

 . create in /etc/aliases such entry:
 	mtaid:	"|tee /tmp/mtaid.tst"
 . mail message to mtaid
 . check owner/group of resulted /tmp/mtaid.tst and chown main Minimalist's
   directory (and all subsequent) to this owner/group
 . delete 'mtaid' alias from /etc/aliases

2. Add list's name and short description of it into lists.lst file (in the
main Minimalist's directory). This file will be shown by the command
<info>. Example of this file's contents:

list	This is testing list
info	General information, news, etc

3. Create in the list's directory some files:

 a) config
     Private settings for this list, they override global parameters.

 b) info
     Common information about list, used when user subscribes to the list
     and requests information about list.

 c) footer
     This file will be appended to any message, passed through list. There
     are few ways in which footer can be added to message:

      * if message is not encoded (i.e. if it's 7bit or 8bit), message's
	charset is the same as list's charset or list's charset is default
	(us-ascii) and footer doesn't contain any predefined MIME-headers
	(see below), then footer will be simply added to the end of the
	incoming message.

      * else entire message will be converted to MIME-format and footer
	will be added as separate entity, with his own charset (from
	configuration or from predefined headers).

      * if message is already MIME-encoded, then footer will be added as
        separate entity, accordingly to structure of incoming message.

     It means, that footer will always be visible regardless of attachments
     in message or encoding of message or charset, used in message.

     If you want to define your own headers, start footer with string
     '*hdr: ' (without quotes), followed by headers. Body of footer must be
     separated from header with empty line, for example:

     +--------------------------------------------------------
     |*hdr: Content-Type: text/html; charset=koi8-r
     |Content-Transfer-Encoding: 8bit
     |
     |<html>
     |... rest body of header ...
     |</html>
     +--------------------------------------------------------

     It gives ability to use in footer whatever you want, from HTML code,
     which has references to some other resources, to animated GIFs or
     Flash programs.

There are some useful macros can be used in 'info' and 'footer' files:

 \a	will be expanded to administrator's email
 \d	will be expanded to <domain>
 \l	will be expanded to <list>
 \o	will be expanded to <list>-owner@<domain>

4. Add list's aliases to /etc/aliases file:

list:		"|/usr/local/sbin/minimalist.pl list"
list-owner:	user@somewhere

If you are using VERP for bounce processing (see minimalist.conf-sample for
information about directive 'verp'), you must add one more alias, something
like to:

list-owner-*:	"|/path/to/bounce_processing_tool.pl"

Wildcard mask specifies, that any message, where recipient's address starts
on 'list-owner-', will be passed to bounce_processing_tool.pl. Check your
MTA documentation on how to create wildcard aliases.

Distribution of Minimalist does not provide bounce processing program for
now. You should use any third-party program.

----------------------------------------------------------------------------
IV. Check configuration

You always can check configuration with command:

 minimalist.pl - [listname [listname ... ]]
 
where 'listname' is existing list's name.  If there are errors in they will
be reported. It is recommended always check configuration after any
changes either in global configuration file or in list's config.

----------------------------------------------------------------------------
V. Security

Information about how to get administrative privileges, stored in global
and private configs. You must set owner and permissions of this configs to
allow your MTA access configs and disallow access for unprivileged users.

----------------------------------------------------------------------------
VI. Internals

Subscribers are listed in files 'list' and 'list-writers' in list's
directory. Format: e-mail per row. Settings for subscriber are appended to
his e-mail through separator '>'. Available values are (without quotes):

'+' - user allowed to write in read only list (mode ... writer)
'-' - user disallowed to write in list (mode ... reader)
'!' - suspended user (suspend/resume, mode ... suspend/resume)
'#ms<size>' - maximum size in bytes of messages for user

Archives are located under list's directory in archive/yyyy./mm./dd./[0-9]*
in format one file per one message. DON'T DELETE "SEQUENCE" file in this
directory - there is a number of a last archived message!

VII. Enjoy :)

Directory sample/ in the distribution contains examples of configuration
files. Directory docs/FAQ contains some FAQs, contrib/ - some third party
supporting programs (please, note, that author doesn't aware about their
functionality and damage possibility).

There is mailing list about Minimalist. Please, mail to
	minimalist@kiev.sovam.com
with subject of 'subscribe mml-general' to subscribe on this list.

Vladimir Litovka, <doka@kiev.sovam.com>
http://www.mml.org.ua/
