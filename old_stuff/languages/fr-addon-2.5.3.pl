
push (@languages, 'fr');


##################################################################
###   fr = Français

#-------------------------------
$msgtxt{'1fr'} = <<_EOF_ ;
Ceci est un message du gestionnaire de liste de diffusion Minimalist.

Les commandes peuvent être envoyées dans le sujet de votre message
(une commande par message) ou dans le corps du message (une ou plusieurs
commandes par message, une commande par ligne).
L'execution de commandes batch se fait lorsque le sujet est vide ou
contient la commande 'body' (sans les guillemets) et s'arrete lorsque
la commande 'stop' ou 'exit' est précisée, ou après 10 commandes
incorrectes succéssives.

Liste des commandes diponibles:

subscribe <list> [<email>] :
    S'abonner à la liste <list>. Si <list> est suivi de '-writers', 
    l'utilisateur pourra écrire à cette liste, mais pas reçevoir de
    messages. <email> spécifie une adresse electronique différente
    de celle utilisée pour envoyer le message.

unsubscribe <list> [<email>] :
    Se désabonner de la liste <list>. Peut être suivi de '-writers'
    (voir la description de subscribe). <email> spécifie l'adresse
    electronique associée à l'abonnement (l'adresse de l'utilisateur
    par défaut).

auth <code> :
    Commande de confirmation, utilisée en réponse à une demande
    d'abonnement dans certains cas.
    Cette commande ne peut être utilisée qu'en réponse à une requête
    de Minimalist.

mode <list> <email> <mode> :
    Définir un mode pour un utilisateur d'une liste. Cette commande
    est réservée aux administrateurs. Les différents modes sont:
      * 'reader' - l'utilisateur dispose d'un accès en lecture seule
      * 'writer' - l'utilisateur peut poster des messages
      * 'usual' - utilise le mode par défaut de la liste
      * 'suspend' - désactive l'abonnement
      * 'resume' - réactive l'abonnement
      * 'maxsize <size>' - fixe la taille maximale (en octets) des
                           messages que l'utilisateur peut reçevoir
      * 'reset' - réinitialise la configuration de l'utilisateur

suspend <list> :
    Ne plus reçevoir de messages de la liste <list>

resume <list> :
    Reçevoir à nouveau les messages de la liste <list>

maxsize <list> <size> :
    Fixe la taille maximale (en octets) des messages que l'on souhaite
    reçevoir de la liste <list>

which [<email>] :
    Retourne la liste des abonnement de l'utilisateur

info [<list>] :
    Retourne les informations d'une/des liste(s)

who <list> :
    Retourne la liste des utilisateurs abonnés à la liste <list>.
    Cette commande est réservée aux administrateurs.

help :
    Ce message

Note, les commandes réservées aux administrateurs (utilisateurs identifiés
par leur adresse electronique, et authentifiés par mot de passe) sont ignorées
pour les autres utilisateurs.
Le mot de passe doit être précisé dans le sujet du message sous la forme:

{pwd: list_password}

Exemple:

To: MML Discussion {pwd: password1235} <mml-general\@kiev.sovam.com>

Le mot de passe sera ensuite supprimé du sujet avant d'être envoyé par
Minimalist aux abonnés.
_EOF_

#-------------------------------
$msgtxt{'2fr'} = "ERREUR:\n\tVous";
$msgtxt{'3fr'} = "n'êtes pas abonné à cette liste.\n\n".
		 "SOLUTION:\n\tEnvoyez un message à";
$msgtxt{'4fr'} = "avec le sujet\n\t'help' (sans guillemets) pour informations.\n\n".
		 "Votre message:";
#-------------------------------
$msgtxt{'5fr'} = "ERREUR:\n\tVous";
$msgtxt{'5.1fr'} = "n'êtes pas authorisé à poster sur cette liste.\n\nVotre message:";
#-------------------------------
$msgtxt{'6fr'} = "ERREUR:\n\tTaille du message trop grande ( max ";
$msgtxt{'7fr'} = "octets ).\n\nSOLUTION:\n\tEnvoyez un plus petit message ou découpez votre message en\n\tplusieurs petits messages.\n\n".
		 "===========================================================================\n".
		 "Votre message:";
#-------------------------------
$msgtxt{'8fr'} = "\nERREUR:\n\tIl n'y à pas d'authentification avec ce code: ";
$msgtxt{'9fr'} = "\n\nSOLUTION:\n\tRenvoyés votre requête à Minimalist.\n";

#-------------------------------
$msgtxt{'10fr'} = "\nERREUR:\n\tVous n'êtes pas authorisé à reçevoir les abonnements des autres utilisateurs.\n".
		  "\nSOLUTION:\n\tAucune.";
#-------------------------------
$msgtxt{'11fr'} = "\nAbonnements en cours pour l'utilisateur ";
#-------------------------------
$msgtxt{'12fr'} = "\nERREUR:\n\tCette liste n'existe pas";
$msgtxt{'13fr'} = "here.\n\nSOLUTION:\n\tEnvoyez un message à";
$msgtxt{'14fr'} = "avec le sujet\n\t'info' (sans guillements).\n";
#-------------------------------
$msgtxt{'15fr'} = "\nERREUR:\n\tVous n'êtes pas authorisé à abonner d'autres personnes.\n".
		  "\nSOLUTION:\n\tAucune.";
#-------------------------------
$msgtxt{'16fr'} = "\nERREUR:\n\tDésolé, cette liste est fermée pour vous.\n".
		  "\nSOLUTION:\n\tUne erreur? Faites une réclamation à ";
#-------------------------------
$msgtxt{'17fr'} = "\nERREUR:\n\tDésolé, cette liste est obligatoire pour vous.\n".
		  "\nSOLUTION:\n\tUne erreur? Faites une réclamation à ";
#-------------------------------
$msgtxt{'18fr'} = "Votre requête";
$msgtxt{'19fr'} = "Vous devez être authentifié. Envoyez une nouvelle requête à";
$msgtxt{'20fr'} = "(ou répondez à ce courrier)\navec le sujet suivant:";
$msgtxt{'21fr'} = "Votre authentification est valide pour quelques heures\n";
$msgtxt{'22fr'} = "et sera ensuite annulée.\n";
#-------------------------------
$msgtxt{'23fr'} = "\nVoici les informations disponible sur";
#-------------------------------
$msgtxt{'24fr'} = "\nVoici la liste des diffusions disponibles sur";
#-------------------------------
$msgtxt{'25fr'} = "\nUtilisateur abonnés à";
$msgtxt{'25.1fr'} = "\nTotale: ";
#-------------------------------
$msgtxt{'26fr'} = "\nERREUR:\n\tVous n'êtes pas authorisé à reçevoir cette liste.";
#-------------------------------
$msgtxt{'27.0fr'} = "Erreur de syntaxe ou commande inconnue";
$msgtxt{'27fr'} = "\nERREUR:\n\t".$msgtxt{'27.0en'}.".\n\nSOLUTION:\n\n".$msgtxt{'1en'};
#-------------------------------
$msgtxt{'28fr'} = "Cordialement, le gestionnaire Minimalist.";
#-------------------------------
$msgtxt{'29fr'} = "Vous êtes déjà abonné à";
#-------------------------------
$msgtxt{'30fr'} = "Le nombre maximum d'abonnés est atteint (";
#-------------------------------
$msgtxt{'31fr'} = "Vous êtes abonné à";
$msgtxt{'32fr'} = "avec succès.\n\nVeuillez noter ceci:\n";
#-------------------------------
$msgtxt{'33fr'} = "Vous n'êtes pas abonné à";
$msgtxt{'34fr'} = "pour la raison suivante";
$msgtxt{'35fr'} = "Pour tout commentaire ou question, veuillez écrire à\nl'administrateur";
#-------------------------------
$msgtxt{'36fr'} = "\nUtilisateur ";
$msgtxt{'37fr'} = " s'est désabonné avec succès.\n";
#-------------------------------
$msgtxt{'38fr'} = "\nErreur interne; l'administrateur à été informé.".
		  "\nVeuillez noter que l'abonnement pour ";
$msgtxt{'38.1fr'} = " est inchangé sur ";
#-------------------------------
$msgtxt{'39fr'} = " n'est pas enregistré sur cette liste.\n";
#-------------------------------
$msgtxt{'40fr'} = "\nBonjour";
#-------------------------------
$msgtxt{'41fr'} = "\nParamètres pour l'utilisateur ";
$msgtxt{'42fr'} = " sur la liste ";
$msgtxt{'43fr'} = " il n'y à pas de paramètres particuliers";
$msgtxt{'43.1fr'} = " envoi authorisé";
$msgtxt{'43.2fr'} = " envoi non authorisé";
$msgtxt{'43.3fr'} = " abonnement désactivé";
$msgtxt{'43.4fr'} = " taille maximum des messages de ";
#-------------------------------
$msgtxt{'44fr'} = "\nERREUR:\n\tVous n'êtes pas authorisé à changer ces paramètres.\n".
		  "\nSOLUTION:\n\tAucune.";


