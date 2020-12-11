%Prédicats d'affichage
echo(T) :- echo_on, !, write(T).
echo(_).
echoNL(T) :- echo(T), nl.

/*
 * Prédicat pour lancer tous les tests sur reduit.
 * On exécute le prédicat reduit(R,E,P,Q) avec une règle R sur
 * une équation E et on transforme le système d'entrée P en
 * système de sortie Q.
 * On vérifie si le système de sortie Q correspond bien au
 * système P après application de la règle R sur l'équation E.
 * Si on arrive à FIN, les tests sont valides.
 */
lancerTest_Reduit() :-
    set_echo,
    echoNL("TEST PREDICAT REDUIT :"), nl,

    test_reduit_rename,
    test_reduit_simplify,
    test_reduit_expand,
    test_reduit_check,
    test_reduit_orient,
    test_reduit_decompose,
    test_reduit_clash,
    test_reduit_clean,
    test_reduit_fail,

    echoNL("FIN TEST PREDICAT REDUIT").


%Test de réduit avec la règle rename.
test_reduit_rename() :-
    echoNL("TEST RENAME :"),

    echoNL("[X ?= Y]"),
    reduit(rename, X1 ?= Y1, [], Q1),
    Q1 == [],
    X1 == Y1,
    echoNL("Résultat : []"), nl,

    echoNL("[X ?= Y, Z ?= X]"),
    reduit(rename, X2 ?= Y2, [Z2 ?= X2], Q2),
    Q2 == [Z2 ?= Y2],
    X2 == Y2,
    echoNL("Résultat [Z ?= Y]"), nl, nl.


%Test de réduit avec la règle simplify.
test_reduit_simplify() :-
    echoNL("TEST SIMPLIFY :"),

    echoNL("[X ?= a]"),
    reduit(simplify, X1 ?= a, [], Q1),
    Q1 == [],
    X1 == a,
    echoNL("Résultat : []"), nl,

    echoNL("[X ?= a, Z ?= X]"),
    reduit(simplify, X2 ?= a, [Z2 ?= X2], Q2),
    Q2 == [Z2 ?= a],
    X2 == a,
    echoNL("Résultat [Z ?= a]"), nl, nl.


%Test de réduit avec la règle expand.
test_reduit_expand() :-
    echoNL("TEST EXPAND :"),

    echoNL("[X ?= f(Y)]"),
    reduit(expand, X1 ?= f(Y1), [], Q1),
    Q1 == [],
    X1 == f(Y1),
    echoNL("Résultat : []"), nl,

    echoNL("[X ?= f(Y), Z ?= X]"),
    reduit(expand, X2 ?= f(Y2), [Z2 ?= X2], Q2),
    Q2 == [Z2 ?= f(Y2)],
    X2 == f(Y2),
    echoNL("Résultat : [Z ?= f(Y)]"), nl,

    echoNL("[X ?= g(Z), Y ?= h(a), Z ?= f(Y)]"),
    reduit(expand, X3 ?= g(Z3), [Y3 ?= h(a), Z3 ?= f(Y3)], Q3),
    Q3 == [Y3 ?= h(a), Z3 ?= f(Y3)],
    X3 == g(Z3),
    echoNL("Résultat : [Y ?= h(a), Z ?= f(Y)]"), nl,

    echoNL("[Y ?= h(a), Z ?= f(Y)]"),
    reduit(expand, Y4 ?= h(a), [Z4 ?= f(Y4)], Q4),
    Q4 == [Z4 ?= f(h(a))],
    Y4 == h(a),
    echoNL("Résultat : [Z ?= f(h(a))]"), nl, nl.


%Test de réduit avec la règle check.
test_reduit_check() :-
    echoNL("TEST CHECK :"),

    echoNL("[X ?= f(X)]"),
    reduit(check, X1 ?= f(X1), [], Q1),
    Q1 == bottom,
    echoNL("Résultat : bottom"), nl,

    echoNL("[X ?= f(h(g(X))), Z ?= a]"),
    reduit(check, X ?= f(h(g(X))), [Z ?= a], Q2),
    Q2 == bottom,
    echoNL("Résultat : bottom"), nl,

    echoNL("[X ?= f(h(Z,g(Y,X)))]"),
    reduit(check, X ?= f(h(Z,g(Y,X))), [], Q3),
    Q3 == bottom,
    echoNL("Résultat : bottom"), nl,

    echoNL("[X ?= f(h(Z,g(Y,X))), Z ?= b, W ?= f(Z)]"),
    reduit(check, X ?= f(h(Z,g(Y,X))), [Z ?= b, _W ?= f(Z)], Q4),
    Q4 == bottom,
    echoNL("Résultat : bottom"), nl, nl.


%Test de réduit avec la règle orient.
test_reduit_orient() :-
    echoNL("TEST ORIENT :"),

    echoNL("[a ?= X]"),
    reduit(orient, a ?= X, [], Q1),
    Q1 == [X ?= a],
    echoNL("Résultat : [X ?= a]"), nl,

    echoNL("[a ?= X, Y ?= X]"),
    reduit(orient, a ?= X, [Y ?= X], Q2),
    Q2 == [X ?= a, Y ?= X],
    echoNL("Résultat : [X ?= a, Y ?= X]"), nl, nl.


%Test de réduit avec la règle decompose.
test_reduit_decompose() :-
    echoNL("TEST DECOMPOSE :"),

    echoNL("[f(X) ?= f(Y)]"),
    reduit(decompose, f(X) ?= f(Y), [], Q1),
    Q1 == [X ?= Y],
    echoNL("Résultat : [X ?= Y]"), nl,

    echoNL("[f(X,Y) ?= f(a,b)]"),
    reduit(decompose, f(X,Y) ?= f(a,b), [], Q2),
    Q2 == [X ?= a, Y ?= b],
    echoNL("Résultat : [X ?= a, Y ?= b]"), nl,

    echoNL("[f(X) ?= f(a), Y ?= X]"),
    reduit(decompose, f(X) ?= f(a), [Y ?= X], Q3),
    Q3 == [X ?= a, Y ?= X],
    echoNL("Résultat : [X ?= a, Y ?= X]"), nl,

    echoNL("[f(X,Y) ?= f(g(Z),h(a)), Z ?= f(Y)]"),
    reduit(decompose, f(X,Y) ?= f(g(Z),h(a)), [Z ?= f(Y)], Q4),
    Q4 == [X ?= g(Z), Y ?= h(a), Z ?= f(Y)],
    echoNL("Résultat : [X ?= a, Y ?= X, Z ?= f(Y)]"), nl, nl.


%Test de réduit avec la règle clash.
test_reduit_clash() :-
    echoNL("TEST CLASH :"),

    echoNL("[f(X) ?= f(a,b)]"),
    reduit(clash, f(X) ?= f(a,b), [], Q1),
    Q1 == bottom,
    echoNL("Résultat : bottom"), nl,

    echoNL("[f(X,Y) ?= f(a,b,c), Z ?= X]"),
    reduit(clash, f(X,Y) ?= f(a,b,c), [Z ?= X], Q2),
    Q2 == bottom,
    echoNL("Résultat : bottom"), nl,

    echoNL("[f(X) ?= g(Y)]"),
    reduit(clash, f(X) ?= g(Y), [], Q3),
    Q3 == bottom,
    echoNL("Résultat : bottom"), nl,

    echoNL("[f(X,Y) ?= g(a,b), Z ?= X]"),
    reduit(clash, f(X,Y) ?= g(a,b), [Z ?= X], Q4),
    Q4 == bottom,
    echoNL("Résultat : bottom"), nl, nl.


%Test de réduit avec la règle clean.
test_reduit_clean() :-
    echoNL("TEST CLEAN :"),

    echoNL("[X ?= X]"),
    reduit(clean, X ?= X, [], Q1),
    Q1 == [],
    echoNL("Résultat : []"), nl,

    echoNL("[a ?= a]"),
    reduit(clean, a ?= a, [], Q2),
    Q2 == [],
    echoNL("Résultat : []"), nl,

    echoNL("[X ?= X, Y ?= a]"),
    reduit(clean, X ?= X, [Y ?= a], Q3),
    Q3 == [Y ?= a],
    echoNL("Résultat : [Y ?= a]"), nl,

    echoNL("[f(X) ?= f(X), Y ?= a]"),
    reduit(clean, f(X) ?= f(X), [Y ?= a], Q4),
    Q4 == [Y ?= a],
    echoNL("Résultat : [Y ?= a]"), nl,

    echoNL("[f(g(h(X)))) ?= f(g(h(X))), Y ?= a]"),
    reduit(clean, f(g(h(X))) ?= f(g(h(X))), [Y ?= a], Q5),
    Q5 == [Y ?= a],
    echoNL("Résultat : [Y ?= a]"), nl, nl.


%Test de réduit avec la règle fail.
test_reduit_fail() :-
    echoNL("TEST FAIL :"),

    echoNL("[a ?= b]"),
    reduit(fail, a ?= b, [], Q1),
    Q1 == bottom,
    echoNL("Résultat : bottom"), nl,

    echoNL("[a ?= b, X ?= Y, Y ?= c]"),
    reduit(fail, a ?= b, [_X ?= Y, Y ?= c], Q2),
    Q2 == bottom,
    echoNL("Résultat : bottom"), nl, nl.
