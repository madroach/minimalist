push (@languages, 'nl');

##################################################################
###   nl = Dutch
###
###   Added by Andre de Vet

#-------------------------------
$msgtxt{'1nl'} = <<_EOF_ ;
Dit is de Minimalist Mailing List Manager.

Commando's mogen of in het subject van het bericht (een(1) commando per
bericht) of in de body van het bericht (een of meer commando's, een(1)
per regel) staan. Het verwerken van de commando's start als het subject
leeg is of het commando 'body' bevat (zonder quotes), en stopt als het
commando 'stop' of 'exit' (zonder quotes) tegengekomen wordt, of als
er 10 incorrecte commando's verwerkt zijn.

Ondersteunde commando's zijn:

subscribe <list> [<email>] :
    Schrijft de gebruiker in bij <list>. Als <list> het achtervoegsel
    '-writers' bevat kan de gebruiker wel berichten sturen naar de
    lijst, maar ontvangt deze er geen berichten van.    

unsubscribe <list> [<email>] :
    Schrijft de gebruiker uit van <list>. 

auth <code> :
    Bevestigings commando. Wordt alleen gebruikt als reactie op een
    verzoek van Minimalist, en word gebruikt om de inschrijvende 
    partij te authenticeren.

mode <list> <email> <modus> :
    Zet de modus voor een gespecificeerde gebruiker op een specifieke
    lijst. Alleen toegestaan voor de administrator. De modus kan
    zijn (zonder quotes):
      * 'reader' - alleen lezen toegang op de lijst voor de gebruiker;
      * 'writer' - de gebruiker kan ongeacht de status van de lijst
                   berichten plaatsen
      * 'usual' -  herstelt de twee bovengenoemde modi
      * 'suspend' - stop de inschrijving op de lijst
      * 'resume' - herstelt de inschrijving op de lijst
      * 'maxsize <size>' - stelt de maximum grootte (in bytes) van
                           berichten in voor een gebruiker
      * 'reset' - verwijder alle ingestelde modi voor een gebruiker

suspend <list> :
    Stopt het ontvangen van berichten van de aangegeven mailing list

resume <list> :
    Herstelt het ontvangen van berichten van de aangegeven mailing list

maxsize <list> <size> :
    Stelt de maximum grootte (in bytes) in van berichten die een
    gebruiker wil ontvangen.

which [<email>] :
    Stuurt een lijst terug van mailinglists waarop de gebruiker 
    ingeschreven is.

info [<list>] :
    Vraagt informatie aan over de beschikbare mailinglists, of
    specifieke informatie over <list>. 

who <list> :
    Stuurt een lijst van ingeschreven gebruikers van <list> terug.

help :
    Dit bericht.

Let op: Commando's met <email>, 'who' en 'mode' kunnen alleen gebruikt
worden door administrators (deze gebruikers zijn geidentificeerd in het 
'mailfrom' authenticatie schema of hebben een correct wachtwoord - global 
of local - teruggestuurd). Ongeauthenticeerde commando's worden genegeerd.
Het wachtwoord moet op de eerste regel van het body gedeelte van het bericht 
staan, in het volgende formaat:

*password: list_password

Gevolgd door een willekeurig aantal lege regels. De regel wordt natuurlijk
verwijderd voordat het bericht doorgestuurd wordt naar de lijst.
_EOF_

#-------------------------------
$msgtxt{'2nl'} = "FOUT:\n\tJe";
$msgtxt{'3nl'} = "bent niet ingeschreven bij deze lijst.\n\n".
		 "OPLOSSING:\n\tStuur een bericht aan";
$msgtxt{'4nl'} = "met als onderwerp 'help' (geen quotes) voor informatie over hoe je je moet inschrijven.\n\n".
		 "Je oorspronkelijke bericht volgt::";
#-------------------------------
$msgtxt{'5nl'} = "FOUT:\n\tJe";
$msgtxt{'5.1nl'} = "hebt geen toestemming om naar deze lijst te sturen.\n\nJe oorspronkelijke bericht volgt:";
#-------------------------------
$msgtxt{'6nl'} = "FOUT:\n\tJe bericht is groter dan de maximaal toegestane grootte (";
$msgtxt{'7nl'} = "bytes ).\n\nOPLOSSING:\n\tStuur of een kleiner bericht, of deel het bericht op in meerdere\n\t kleine berichten.\n\n".
		 "===========================================================================\n".
		 "De header van je bericht volgt:";
#-------------------------------
$msgtxt{'8nl'} = "\nFOUT:\n\tEr is geen authorisatie verzoek met deze code: ";
$msgtxt{'9nl'} = "\n\nOPLOSSING:\n\tStuur je verzoek aan Minimalist opnieuw.\n";
#-------------------------------
$msgtxt{'10nl'} = "\nFOUT:\n\tHet is niet toegestaan om de inschrijflijst van andere gebruikers op te vragen.\n".
		  "\nOPLOSSING:\n\tGeen.";
#-------------------------------
$msgtxt{'11nl'} = "\nHuidige inschrijvingen voor gebruiker ";
#-------------------------------
$msgtxt{'12nl'} = "\nFOUT:\n\tDe gevraagde lijst bestaat";
$msgtxt{'13nl'} = "niet.\n\nOPLOSSING:\n\tStuur een bericht aan";
$msgtxt{'14nl'} = "met als onderwerp\n\t'info' (geen quotes) voor een overzicht van beschikbare lijsten.\n";
#-------------------------------
$msgtxt{'15nl'} = "\nFOUT:\n\tHet is niet toegestaan anderen in te schrijven.\n".
		  "\nOPLOSSING:\n\tGeen.";
#-------------------------------
$msgtxt{'16nl'} = "\nFOUT:\n\tSorry, dit is een voor jou gesloten lijst.\n".
		  "\nOPLOSSING:\n\tKlopt dit niet? Stuur je klacht aan ";
#-------------------------------
$msgtxt{'17nl'} = "\nFOUT:\n\tSorry, deze lijst is verplicht.\n".
		  "\nOPLOSSING:\n\tKlopt dit niet? Stuur je klacht aan ";
#-------------------------------
$msgtxt{'18nl'} = "Je verzoek";
$msgtxt{'19nl'} = "moet geauthenticeerd worden. Om dit te bereiken kun je opnieuw een bericht sturen aan";
$msgtxt{'20nl'} = "(Je kunt ook gewoon op 'reply' drukken)\nmet het volgende onderwerp:";
$msgtxt{'21nl'} = "Dit authenticatie verzoek is geldig voor de komende";
$msgtxt{'22nl'} = "uren vanaf nu.\nDaarna zal het verwijderd worden.\n";
#-------------------------------
$msgtxt{'23nl'} = "\nHier is de beschikbare informatie over";
#-------------------------------
$msgtxt{'24nl'} = "\nDit zijn de beschikbare mailinglists op";
#-------------------------------
$msgtxt{'25nl'} = "\nGebruikers, ingeschreven op";
$msgtxt{'25.1nl'} = "\nTotaal: ";
#-------------------------------
$msgtxt{'26nl'} = "\nFOUT:\n\tHet is niet toegestaan een lijst op te vragen van ingeschreven gebruikers";
#-------------------------------
$msgtxt{'27nl'} = "\nFOUT:\n\tSyntaxisfout of onbekende instructie.\n\nOPLOSSING:\n\n".$msgtxt{'1nl'};
#-------------------------------
$msgtxt{'28nl'} = "Hoogachtend, de Minimalist";
#-------------------------------
$msgtxt{'29nl'} = "je bent al ingeschreven op";
#-------------------------------
$msgtxt{'30nl'} = "er zijn al het maximum nummer gebruikers ingeschreven (";
#-------------------------------
$msgtxt{'31nl'} = "je bent ingeschreven op";
$msgtxt{'32nl'} = "\n\nNeem alsjeblieft notie van het volgende:\n";
#-------------------------------
$msgtxt{'33nl'} = "je bent niet ingeschreven op";
$msgtxt{'34nl'} = "vanwege de volgende reden";
$msgtxt{'35nl'} = "Als je commentaar, vragen of suggesties hebt stuur deze dan alsjeblieft aan\nde lijst administrator";
#-------------------------------
$msgtxt{'36nl'} = "\nGebruiker ";
$msgtxt{'37nl'} = " is met goed gevolg uitgeschreven.\n";
#-------------------------------
$msgtxt{'38nl'} = "\nInterne fout tijdens het verwerken van je verzoek; Een foutrapport is verstuurd aan de administrator.".
		  "\nLet wel, je inschrijvingsstatus voor ";
$msgtxt{'38.1nl'} = " is niet veranderd op ";
#-------------------------------
$msgtxt{'39nl'} = " is geen geregistreerd lid van deze lijst.\n";
#-------------------------------
$msgtxt{'40nl'} = "\nBeste";
#-------------------------------
$msgtxt{'41nl'} = "\nInstellingen voor gebruiker ";
$msgtxt{'42nl'} = " op lijst ";
$msgtxt{'43nl'} = " er zijn geen specifieke instellingen";
$msgtxt{'43.1nl'} = " posts zijn toegestaan";
$msgtxt{'43.2nl'} = " posts zijn niet toegestaan";
$msgtxt{'43.3nl'} = " inschrijving stopgezet";
$msgtxt{'43.4nl'} = " maximale berichtgrootte is ";
#-------------------------------
$msgtxt{'44nl'} = "\nFOUT:\n\tHet is je niet toegestaan instellingen van andere mensen te wijzigen.\n".
                  "\nOPLOSSING:\n\tGeen.";

