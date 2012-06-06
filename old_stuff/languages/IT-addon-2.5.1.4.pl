push (@languages, 'it');

##################################################################
###   it = Italiano
###
###   Added by Federico Bianchi <f.bianchi@humnet.unipi.it>

#-------------------------------
$msgtxt{'1IT'} = <<_EOF_ ;

Questo e` il gestore di liste postali Minimalist.

I comandi possono essere sia nell'oggetto (un solo comando alla volta) che nel
corpo del messaggio (uno o piu` comandi, ma uno solo per linea). L'elaborazione
**batched** inizia quando il campo oggetto e` vuoto o contiene il comando 'body'
(senza apici) e si blocca o quando arrivano i comandi 'stop' od 'exit' (sempre
senza apici) o in presenza di 10 comandi non corretti.

I comandi accettati sono:

subscribe <lista> [<indirizzo di posta>] :
   Iscrive l'utente alla <lista>. Se <lista> contiene il suffisso '-writers',
   l'utente potra` inviarvi messaggi senza riceverne.

unsubscribe <lista> [<indirizzo di posta>] :
   Rimuovi l'utente dalla <lista>. Puo` essere usato con il suffisso '-writers'
   secondo quanto detto sopra.

auth <codice> :
    Conferma il comando precedente, usato in alcuni casi come risposta alla richiesta
    di iscrizione. Questo comando deve essere usato esclusivamente in risposta ad una
    richiesta da Minimalist.

suspend <lista> :
    Sospendi la ricezione dei messaggi sulla <lista> specificata

resume <lista> :
    Riattiva la ricezione dei messaggi dalla <lista>

maxsize <lista> <dimensione> :
    Specifica la dimensione massima (in byte) dei messaggi che l'utente vuol ricevere

which [<indirizzo di posta>] :
    Ritorna la lista delle liste cui l'utente e` iscritto

info [<lista>] :
    Richiede informazioni su tutte le liste o solo su <lista>

who <lista> :
    Solo per gli amministratori; richiedi la lista di tutti gli utenti iscritti alla <lista>

mode <lista> <indirizzo di posta> <modalita`> :
    Imposta cio` che l'utente definito da <indirizzo di posta> puo` fare sulla <lista>.
    E` consentito solo agli amministratori. <mode> puo` essere (senza apici):
    * 'reader' - l'utente ha accesso di sola lettura (non puo` inviare messaggi)
       alla <lista>
    * 'writer' - l'utente puo` inviare messaggi alla <lista>, eventualmente aggirando
      altre restrizioni
    * 'usual' - ripristina le impostazioni predefinite, cancellando gli effetti dei due
      comandi precedenti
    * 'suspend' - sospendi l'iscrizione dell'utente
    * 'resume' - riattiva l'iscrizione dell'utente precedentemente sospeso
    * 'maxsize <dimensione>' - definisci la dimensione massima (in byte) dei messaggi che
                               possono essere ricevuti dall'utente
    * 'reset' - ripristina tutte le impostazioni predefinite per l'utente specificato

help :
    Questo messaggio

help :
    This message

Nota che i comandi con <indirizzo di posta>, 'who' e 'mode' possono essere usati solo dagli
amministratori, che possono essere identificati attraverso l'indirizzo di provenienza o
usando una password (locale o globale). In caso contrario, tali comandi saranno ignorati. La
password deve essere presente come frammento nell'intestazione del messaggio, con il formato:

{pwd: list_password}

Ad esempio

To: MML Discussion {pwd: password1235} <mml-general\@kiev.sovam.com>

Naturalmente questo frammento verra` rimosso dall'intestazione prima di inviare il
messaggio agli iscritti
_EOF_

#-------------------------------
$msgtxt{'2it'} = "ERRORE:\n\tTu";
$msgtxt{'3it'} = "non sei iscritto a questa lista.\n\n".
		 "SOLUZIONE:\n\tDevi inviare un messaggio";
$msgtxt{'4it'} = "con un oggetto \n\t'help' (senza apici!) per informazioni su come iscriverti.\n\n".
		 "Segue il tuo messaggio:";
#-------------------------------
$msgtxt{'5it'} = "ERRORE:\n\tTu";
$msgtxt{'5.1it'} = "non puoi mandare messaggi su questa lista.\n\nSegue il tuo messaggio:";
#-------------------------------
$msgtxt{'6it'} = "ERRORE:\n\tLa dimensione del messaggio e` maggiore del massimo consentito (";
$msgtxt{'7it'} = "byte).\n\nSOLUZIONE:\n\tManda un messaggio piu` piccolo o dividilo in piu` parti\n\n".
		 "===========================================================================\n".
		 "Segue l'intestazione del tuo messaggio:";
#-------------------------------
$msgtxt{'8it'} = "\nERRORE:\n\tNon c'e` una richiesta di autentica con questo codice: ";
$msgtxt{'9it'} = "\n\nSOLUZIONE:\n\tRispedisci la tua richiesta a Minimalist.\n";

#-------------------------------
$msgtxt{'10it'} = "\nERRORE:\n\tNon sei autorizzato ad accedere all'iscrizione di altri utenti.\n".
		  "\nSOLUZIONE:\n\tNessuna.";
#-------------------------------
$msgtxt{'11it'} = "\nIscrizione attuale dell'utente ";
#-------------------------------
$msgtxt{'12it'} = "\nERRORE:\n\tQuesta lista non esiste qui\n\n";
$msgtxt{'13it'} = "SOLUZIONE:\n\tInvia un messaggio con oggetto";
$msgtxt{'14it'} = "\n\t 'info' (niente apici) per una lista delle liste di posta disponibili.\n";
#-------------------------------
$msgtxt{'15it'} = "\nERRORE:\n\tNon puoi iscrivere altri utenti.\n".
		  "\nSOLUZIONE:\n\tNessuna.";
#-------------------------------
$msgtxt{'16it'} = "\nERRORE:\n\tSpiacente. Non sei ammesso a questa lista. \n".
		  "\nSOLUZIONE:\n\tSe hai dei dubbi, segnala la cosa a ";
#-------------------------------
$msgtxt{'17it'} = "\nERRORE:\n\tSpiacente. Questa lista e` obbligatoria per te.\n".
		  "\nSOLUZIONE:\n\tSe hai dei dubbi, segnala la cosa a ";
#-------------------------------
$msgtxt{'18it'} = "La tua richiesta";
$msgtxt{'19it'} = "dev'essere autenticata. Per far cio', invia un'altra richiesta a";
$msgtxt{'20it'} = "(o premi semplicemente 'Rispondi' nel tuo programma di posta)\ncon il seguente oggetto:";
$msgtxt{'21it'} = "Questa richiesta di autentica e` valida per le prossime ";
$msgtxt{'22it'} = "ore a partire da adesso e poi\nsara` eliminata.\n";
#-------------------------------
$msgtxt{'23it'} = "\nQui c'e` l'informazione disponibile su";
#-------------------------------
$msgtxt{'24it'} = "\nQueste sono le liste di posta disponibili presso";
#-------------------------------
$msgtxt{'25it'} = "\nUtenti, iscritti a";
$msgtxt{'25.1it'} = "\nTotale: ";
#-------------------------------
$msgtxt{'26it'} = "\nERRORE:\n\tNon ti e` permesso di avere la lista degli iscritti.";
#-------------------------------
$msgtxt{'27.0it'} = "Errore di sintassi o istruzione sconosciuta";
$msgtxt{'27it'} = "\nERRORE:\n\t".$msgtxt{'27.0it'}.".\n\nSOLUZIONE:\n\n".$msgtxt{'1en'};
#-------------------------------
$msgtxt{'28it'} = "In fede, il Minimalist";
#-------------------------------
$msgtxt{'29it'} = "Sei gia` iscritto a";
#-------------------------------
$msgtxt{'30it'} = "Ci sono gia` troppi iscritti (";
#-------------------------------
$msgtxt{'31it'} = "Ti sei iscritto a ";
$msgtxt{'32it'} = "con successo.\n\nNota bene quanto segue:\n";
#-------------------------------
$msgtxt{'33it'} = "La tua iscrizione non e` stata accettata";
$msgtxt{'34it'} = "in quanto";
$msgtxt{'35it'} = "Se hai commenti o domande da fare puoi segnlare la cosa agli amministratori della lista";
#-------------------------------
$msgtxt{'36it'} = "\nL'utente ";
$msgtxt{'37it'} = " Si e` rimosso dalla lista con successo.\n";
#-------------------------------
$msgtxt{'38it'} = "\nErrore interno nell'elaborare la tua richiesta; il problema e` stato segnalato\n\tall'amministratore.".
		  "\nPer la cronaca, lo status dell'utente ";
$msgtxt{'38.1it'} = " non e` cambiato ";
#-------------------------------
$msgtxt{'39it'} = " non e` iscritto a questa lista.\n";
#-------------------------------
$msgtxt{'40it'} = "\nCaro";
#-------------------------------
$msgtxt{'41it'} = "\nImpostazioni per l'utente ";
$msgtxt{'42it'} = " sulla lista ";
$msgtxt{'43it'} = " non vi sono impostazioni specifiche";
$msgtxt{'43.1it'} = " si possono inviare messaggi";
$msgtxt{'43.2it'} = " non si possono inviare messaggi";
$msgtxt{'43.3it'} = " iscrizione sospesa";
$msgtxt{'43.4it'} = " la massima dimensione dei messaggi e` ";
#-------------------------------
$msgtxt{'44it'} = "\nERRORE:\n\tNon ti e` permesso di cambiare le impostazioni altrui.\n".
		  "\nSOLUZIONE:\n\tNessuna.";

