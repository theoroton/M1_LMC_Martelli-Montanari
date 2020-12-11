%Prédicats d'affichage
echo(T) :- echo_on, !, write(T).
echo(_).
echoNL(T) :- echo(T), nl.

/*
 * Prédicat pour lancer tous les tests sur unifie.
 * On exécute le prédicat unifie(P) avec un système P.
 * On vérifie si le prédicat nous donne la bonne réponse
 * pour un système P donnée.
 * Si on arrive à FIN, les tests sont valides.
 */
lancerTest_Unifie() :-
    set_echo,
    echoNL("TEST PREDICAT UNIFIE :"), nl,

    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7,

    echoNL("FIN TEST PREDICAT UNIFIE").


test1() :-
    echoNL("[f(X,Y) ?= f(g(Z),h(a)), Z ?= f(Y)]"),
    unifie([f(_X,Y) ?= f(g(Z),h(a)), Z ?= f(Y)], choix_premier),
    echoNL("true : OK"), nl.


test2() :-
    echoNL("[f(X,Y) ?= f(g(Z),h(a)), Z ?= f(X)]"),
    not(unifie([f(X,_Y) ?= f(g(Z),h(a)), Z ?= f(X)], choix_premier)),
    echoNL("false : OK"), nl.


test3() :-
    echoNL("[Z ?= f(Y), f(X,Y) ?= f(g(Z),h(a))]"),
    unifie([Z ?= f(Y), f(_X,Y) ?= f(g(Z),h(a))], choix_premier),
    echoNL("true : OK"), nl.


test4() :-
    echoNL("[Z ?= f(Y), f(X,Y) ?= f(g(Z),h(W)), b ?= W, f(X) ?= f(X)]"),
    unifie([Z ?= f(Y), f(X,Y) ?= f(g(Z),h(W)), b ?= W, f(X) ?= f(X)], choix_premier),
    echoNL("true : OK"), nl.


test5() :-
    echoNL("[Z ?= f(Y), f(X,Y) ?= f(g(Z),h(W)), b ?= W, f(X) ?= f(h(X))]"),
    not(unifie([Z ?= f(Y), f(X,Y) ?= f(g(Z),h(W)), b ?= W, f(X) ?= f(h(X))], choix_premier)),
    echoNL("false : OK"), nl.


test6() :-
    echoNL("[Z ?= f(Y), f(X,Y) ?= f(g(Z),h(W)), f(A,B) = g(X,Y)]"),
    not(unifie([Z ?= f(Y), f(X,Y) ?= f(g(Z),h(_W)), f(_A,_B) = g(X,Y)], choix_premier)),
    echoNL("false : OK"), nl.


test7() :-
    echoNL("[Z ?= f(Y), f(X,Y) ?= f(g(Z),h(W)), b ?= a]"),
    not(unifie([Z ?= f(Y), f(_X,Y) ?= f(g(Z),h(_W)), b ?= a], choix_premier)),
    echoNL("false : OK"), nl.

