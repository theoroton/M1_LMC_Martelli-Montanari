%Prédicats d'affichage
echo(T) :- echo_on, !, write(T).
echo(_).
echoNL(T) :- echo(T), nl.

/*
 * Prédicat pour lancer tous les tests.
 * On exécute le prédicat règle(E,R) avec une équation E.
 * On vérifie si la règle R trouvé correspond à celle
 * adéquate pour l'équation E.
 */
lancerTest_Regle() :-
    set_echo,
    echoNL("TEST PREDICAT REGLE :"), nl,

    test_rename,
    test_simplify,
    test_expand,
    test_check,
    test_orient,
    test_decompose,
    test_clash,
    test_clean,
    test_fail,

    echoNL("FIN TEST PREDICAT REGLE").


%Test de la règle rename.
test_rename() :-
    echoNL("TEST RENAME :"),

    echoNL("X ?= Y"),
    regle(_X ?= _Y, R),
    R == rename,
    echoNL(R), nl,

    echoNL("W ?= Z"),
    regle(_W ?= _Z, R),
    R == rename,
    echoNL(R), nl, nl.


%Test de la règle simplify.
test_simplify() :-
    echoNL("TEST SIMPLIFY :"),

    echoNL("X ?= a"),
    regle(_X ?= a, R),
    R == simplify,
    echoNL(R), nl,

    echoNL("Y ?= b"),
    regle(_Y ?= b, R),
    R == simplify,
    echoNL(R), nl, nl.


%Test de la règle expand.
test_expand() :-
    echoNL("TEST EXPAND :"),

    echoNL("X ?= f(Y)"),
    regle(X ?= f(Y), R),
    R == expand,
    echoNL(R), nl,

    echoNL("X ?= f(a)"),
    regle(X ?= f(a), R),
    R == expand,
    echoNL(R), nl,

    echoNL("X ?= f(g(Y))"),
    regle(X ?= f(g(Y)), R),
    R == expand,
    echoNL(R), nl,

    echoNL("X ?= f(g(h(j(Y))))"),
    regle(X ?= f(g(h(j(Y)))), R),
    R == expand,
    echoNL(R), nl,

    echoNL("X ?= f(g(h(Z, j(Y,W))))"),
    regle(X ?= f(g(h(_Z, j(Y,_W)))), R),
    R == expand,
    echoNL(R), nl, nl.


%Test de la règle check.
test_check() :-
    echoNL("TEST CHECK :"),

    echoNL("X ?= f(X)"),
    regle(X ?= f(X), R),
    R == check,
    echoNL(R), nl,

    echoNL("X ?= f(Y,X)"),
    regle(X ?= f(Y,X), R),
    R == check,
    echoNL(R), nl,

    echoNL("X ?= f(Y, g(Z,X))"),
    regle(X ?= f(Y, g(Z,X)), R),
    R == check,
    echoNL(R), nl,

    echoNL("X ?= f(Y, g(Z, h(j(X))))"),
    regle(X ?= f(Y, g(Z, h(j(X)))), R),
    R == check,
    echoNL(R), nl, nl.


%Test de la règle orient.
test_orient() :-
    echoNL("TEST ORIENT :"),

    echoNL("a ?= X"),
    regle(a ?= _X, R),
    R == orient,
    echoNL(R), nl,

    echoNL("b ?= Y"),
    regle(b ?= _Y, R),
    R == orient,
    echoNL(R), nl, nl.


%Test de la règle decompose.
test_decompose() :-
    echoNL("TEST DECOMPOSE :"),

    echoNL("f(X) ?= f(Y)"),
    regle(f(X) ?= f(Y), R),
    R == decompose,
    echoNL(R), nl,

    echoNL("f(X,Y) ?= f(a,b)"),
    regle(f(X,Y) ?= f(a,b), R),
    R == decompose,
    echoNL(R), nl,

    echoNL("f(X,Y) ?= f(g(Z), h(b))"),
    regle(f(X,Y) ?= f(g(Z), h(b)), R),
    R == decompose,
    echoNL(R), nl,

    echoNL("f(X,Y,Z) ?= f(g(a), W, h(b))"),
    regle(f(X,Y,Z) ?= f(g(a), _W, h(b)), R),
    R == decompose,
    echoNL(R), nl, nl.


%Test de la règle clash.
test_clash() :-
    echoNL("TEST CLASH :"),

    echoNL("f(X) ?= f(a,b)"),
    regle(f(X) ?= f(a,b), R),
    R == clash,
    echoNL(R), nl,

    echoNL("f(X,Y,Z) ?= f(a,b,c,W)"),
    regle(f(X,Y,Z) ?= f(a,b,c,W), R),
    R == clash,
    echoNL(R), nl,

    echoNL("f(X) ?= g(Y)"),
    regle(f(X) ?= g(Y), R),
    R == clash,
    echoNL(R), nl,

    echoNL("f(X,Y,Z) ?= g(a,b,f(W))"),
    regle(f(X,Y,Z) ?= g(a,b,f(W)), R),
    R == clash,
    echoNL(R), nl, nl.


%test de la règle clean.
test_clean() :-
    echoNL("TEST CLEAN :"),

    echoNL("X ?= X"),
    regle(X ?= X, R),
    R == clean,
    echoNL(R), nl,

    echoNL("a ?= a"),
    regle(a ?= a, R),
    R == clean,
    echoNL(R), nl,

    echoNL("f(Y) ?= f(Y)"),
    regle(f(Y) ?= f(Y), R),
    R == clean,
    echoNL(R), nl,

    echoNL("f(g(h(Z))) ?= f(g(h(Z)))"),
    regle(f(g(h(Z))) ?= f(g(h(Z))), R),
    R == clean,
    echoNL(R), nl, nl.


%Test de la règle fail.
test_fail() :-
    echoNL("TEST FAIL :"),

    echoNL("a ?= b"),
    regle(a ?= b, R),
    R == fail,
    echoNL(R), nl,

    echoNL("b ?= c"),
    regle(b ?= c, R),
    R == fail,
    echoNL(R), nl, nl.




