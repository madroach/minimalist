push (@languages, 'DE');

##################################################################
###   DE = formal German
###
###   Added by Volker Tanger


#-------------------------------
$msgtxt{'1DE'} = <<_EOF_ ;
Dies das Minimalist Mail-Listen Programm.

Ein einzelnes Kommando wird in der Betreffzeile angegeben. Sollen mehrere
Kommandos ausgefuehrt werden, so muss in der Betreffzeile "body" stehen 
(ohne Anfuehrungsstriche) - die Kommandos stehen dann (jeweils nur eines 
pro Zeile) im Nachrichtentext. Die Bearbeitung wird beendet mit einer Zeile
in der "stop" oder "exit" (ohne Anfuehrungsstriche) steht, oder nachdem zehn
falsche/unbekannte Kommandozeilen auftraten.


Bekannte Kommandos sind:

subscribe <list> [<email>] :
    In die Liste <list> einschreiben. Wird an <list> das Wort '-writers'
    angehaengt, dann kann man zwar an die Mailliste schreiben, werhaelt 
    aber keine nachrichten. Praktisch, wenn man mehrere Mailadressen 
    hat, von denen man aus schreibt.

unsubscribe <list> [<email>] :
    Aus der Liste <list> austragen. Kann genauso mit '-writers' 
    kombiniert werden wie SUBSCRIBE (s.o.)

auth <code> :
    Bestaetigungskommando - funktioniert nur als Antwort auf Anfragen
    durch Minimalist.

mode <list> <email> <mode> :
	Ein Befehl nur fuer Administratoren, mit dem das Verhalten der
	Mailingliste geaendert werden kann. Die <mode>s sind (jeweils
	ohne Anfuehrungsstriche):
	 * 'reader' - der Benutzer darf die Liste nur lesen, nicht aber
		schreiben
	 * 'writer' - der Benutzer darf unabhaengig vom Listenstatus
		in die Liste schreiben
	 * 'usual' - setzt den Benutzer auf Standardeinstellung zurueck
		(d.h. loescht seine vorherigen 'reader'/'writer' Modes
	 * 'suspend' - setzt den Benutzer inaktiv, z.B. für Urlaubszeiten
	 * 'resume' - aktiviert den Benutzer wieder
	 * 'reset' - loescht alle o.g. Modi für den Benutzer, d.h. zurueck
		auf 100% Standardeinstellung

suspend <list> :
	Urlaubsschaltung ein - es werden keine Nachrichten mehr von der 
	Mailingliste versandt, ohne die Liste aber zu verlassen

resume <list> :
	Urlaubsschaltung aus - Nachrichten werden wieder versandt

maxsize <list> <size> :
	Setzt (pro Nutzer) die maximale Dateigroesse, die er empfangen will.

which [<email>] :
    Liste aller Mail-Listen, bei der der Benutzer eingetragen ist.

info [<list>] :
    Info zur Mail-Liste <list> bzw. eine Uebersicht ueber alle
    Listen auf diesem Server.

who <list> :
    Eine Liste aller Teilnehmer der Mail-Liste <list>

help :
    Diese Nachricht.

Nur Administratoren bzw. Moderatoren koennen den <email> Parameter 
bzw. die 'who' und 'mode' Kommando benutzen. Anfragen von anderen 
werden ignoriert.
		 
_EOF_


#-------------------------------
$msgtxt{'2DE'} = "FEHLER:\n    Sie (";
$msgtxt{'3DE'} = ") sind kein Telnehmer dieser Liste.\n\n".
	"LOESUNG:\n    Senden Sie bitte eine Mail an minimalist\@";
$msgtxt{'4DE'} = " mit dem Betreff/Subject\n".
	"'info' (ohne Anfuehrungszeichen) fuer Infos zur Anmeldung.\n";

#-------------------------------
$msgtxt{'5DE'} = "FEHLER:\n    Sie duerfen nicht an diese Liste schreiben.\n";

#-------------------------------
$msgtxt{'6DE'} = "FEHLER:\n    Die Nachricht ist groesser als die erlaubten (";
$msgtxt{'7DE'} = " bytes).\n\nLOESUNG:\n    Kleinere Nachricht oder Nachricht stueckeln.\n\n".
	"===========================================================================\n".
	"Kopf der Nachricht folgt:\n";

#-------------------------------
$msgtxt{'8DE'} = "\nFEHLER:\n\tEs gibt keine (aktuelle) AUTH-Anfrage mit diesem Code: ";
$msgtxt{'9DE'} = "\n\nLOESUNG:\n\tAnfrage erneut wiederholen.";

#-------------------------------
$msgtxt{'10DE'} = "\nFEHLER:\n\tNur Administratoren duerfen dieses Kommando ausfuehren.\n".
             "\nLOESUNG:\n\tKeine.";

#-------------------------------
$msgtxt{'11DE'} = "\nAktuell bestellte Mail-Listen ";

#-------------------------------
$msgtxt{'12DE'} = "\nFEHLER:\n    Hier existierte die Liste \U";
$msgtxt{'13DE'} = "\E nicht.\n\nLOESUNG:\n    Eine Mail an minimalist\@";
$msgtxt{'14DE'} = " senden mit Betreff\n    'info' (ohne Anfuehrungszeichen) um eine Liste aller Listen zu erhalten.\n";

#-------------------------------
$msgtxt{'15DE'} = "\nFEHLER:\n\tNur Administratoren duerfen Teilnehmer direkt anmelden.\n".
	      "\nLOESUNG:\n\tKeine.";

#-------------------------------
$msgtxt{'16DE'} = "\nFEHLER:\n\tLeider ist diese Liste fer sich nicht zugaenglich.\n".
	      "\nLOESUNG:\n\tRueckfragen bitte an ";

#-------------------------------
$msgtxt{'17DE'} = "\nFEHLER:\n\tDiese Liste duerfen Sie leider nicht abbestellen.\n".
	      "\nLOESUNG:\n\tRueckfragen bitte an ";

#-------------------------------
$msgtxt{'18DE'} = "Ihre Anfrage";
$msgtxt{'19DE'} = "muss authentisiert werden. Dazu bitte eine weitere Mail senden\nan ";
$msgtxt{'20DE'} = " (oder einfach auf 'Antworten' druecken)\nmit dem Betreff:";
$msgtxt{'21DE'} = "Dieser Authentisierungsschluessel ist gueltig fuer die naechsten ";
$msgtxt{'22DE'} = " Stunden.\n";

#-------------------------------
$msgtxt{'23DE'} = "\nHier die gewuenschte Information ueber";

#-------------------------------
$msgtxt{'24DE'} = "\nAuf diesem Server sind folgende Mail-Listen verfuegbar";

#-------------------------------
$msgtxt{'25DE'} = "\nTeilnehmer der Liste";
$msgtxt{'25.1DE'} = "\nInsgesamt: ";

#-------------------------------
$msgtxt{'26DE'} = "\nFEHLER:\n\tNur Administratoren duerfen dieses Kommando ausfuehren.\n".
             "\nLOESUNG:\n\tKeine.";

#-------------------------------
$msgtxt{'27DE'} = "\nFEHLER:\n\tFalsches oder unbekanntes Kommando.\n".
   	   "\nLOESUNG:\n\n$msgtxt{'1DE'}";

#-------------------------------
$msgtxt{'28DE'} = "Mit freundlichen Gruessen,\nIhr Minimalist";

#-------------------------------
$msgtxt{'29DE'} = "Sie sind bereits Teilnehmer bei";

#-------------------------------
$msgtxt{'30DE'} = "Leider ist die Listenkapazitaet erschoepft ";

#-------------------------------
$msgtxt{'31DE'} = "Sie haben sich erfolgreich an der Mail-Liste ";

#-------------------------------
$msgtxt{'32DE'} = "angemeldet.\n\nBitte beachten Sie folgendes:";

#-------------------------------
$msgtxt{'33DE'} = "Sie wurden nicht in die Mail-Liste";
$msgtxt{'34DE'} = "eingetragen. Der Grund:";
$msgtxt{'35DE'} = "Fragen und Anmerkungen bitte an den Listenadministrator ";

#-------------------------------
$msgtxt{'36DE'} = "\nDer Teilnehmer";
$msgtxt{'37DE'} = "wurde erfolgreich ausgetragen.\n";

#-------------------------------
$msgtxt{'38DE'} = "\nInterner Fehler - eine Nachricht wurde an den Administrator gesandt.\nIhr Mitgliedsstatus der Liste ";
$msgtxt{'38.1DE'} = " hat sich nicht geändert.";

#-------------------------------
$msgtxt{'39DE'} = "ist kein Teilnehmer dieser Mail-Liste.\n";

#-------------------------------
$msgtxt{'40DE'} = "Willkommen";

#-------------------------------
$msgtxt{'41DE'} = "\nEinstellungen für den Benutzer ";

#-------------------------------
$msgtxt{'42DE'} = " auf der Liste ";

#-------------------------------
$msgtxt{'43DE'} = " es gibt keine besonderen Einstellungen";
$msgtxt{'43.1DE'} = " Sie haben Schreibberechtigung.";
$msgtxt{'43.2DE'} = " Sie haben keine Schreibberechtigung.";
$msgtxt{'43.3DE'} = " Urlaubsschaltung - Sie erhalten vorübergehend keine Mails mehr.";
$msgtxt{'43.4DE'} = " Sie erhalten nur noch Mails, die nicht größer sind als ";

#-------------------------------
$msgtxt{'44DE'} = "\nFEHLER:\n\tSie haben keine Berechtigung, die Einstellungen anderer zu verändern.\n" . 
		  "\nLösung:\n\tKeine.\;
		 
