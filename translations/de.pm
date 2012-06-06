package Translation::de;
use strict;
use parent 'Locale::Maketext';

sub new () {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->{encoding} = 'iso-8859-1';
  bless ($self, $class);
  return $self;
}

our %Lexicon = (
  _AUTO => 1,
  _USAGE => '_USAGE',

  'ERROR:' => 'FEHLER:',
  'SOLUTION:' => 'LÖSUNG:',

  'Bad syntax or unknown instruction.' =>
  'Syntaxfehler oder unbekannter Befehl.',

  'Dear [_1],' =>
  'Hallo [_1]',

  'Sincerely, the Minimalist' =>
  "Mit freundlichen Grüßen,\nDer Minimalist",

  'You([_1]) are not subscribed to this list([_2]).' =>
  'Sie([_1]) sind für diese Mailingliste([_2]) nicht angemeldet.',

  "Send a message to [_1] with a subject of 'help' (no quotes) for information about howto subscribe.",
  "Für weitere Informationen, wie Sie sich anmelden können, senden Sie eine Email mit dem Betreff 'help' (ohne Anführungszeichen) an [_1].",

  'Your message follows:' =>
  'Ihre Nachricht folgt:',

  'You([_1]) are not allowed to write to this list.' =>
  'Sie haben keine Berechtigung, an diese Liste zu schreiben.',

  'Message size is larger than maximum allowed ([_1] bytes).' =>
  'Die Mail ist größer als die Maximalgröße von [_1] bytes).',

  'Either send a smaller message or split your message into multiple smaller ones.' =>
  'Senden Sie entweder eine kleinere Mail, oder teilen Sie Ihre Nachricht auf mehrere kleinere Mails auf.',

  'Your message header follows:' =>
  'Die Header-Zeilen Ihrer Email folgen:',

  'Internal error while processing your request; report sent to administrator.' =>
  'Ein internen Fehlen ist beim verarbeiten Ihrer Anfrage aufgetreten. Ein Fehlerbericht wurde an den Administrator geschickt.',

  'Please note that subscription status for [_1] on [_2] did not change.' =>
  'Beachten Sie, dass der Anmeldungsstatus von [_1] auf der Mailingliste [_2] sich nicht verändert hat.',

  'There is no authentication request with such code ([_1]) or the requst is invalid.' =>
  'Es gibt keine Authentifizierungsanfrage mit diesem Code([_1]), oder die Anfrage ist ungültig.',

  'Resend your request to Minimalist.' =>
  'Senden Sie Ihre ursprüngliche Anfrage nochmals.',

  'You are not allowed to get subscriptions of other users.' =>
  'Es ist Ihnen nicht erlaubt, den Anmeldungsstatus anderer Benutzer zu erfragen.',

  'Current subscriptions of [_1]:' =>
  'Aktueller Anmeldungsstatus von [_1]:',


  'There is no list ([_1]) here.' =>
  'Es gibt hier keine Mailingliste [_1].',

  "Send a message to [_1] with a subject of 'info' (no quotes) for a list of available mailing lists." =>
  "Für eine Liste der verfügbaren Mailinglisten, senden Sie eine Email mit dem Betreff 'info' (ohne Anführungszeichen) an [_1].",

  'Description of list [_1]:' =>
  'Beschreibung der Mailingliste [_1]:',

  'No description available.' =>
  'Keine Beschreibung verfügbar.',

  '[*,_1,user is,users are,No user is] subscribed to [_2]:' =>
  '[*,_1,Benutzer ist,Benutzer sind,Kein Benutzer ist] bei der Mailingliste [_2] angemeldet:',

  'You are not allowed to get a listing of subscribed users.' =>
  'Es ist Ihnen nicht erlaubt, die angemeldeten Benutzer zu erfragen',

  'Sorry, this list is closed for you.' =>
  'Es tut uns leid, aber diese Liste ist für Sie geschlossen.',

  'Sorry, this list is mandatory for you.' =>
  'Es tut uns leid, aber diese Liste ist für Sie verpflichtend.',

  'Please send any comments or questions to [_1].' =>
  'Bitte senden Sie Fragen oder Anmerkungen an [_1].',

  "You aren't allowed to subscribe other people." =>
  'Es ist Ihnen nicht erlaubt, andere Benutzer anzumelden.',

  'You are not allowed to change settings of other people.' =>
  'Es ist Ihnen nicht erlaubt, die Einstellungen anderer Benutzer zu verändern.',

  'you are already subscribed to [_1].' =>
  'Sie sind bereits bei der Mailingliste [_1] angemeldet.',

  'there are already the maximum number of [*,_1,subscriber] subscribed to [_2].' =>
  'Es ist bereits die maximal zulässige Zahl von [*,_1,Benutzer,Benutzern] an der Mailingliste [_2] angemeldet.',

  'You have been subscribed to [_1]' =>
  'Sie wurden zu [_1] angemeldet',

  'You have been unsubscribed from [_1]' =>
  'Sie wurden von [_1] abgemeldet',

  'you have subscribed to [_1] successfully.' =>
  'Sie haben sich erfolgreich bei der Mailingliste [_1] angemeldet.',

  'Description of the list:' =>
  'Beschreibing der Mailingliste:',

  'you have not been subscribed to [_1] due to the following reason:' =>
  'Sie wurden aus folgenden Gründen nicht an der Mailingliste [_1] angemeldet.',

  'User [_1] has been unsubscribed sucessfully from [_2].' =>
  'Der Benutzer [_1] wurde erfolgreich von [_2] abgemeldet.',

  'User [_1] is not a registered member of list [_2].' =>
  'Der Benutzer [_1] ist nicht an der Mailingliste [_2] angemeldet.',


  'posts are allowed' => 'Beiträge sind erlaubt',
  'posts are not allowed' => 'Beiträge sind nicht erlaubt',
  'subscription suspended' => 'Anmeldung pausiert',
  'maximum message size is [*,_1,byte]' =>
  'Maximale Emailgröße beträgt [*,_1,byte]',
  'there are no specific settings' => 'Keine besonderen Einstellungen',

  'Settings for user [_1] on list [_2]:' =>
  'Einstellungen für Benutzer [_1] auf der Mailingliste [_2]:',

  'Please note that settings for [_1] on [_2] did not change.' =>
  'Beachten Sie, dass die Einstellungen von [_1] auf der Mailingliste [_2] sich nicht verändert haben.',

  'Settings changed' =>
  'Einstellungen geändert',

  "Your request '[_1]' must be authenticated. To accomplish this, send another request to [_2] with the following subject:" =>
  "Ihre Anfrage '[_1]' muss authentifiziert werden. Dazu senden Sie bitte eine weitere Anfrage mit dem folgenden Betreff an [_2]:",

  'Or simply use the reply function of your mail reader.' =>
  'Oder verwenden Sie einfach die Antworten Funktion Ihres Mailprogramms.',

  'This authentication request is valid for the next [*,_1,hour] from now on and then will be discarded.' =>
  'Diese Authentifizierungsanfrage ist für die nächsten [*,_1,Stunde,Stunden] gültig. Danach wird sie verworfen.',
);

1;
