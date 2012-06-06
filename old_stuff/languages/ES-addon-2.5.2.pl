push (@languages, 'ES');

##################################################################
###   ES = Spanish
###
###   Added by Fernando Sánchez <fer@debian.org>

#-------------------------------
$msgtxt{'1ES'} = <<_EOF_ ;
Este es el Gestor de Listas de Correo Minimalist.

Las instrucciones pueden indicarse en el tema del mensaje (una instrucción
por mensaje) o en el contenido (una o varias instrucciones, una por línea).
Se procesarán las instrucciones del contenido del mensaje si el tema 
está vacío o contiene la instrucción "body" (sin las comillas), y se dejarán
de procesar cuando se encuentre la instrucción "stop" o "exit" (sin
comillas), o se procesen 10 instrucciones incorrectas.

Las instrucciones permitidas son:

subscribe <lista> [<email>] :
    Suscribe el usuario a <lista>. Si <lista> contiene el sufijo
    "-writers", el usuario podrá escribir en la lista, pero no recibir
    mensajes de ella.

unsubscribe <lista> [<email>] :
    Elimina al usuario de la lista <lista>. Se puede utilizar con el sufijo
    "-writers" (ver descripción de la instrucción "subscribe")

auth <código> :
    Instrucción de confirmación, utilizada como respuesta a una petición de
    suscripción en ciertas ocasiones. Esta instrucción no se utiliza de forma
    independiente, sino que debe usarse como respuesta a una petición de
    Minimalist.

mode <lista> <email> <modo> :
    Selecciona el modo para el usuario y lista especificados. Sólo se
    permite el uso de esta instrucción al administrador. El <modo> puede
    ser (sin comillas):
      * "reader" - acceso de sólo lectura para el usuario en esa lista;
      * "writer" - el usuario puede enviar mensajes a la lista sin que importe
                   el estado de ésta
      * "usual" -  limpia cualquiera de los dos modos anteriores
      * "suspend" - suspende la suscripción del usuario
      * "resume" - reactiva una suscripción previamente suspendida
      * "maxsize <tamaño>" - fija el tamaño máximo (en bytes) de los
                             mensajes que el usuario desea recibir
      * "reset" - limpia todos los modos para el usuario especificado

suspend <lista> :
    Dejar de recibir mensajes de la lista de correo especificada

resume <lista> :
    Volver a recibir mensajes de la lista de correo especificada

maxsize <lista> <tamaño> :
    Fija el tamaño máximo (en bytes) de los mensajes que el usuario desea
    recibir

which [<email>] :
    Devuelve una lista de las listas de correo a las que el usuario está
    suscrito

info [<lista>] :
    Pide información sobre las listas existentes o sobre <lista>

who <lista> :
    Devuelve la lista de usuarios suscritos a <lista> 

help :
    Este mensaje

Tenga en cuenta que las instrucciones con <email>, "who" y "mode" sólo
pueden ser utilizadas por administradores (usuarios identificados en el
esquema de autenticación "mailfrom" o que han utilizado una clave correcta
- global o local). En otro caso, la instrucción será ignorada. La clave debe
incluirse dentro de cualquiera de las cabeceras del mensaje, con el siguiente
formato:

{password: clave_de_la_lista}

Por ejemplo:

To: Lista de correo {pwd: password1235} <listacorreo\@dominio.com>


Este fragmento, por supuesto, será eliminado del mensaje antes de
enviarlo a los suscriptores.
_EOF_

#-------------------------------
$msgtxt{'2ES'} = "ERROR:\n\tUsted";
$msgtxt{'3ES'} = "no está suscrito a esta lista.\n\n".
                 "SOLUCION:\n\tEnvíe un mensaje a";
$msgtxt{'4ES'} = "con el tema\n\t\"help\" (sin comillas) para informarse de cómo suscribirse.\n\n".
                 "Este es su mensaje:";
#-------------------------------
$msgtxt{'5ES'} = "ERROR:\n\tUsted";
$msgtxt{'5.1ES'} = "no tiene permiso para escribir en esta lista.\n\nEste es su mensaje:";
#-------------------------------
$msgtxt{'6ES'} = "ERROR:\n\tEl mensaje es más grande que el límite permitido (";
$msgtxt{'7ES'} = "bytes ).\n\nSOLUCION:\n\tEnvíe un mensaje más pequeño o divida su mensaje en\n\totros más pequeños.\n\n".
                 "===========================================================================\n".
                 "Estas son las cabeceras de su mensaje:";
#-------------------------------
$msgtxt{'8ES'} = "\nERROR:\n\tNo hay ninguna petición de autenticación con ese código: ";
$msgtxt{'9ES'} = "\n\nSOLUCION:\n\tVuelva a enviar su petición a Minimalist.\n";

#-------------------------------
$msgtxt{'10ES'} = "\nERROR:\n\tUsted no tiene permiso para conocer la suscripción de otros usuarios.\n".
                  "\nSOLUCION:\n\tNinguna.";
#-------------------------------
$msgtxt{'11ES'} = "\nSuscripción actual del usuario ";
#-------------------------------
$msgtxt{'12ES'} = "\nERROR:\n\tNo existe tal lista";
$msgtxt{'13ES'} = "aquí.\n\nSOLUCION:\n\tEnvíe un mensaje a";
$msgtxt{'14ES'} = "indicando en el tema\n\t\"info\" (sin comillas) para recibir información sobre las listas de correo disponibles.\n";
#-------------------------------
$msgtxt{'15ES'} = "\nERROR:\n\tUsted no puede suscribir a otra gente.\n".
                  "\nSOLUCION:\n\tNinguna.";
#-------------------------------
$msgtxt{'16ES'} = "\nERROR:\n\tLo siento, esta lista está cerrada para usted.\n".
                  "\nSOLUCION:\n\tSi tiene alguna duda, por favor, envíe sus comentarios a ";
#-------------------------------
$msgtxt{'17ES'} = "\nERROR:\n\tLo siento, esta lista es obligatoria para usted.\n".
                  "\nSOLUCION:\n\tSi tiene alguna duda, por favor, envíe sus comentarios a ";
#-------------------------------
$msgtxt{'18ES'} = "Su petición";
$msgtxt{'19ES'} = "debe ser autenticada. Para conseguirlo, envíe otra petición a";
$msgtxt{'20ES'} = "(o pulse \"Contestar\" en su lector de correo)\nindicando como tema:";
$msgtxt{'21ES'} = "Esta petición de autenticación es válida para las siguientes";
$msgtxt{'22ES'} = "horas desde este momento y después\nserá ignorada.\n";
#-------------------------------
$msgtxt{'23ES'} = "\nEsta es la información disponible sobre";
#-------------------------------
$msgtxt{'24ES'} = "\nEstas son las listas de correo disponibles en";
#-------------------------------
$msgtxt{'25ES'} = "\nUsuarios, suscritos a";
$msgtxt{'25.1ES'} = "\nTotal: ";
#-------------------------------
$msgtxt{'26ES'} = "\nERROR:\n\tUsted no puede recibir una lista de los usuarios suscritos.";
#-------------------------------
$msgtxt{'27.0ES'} = "Error de sintaxis o instrucción desconocida.";
$msgtxt{'27ES'} = "\nERROR:\n\t".$msgtxt{'27.0ES'}.".\n\nSOLUCION:\n\n".$msgtxt{'1ES'};
#-------------------------------
$msgtxt{'28ES'} = "Atentamente, Minimalist";
#-------------------------------
$msgtxt{'29ES'} = "usted ya está suscrito a";
#-------------------------------
$msgtxt{'30ES'} = "ya se ha alcanzado el número máximo de suscriptores (";
#-------------------------------
$msgtxt{'31ES'} = "usted se ha suscrito a";
$msgtxt{'32ES'} = "correctamente.\n\nPor favor, tenga en cuenta que:\n";
#-------------------------------
$msgtxt{'33ES'} = "usted no se ha suscrito a";
$msgtxt{'34ES'} = "por el motivo siguiente";
$msgtxt{'35ES'} = "Si tiene algún comentario o sugerencia, por favor,\nenvíelas al administrador de la lista";
#-------------------------------
$msgtxt{'36ES'} = "\nEl usuario ";
$msgtxt{'37ES'} = " ha sido eliminado correctamente de la lista.\n";
#-------------------------------
$msgtxt{'38ES'} = "\nError interno durante el proceso de su petición; se ha avisado al administrador.".
                  "\nPor favor, tenga en cuenta que el estado de la suscripción de ";
$msgtxt{'38.1ES'} = " no ha cambiado en ";
#-------------------------------
$msgtxt{'39ES'} = " no es un miembro registrado de esta lista.\n";
#-------------------------------
$msgtxt{'40ES'} = "\nApreciado";
#-------------------------------
$msgtxt{'41ES'} = "\nOpciones para el usuario ";
$msgtxt{'42ES'} = " en la lista ";
$msgtxt{'43ES'} = " no hay ninguna opción específica";
$msgtxt{'43.1ES'} = " se permite el envío de mensajes";
$msgtxt{'43.2ES'} = " no se permite el envío de mensajes";
$msgtxt{'43.3ES'} = " subscripción suspendida";
$msgtxt{'43.4ES'} = " el tamaño máximo de un mensaje es ";
#-------------------------------
$msgtxt{'44ES'} = "\nERROR:\n\tUsted no puede cambiar las opciones de otra gente.\n".
                  "\nSOLUCION:\n\tNinguna.";

