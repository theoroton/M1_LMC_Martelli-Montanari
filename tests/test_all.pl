%Prédicats d'affichage
echo(T) :- echo_on, !, write(T).
echo(_).
echoNL(T) :- echo(T), nl.
echoSEP() :- nl, echoNL("====================="), nl.

/*
 * Prédicat pour lancer tous les tests de tous les prédicats.
 * Si on arrive à FIN, les tests sont valides.
 */
lancerTests() :-
    set_echo,
    echoNL("DEBUT DES TESTS :"),

    echoSEP(),
    lancerTest_Regle,
    echoSEP(),
    lancerTest_Occur_Check,
    echoSEP(),
    lancerTest_Reduit,
    echoSEP(),
    lancerTest_Unifie,
    echoSEP(),

    echoNL("FIN DES TESTS").
