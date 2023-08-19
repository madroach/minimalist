# French translation for the minimalist mailing list manager
#
# Copyright (c) 2017, Floréal Toumikian <floreal@nimukaito.net>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

package Translation::fr;
use strict;
use parent 'Locale::Maketext';

sub new () {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->{encoding} = 'utf-8';
  bless ($self, $class);
  return $self;
}

our %Lexicon = (
  _AUTO => 1,
  _USAGE => '_USAGE',

  'ERROR:' => 'ERREUR:',
  'SOLUTION:' => 'SOLUTION:',

  'Bad syntax or unknown instruction.' =>
  'Mauvaise syntaxe ou instruction inconue.',

  'Dear [_1],' =>
  'Cher [_1]',

  'Sincerely, the Minimalist' =>
  "Sincèrement, Minimalist",

  'You([_1]) are not subscribed to this list([_2]).' =>
  "Vous([_1]) n'êtes pas inscrit-e à cette liste de diffusion([_2]).",

  "Send a message to [_1] with a subject of 'help' (no quotes) for information about howto subscribe.",
  "Envoyez un message à [_1] avec pour sujet « help » (sans guillement) pour obtenir de l'aide pour vous inscrire.",

  'Your message follows:' =>
  'Votre message est:',

  'You([_1]) are not allowed to write to this list.' =>
  "Vous([_1]) n'êtes pas auterisé·e à écrire à cette list.",

  'Message size is larger than maximum allowed ([_1] bytes).' =>
  'La taille du message excède le maximum autorisé ([_1] octets).',

  'Either send a smaller message or split your message into multiple smaller ones.' =>
  'Envoyez en message plus court ou bien séparez le en plusieurs messages plus petits.',

  'Your message header follows:' =>
  'Les entêtes de votre message sont:',

  'Internal error while processing your request; report sent to administrator.' =>
  "Une erreur interne s'est produite pendant le traîtement de votre requête; un rapport est envoyé à l'administrateur.",

  'Please note that subscription status for [_1] on [_2] did not change.' =>
  "Veuillez noter que l'état de votre souscription pour  [_1] sur la liste [_2] n'a pas été modifié.",

  'There is no authentication request with such code ([_1]) or the requst is invalid.' =>
  "Il n'y a pas de requête d'authentification avec ce code ([_1]), ou la requête est invalide.",

  'Resend your request to Minimalist.' =>
  'Veuillez renvoyer votre requête à Minimalist.',

  'You are not allowed to get subscriptions of other users.' =>
  "Vous n'avez pas l'autorisation d'accéder aux inscriptions d'autres utilisateurs.",

  'Current subscriptions of [_1]:' =>
  'Inscription en cours de [_1]:',

  'There is no list ([_1]) here.' =>
  "Il n'y a pas de liste [_1] ici.",

  "Send a message to [_1] with a subject of 'info' (no quotes) for a list of available mailing lists." =>
  "Envoyez un message à [_1] avec pour sujet « help » (sans guillemets) pour connaître les listes de diffusion disponibles.",

  'Description of list [_1]:' =>
  'Desciption de la liste [_1]:',

  'No description available.' =>
  'Pas de description disponible.',

  '[*,_1,user is,users are,No user is] subscribed to [_2]:' =>
  "[*,_1,utilisateur-trice est inscrit·e,utilisateur·trice·s sont inscrit·e·s,Pesonne n'est inscrit·e] à [_2]:",

  'You are not allowed to get a listing of subscribed users.' =>
  "Vous n'avez pas l'autorisation d'obtenir la liste des utilisateurs inscrits",

  'Sorry, this list is closed for you.' =>
  'Désolé, cette liste vous est fermée.',

  'Sorry, this list is mandatory for you.' =>
  'Désolé, cette liste vous est obligatoire.',

  'Please send any comments or questions to [_1].' =>
  "Prière d'envoyer vos questions et commentaires à [_1].",

  "You aren't allowed to subscribe other people." =>
  "Vous n'avez pas l'autorisation d'inscrire d'autres peresonnes.",

  'You are not allowed to change settings of other people.' =>
  "Vous n'avez pas l'autorisation de changer les paramètres d'autres personnes.",

  'you are already subscribed to [_1].' =>
  'vous êtes déjà inscrit·e à [_1].',

  'there are already the maximum number of [*,_1,subscriber] subscribed to [_2].' =>
  "Le nombre maximum de [*,_1,utilisateur·trice inscrit·e,utilisateur·trice·s inscrit·e·s] à la liste [_2] a été ateint",

  'You have been subscribed to [_1]' =>
  'Vous avez été inscrit·e à [_1]',

  'You have been unsubscribed from [_1]' =>
  'Vous avez écé désincrit·e de [_1]',

  'you have subscribed to [_1] successfully.' =>
  'Vous êtes correctement inscrit·e à la liste [_1].',

  'Description of the list:' =>
  'Description de la liste:',

  'you have not been subscribed to [_1] due to the following reason:' =>
  "Vous n'avez pas été inscrit·e à la listte [_1] pour les raisons suivantes:",

  'User [_1] has been unsubscribed sucessfully from [_2].' =>
  "L'utilisateur·trice [_1] a été correctement désinscrit·e de [_2].",

  'User [_1] is not a registered member of list [_2].' =>
  "L'utilisateur·trice [_1] n'est pas enregistré·e comme membre à la liste [_2].",


  'posts are allowed' => 'Messages autorisés',
  'posts are not allowed' => 'Messages non autorisés',
  'subscription suspended' => 'Inscription suspendue',
  'maximum message size is [*,_1,byte]' =>
  'La taille maximale du message est [*,_1,octet,octets]',
  'there are no specific settings' => "Il n'y a pas de paramètre spécifique",

  'Settings for user [_1] on list [_2]:' =>
  "Paramètre pour l'utilisateur-trice [_1] sur la liste [_2]:",

  'Please note that settings for [_1] on [_2] did not change.' =>
  "Veillez noter que les paramètres pour [_1] de la liste [_2] n'ont pas été modifiés.",

  'Settings changed' =>
  'Paramètre modifié',

  "Your request '[_1]' must be authenticated. To accomplish this, send another request to [_2] with the following subject:" =>
  "Votre requête '[_1]' doit être authentifie. Veuillez envoyer une nouvelle requête à [_2] avec le sujet suivant:",

  'Or simply use the reply function of your mail reader.' =>
  'Ou utilisez simplement la fonction « répondre » de votre logiciel de messagerie.',

  'This authentication request is valid for the next [*,_1,hour] from now on and then will be discarded.' =>
  "Cette requête d'authentification est valide pour les prochaines [*,_1,heure,heures] à partir de maintenant, puis sera à nouveau invalide",
);

1;
