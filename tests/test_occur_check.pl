%Prédicats d'affichage
echo(T) :- echo_on, !, write(T).
echo(_).
echoNL(T) :- echo(T), nl.

/*
 * Prédicat pour lancer tous les tests.
 * On exécute le prédicat occur_check(V,T) avec une variable
 * V et un terme composé T, et on regarde si le résultat
 * correspond à ce qu'on attends.
 * Si on arrive à FIN, les tests sont valides.
 */
lancerTest_Occur_Check() :-
    set_echo,
    echoNL("TEST PREDICAT OCCUR CHECK :"), nl,

    echoNL("X ?= f(X)"),
    occur_check(X,f(X)),
    echoNL("true : OK"), nl,

    echoNL("X ?= f(Y)"),
    not(occur_check(X,f(Y))),
    echoNL("false : OK"), nl,

    echoNL("X ?= f(g(X,Y))"),
    occur_check(X,f(g(X,Y))),
    echoNL("true : OK"), nl,

    echoNL("X ?= f(g(Y,Z))"),
    not(occur_check(X,f(g(Y,Z)))),
    echoNL("false : OK"), nl,

    echoNL("X ?= f(g(Y,h(Z,a,j(X))))"),
    occur_check(X,f(g(Y,h(Z,a,j(X))))),
    echoNL("true : OK"), nl,

    echoNL("X ?= f(g(Y,h(Z,a,j(Z))))"),
    not(occur_check(X,f(g(Y,h(Z,a,j(Z)))))),
    echoNL("false : OK"), nl,

    echoNL("FIN TEST PREDICAT OCCUR CHECK"), !.
