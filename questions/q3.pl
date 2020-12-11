% Définition de l'opérateur "?=".
:- op(20,xfy,?=).

% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo.
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo.
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.
echo(T) :- echo_on, !, write(T).
echo(_).

/*
 * Prédicat echoNL : permet d'afficher le terme T est de faire
 * un retour à la ligne.
 * T : terme à afficher.
 */
echoNL(T) :- echo(T), nl.

/*
 * Prédicat split : permet de couper une équation E en 2 et de récupérer
 * la partie gauche G et la partie droite D.
 * E : équation à couper.
 * G : partie gauche de l'équation.
 * D : partie droite de l'équation.
 */
split(E, G, D) :-
    arg(1, E, G),
    arg(2, E, D).


% ------------------------------------------------------------------------
% Prédicat regle(E, R) :
% Détermine la règle de transformation R qui s'applique à l'équation E.

/*
 * Règle clean : renvoie true si X et T sont égaux.
 * E : équation donnée.
 * R : règle clean.
 */
regle(E, clean) :-
    split(E, X, T),
    X == T, !.

/*
 * Règle rename : renvoie true si X et T sont des variables.
 * E : équation donnée.
 * R : règle rename.
 */
regle(E, rename) :-
    split(E, X, T),
    var(X),
    var(T),
    X \== T, !.

/*
 * Règle simplify : renvoie true si X est une variable et T une
 * constante.
 * E : équation donnée.
 * R : règle simplify.
 */
regle(E, simplify) :-
    split(E, X, T),
    var(X),
    atom(T), !.

/*
 * Règle expand : renvoie true si X est une variable, T un terme
 * composé et si X n'est pas dans T.
 * E : équation donnée.
 * R : règle expand.
 */
regle(E, expand) :-
    split(E, X, T),
    var(X),
    compound(T),
    not(occur_check(X, T)), !.

/*
 * Règle check : renvoie true si X et T sont différents et si X est dans
 * T.
 * E : équation donnée.
 * R : règle check.
 */
regle(E, check) :-
    split(E, X, T),
    X \== T,
    occur_check(X, T), !.

/*
 * Règle orient : renvoie true si T n'est pas une variable et si X en
 * est une.
 * E : équation donnée.
 * R : règle orient.
 */
regle(E, orient) :-
    split(E, T, X),
    not(var(T)),
    var(X), !.

/*
 * Règle decompose : renvoie true si X et T sont des termes composés et
 * s'ils ont le même nombre d'arguments et le même nom.
 * E : équation donnée.
 * R : règle decompose.
 */
regle(E, decompose) :-
    split(E, Fg, Fd),
    compound(Fg),
    compound(Fd),
    functor(Fg, NameG, ArityG),
    functor(Fd, NameD, ArityD),
    NameG == NameD,
    ArityG == ArityD, !.

/*
 * Règle clash : renvoie true si X et T sont des termes composés et
 * s'ils n'ont pas le même nombre d'arguments.
 * E : équation donnée.
 * R : règle clash.
 */
regle(E, clash) :-
    split(E, Fg, Fd),
    compound(Fg),
    compound(Fd),
    functor(Fg, _, ArityG),
    functor(Fd, _, ArityD),
    ArityG \== ArityD, !.

/*
 * Règle clash : renvoie true si X et T sont des termes composés et
 * s'ils n'ont pas le même nom.
 * E : équation donnée.
 * R : règle clash.
 */
regle(E, clash) :-
    split(E, Fg, Fd),
    compound(Fg),
    compound(Fd),
    functor(Fg, NameG, _),
    functor(Fd, NameD, _),
    NameG \== NameD, !.

/*
 * Règle fail : renvoie true si aucune autre règle n'a pu être
 * appliquée.
 * R : règle fail.
 */
regle(_, fail) :- !.


% ------------------------------------------------------------------------
% Prédicat occur_check(V, T) :
% Teste si la variable V apparaît dans le terme T.

/*
 * Test si V est dans T si T est un terme composé. (on
 * vérifie dans tous les arguments de T si V s'y trouve).
 * V : variable à trouvé dans T.
 * T : terme à vérifier.
 */
occur_check(V, T) :-
	var(V),
	compound(T),
	functor(T, _, NbArgs),
	occur_check_args(V, T, NbArgs).

/*
 * Test si V et T sont des variables et sont égales.
 * V : variable à trouvé dans T.
 * T : variable à vérifier.
 */
occur_check(V, T) :-
	var(V),
	var(T),
	V == T.


% Prédicat occur_check_args(V, T, N) :
% Teste si la variable V apparaît dans un argument du terme T.

/*
 * Test si V est dans le premier argument de T.
 * V : variable à trouvé dans T.
 * T : terme à vérifier.
 * N : indice du premier argument
 */
occur_check_args(V, T, 1) :-
	arg(1, T, Arg), !,
	occur_check(V, Arg).

% Prédicat occur_check_args: regarde si V est dans un des arguments
% de T (NbArgs : nombre d'arguments de T).
/*
 * Test si V est dans un des arguments de T. (on vérifie dans
 * tous les arguments de T si V s'y trouve).
 * V : variable à trouvé dans T.
 * T : terme à vérifier.
 * N : nombre d'arguments et vérifier.
 */
occur_check_args(V, T, NbArgs) :-
	arg(NbArgs, T, Arg),
	occur_check(V, Arg);
	NbArgs2 is (NbArgs - 1),
	occur_check_args(V, T, NbArgs2).


% ------------------------------------------------------------------------
% Prédicat reduit(R, E, P, Q) :
% Transforme le système d'équations P en le système d'équations Q par
% application de la règle de transformation R à l'équation E.

/*
 * Retourne le système P sans l'équation E.
 * R : règle clean.
 * P : reste des équations de P.
 * Q : système P sans l'équation E après application de la règle R.
 */
reduit(clean, _, P, P) :- !.

/*
 * Substitue X part T, et renvoie le système P sans l'équation traitée
 * (X et T sont des variables).
 * R : règle rename.
 * E : première équation de P.
 * P : reste des équations de P.
 * Q : système P sans l'équation E après application de la règle R.
 */
reduit(rename, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Substitue X par T, et renvoie le système P sans l'équation traitée
 * (X est une variable, T est une constante).
 * R : règle simplify.
 * E : première équation de P.
 * P : reste des équations de P.
 * Q : système P sans l'équation E après application de la règle R.
 */
reduit(simplify, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Substitue X par T, et renvoie le système P sans l'équation traitée
 * (X est une variable, T est un terme composé).
 * R : règle expand.
 * E : première équation de P.
 * P : reste des équations de P.
 * Q : système P sans l'équation E après application de la règle R.
 */
reduit(expand, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Retourne bottom si la règle check est appliquée.
 * R : règle check.
 * Q : bottom.
 */
reduit(check, _, _, bottom) :- !.

/*
 * Inverse T et X et ajoute l'équation inversée dans le système Q en
 * lui concaténant le système P.
 * R : règle orient.
 * E : équation à inversée.
 * P : reste des équations de P.
 * Q : système P avec l'équation E inversée après application de la
 * règle R.
 */
reduit(orient, E, P, [X ?= T|P]) :-
    split(E, T, X), !.

/*
 * Décompose les 2 termes composés de E dans une liste Decomp et
 * unifie cette liste avec le système P.
 * R : règle decompose.
 * E : équation à décomposée.
 * P : reste des équations de P.
 * Q : système P avec les équations décomposées après application
 * de la règle R.
 */
reduit(decompose, E, P, Q) :-
    decompose_liste(E, Decomp),
    union_systemes(Decomp, P, Q), !.

/*
 * Retourne bottom si la règle clash est appliquée.
 * R : règle clash.
 * Q : bottom.
 */
reduit(clash, _, _, bottom) :- !.

/*
 * Retourne bottom si la règle fail est appliquée.
 * R : règle fail.
 * Q : bottom.
 */
reduit(fail, _, _, bottom) :- !.


% ------------------------------------------------------------------------
% Prédicat decompose_liste(E, Decomp) :
% Décompose une équation E de la forme f(s1,...,sn) = f(t1,...,tn) en
% une liste Decomp de forme [s1 ?= t1, ...., sn ?= tn].

/*
 * Décompose l'équation E en 2 dans la liste Decomp. Fg est le terme
 * composé de gauche et Fd celui de droite.
 * E : équations à décomposée.
 * Decomp : liste des équations décomposées.
 */
decompose_liste(E, Decomp) :-
    split(E, Fg, Fd),
    functor(Fg, _, NbArgs),
    decompose_liste_args(Fg, Fd, NbArgs, [], Decomp).


% Prédicat decompose_liste_args(Fg, Fd, N, Le, Ls) :
% Prend le Nième argument de chaque terme composée Fg et Fd, crée
% l'équation En (Xn ?= Tn), l'ajoute dans la liste de sortie Ls
% et concatène cette liste avec la liste d'entrée Le.

/*
 * Décompose le premier argument de Fg et Fd, crée l'équation E1
 * (X1 ?= T1), l'ajoute dans Ls et concatène Le.
 * Fg : terme composé de gauche.
 * Fd : terme composé de droite.
 * N : indice du premier argument.
 * Le : liste des équations déjà décomposées.
 * Lr : liste des équations décomposées à laquelle on ajoute E1.
 */
decompose_liste_args(Fg, Fd, 1, Le, [X1 ?= T1|Le]) :-
    arg(1, Fg, X1),
    arg(1, Fd, T1), !.

/*
 * Décompose le Nième argument de Fg et Fdn crée l'équation En
 * (Xn ?= Tn), l'ajoute dans Le et appelle récursivement ce
 * prédicat avec le (N-1)ième terme.
 * Fg : terme composé de gauche.
 * Fd : terme composé de droite.
 * N : indice du Nième argument.
 * Le : liste des équations déjà décomposées.
 * Lr : liste des équations décomposés à laquelle on ajoute En.
 */
decompose_liste_args(Fg, Fd, N, Le, Lr) :-
    arg(N, Fg, XN),
    arg(N, Fd, TN),
    N2 is (N-1),
    decompose_liste_args(Fg, Fd, N2, [XN ?= TN|Le], Lr).


% ------------------------------------------------------------------------
% Prédicat union_systems(S1, S2, Q) :
% Unifie les systèmes S1 et S2 en système Q.

/*
 * Si S1 est vide, alors on renvoie le système S2.
 * S1 : système vide.
 * S2 : second système.
 * Q : système S2 à renvoyer.
 */
union_systemes([], S2, S2).

/*
 * Ajoute X (tête de S1) en tête du système Q et unifie L (reste de
 * S1) avec le système S2.
 * S1 : premier système.
 * S2 : second système.
 * Q : système unifié à renvoyer.
 */
union_systemes([X|L], S2,[X|Q]) :- union_systemes(L, S2, Q).


% ------------------------------------------------------------------------
% Prédicat choix_strategie(S, P, Q, E, R) :
% Choisis la stratégie à utiliser en fonction de S. Transforme le
% système P en système Q et indique l'équation E à traiter ainsi que la
% règle R à appliquer sur cette équation.

/*
 * Choix de la stratégie où l'on sélectionne la première équation
 * du système P.
 * S : choix premier.
 * P : système d'équations.
 * Q : système d'équations transformée.
 * E : équation à traitée.
 * R : règle à appliquer à E.
 */
choix_strategie(choix_premier, P, Q, E, R) :-
    choix_premier(P, Q, E, R), !.

/*
 * Choix de la stratégie où l'on sélectionne l'équation de plus
 * grand poids du système P.
 * S : choix pondere.
 * P : système d'équations.
 * Q : système d'équations transformée.
 * E : équation à traitée.
 * R : règle à appliquer à E.
 */
choix_strategie(choix_pondere, P, Q, E, R) :-
    choix_pondere(P, Q, E, R), !.

/*
 * Choix de la stratégie où l'on sélectionne la dernière équation
 * du système P.
 * S : choix dernier.
 * P : système d'équations.
 * Q : système d'équations transformée.
 * E : équation à traitée.
 * R: règle à appliquer à E.
 */
choix_strategie(choix_dernier, P, Q, E, R) :-
    choix_dernier(P, Q, E, R), !.


% ------------------------------------------------------------------------
% Prédicat choix(P, Q, E ,R) :
% Trouve l'équation E à traiter ainsi que la règle R à appliquer à cette
% équation. Transforme le système P en système Q en enlevant l'équation
% E à traiter.

/*
 * Choix de l'équation avec la stratégie premier. Sélectionne la
 * règle pouvant être appliquée à la première équation.
 * P : système d'équations (X tête du système et L reste du système).
 * Q : système d'équations transformée.
 * E : équation à traiter.
 * R : règle à appliquer à E.
 */
choix_premier([E|L], L, E, R) :-
    regle(E, R), !.

/*
 * Choix de l'équation avec la stratégie pondere. Sélectionne la
 * première équation à laquelle on peut appliquer la règle de plus
 * grand poids. Transforme ensuite le système P en système Q en
 * enlevant l'équation E trouvée.
 * P : système d'équations.
 * Q : système d'équations transformée.
 * E : équation à traiter.
 * R : règle à appliquer à E.
 */
choix_pondere(P, Q, E, R) :-
    equation_a_traitee(P, E, R),
    transformer_systeme(P, E, Q), !.

/*
 * Choix de l'équation avec la stratégie dernier. Sélectionne la
 * règle pouvant être appliquée à la dernière équation.
 * P : système d'équations.
 * Q : système d'équations transformée.
 * E : équation à traiter.
 * R : règle à appliquer à E.
 */
choix_dernier(P, L, E, R) :-
    reverse(P, [E|L]),
    regle(E, R), !.


% ------------------------------------------------------------------------
% Prédicat poids(R, P) :
% Donne le poids P associé à une règle R.
poids(expand, 0).
poids(decompose, 1).
poids(orient, 2).
poids(clean, 3).
poids(rename, 3).
poids(simplify, 3).
poids(fail, 4).
poids(clash, 4).
poids(check, 4).


% ------------------------------------------------------------------------
% Prédicat equation_a_traitee(P, E, R) :
% Trouve l'équation E à traiter d'un système P avec la règle R à lui
% appliquer dans le choix pondere.

/*
 * S'il n'y a plus qu'une équation dans P, on la renvoie ainsi
 * que la règle qui peut lui être appliquée.
 * P : système d'une équation.
 * E : équation à traiter.
 * R : règle à utiliser sur l'équation E.
 */
equation_a_traitee([E], E, R) :-
    regle(E, R), !.

/*
 * Compare une équation N et une équation N+1 et détermine laquelle
 * des 2 est plus prioritaire en fonction du poids de la règle qui
 * lui est associée. Recommence l'opération avec l'équation choisie
 * et le reste des équations de P.
 * P : système d'équations (E1 Nième équation, E2 (N+1)ième équation,
 * L reste des équations).
 * E : équation à traiter.
 * R : règle à utiliser sur l'équation E.
 */
equation_a_traitee([E1,E2|L], E, R) :-
    regle(E1, R1),
    regle(E2, R2),
    poids(R1, P1),
    poids(R2, P2),
    (  P1 >= P2
    -> equation_a_traitee([E1|L], E, R), !
    ;  equation_a_traitee([E2|L], E, R), !
     ).


% ------------------------------------------------------------------------
% Prédicat transformer_systeme(P, E, Q) :
% Trouve l'équation E du système P, la retire de P et indique le
% résultat dans Q.

/*
 * Si le système est vide, on renvoit un système vide.
 * P : système vide.
 * Q : système vide.
 */
transformer_systeme([], _, []) :- !.

/*
 * Si l'équation en tête de P est égal à l'équation E, on retourne le
 * reste de P concaténé à toutes les équations précédant E dans P. Sinon
 * on relance le prédicat avec le reste des équations de P.
 * P : système d'équations (X première équation de P, L reste des
 * équations de P).
 * E : équation à trouver.
 * Q : système d'équations sans l'équation E.
 */
transformer_systeme([X|L], E, Q) :-
    (   X == E
    ->  Q = L, !
    ;   transformer_systeme(L, E, L2),
        Q = [E|L2]).


% ------------------------------------------------------------------------
% Prédicat unifie(P, S) :
% Résout le système d'équation P avec la stratégie S.

/*
 * Si le système P est vide, on a réussi à unifier (Prolog se
 * charge d'écrire le mgu).
 * P : système vide.
 */
unifie([], _) :- nl, !.

/*
 * Si le système P est égal à bottom, alors on ne peut pas l'unifier.
 * P : bottom.
 */
unifie(bottom, _) :- nl, fail, !.

/*
 * Trouve l'équation E à traiter et la règle R à lui appliquer en
 * fonction de la stratégie S. Transforme le système P en système P2,
 * qui contient toutes les équations de P sans l'équation E.
 * Applique la règle R à l'équation E et transforme le système P2 en
 * système Q. Appelle ensuite unifie sur le nouveau système Q.
 * P : système d'équations à unifier.
 * S : stratégie à utiliser.
 */
unifie(P, S) :-
    choix_strategie(S, P, P2, E, R),
    echo(system: P), echo("\n"),
    echo(R: E), echo("\n"),
    reduit(R, E, P2, Q),
    unifie(Q, S), !.


% ------------------------------------------------------------------------
% Prédicat unif(P,S) et trace_unif(P,S) :
% Inhibe ou active la trace d'affichage des règles appliquées à chaque
% étape de l'algorithme d'unification.

/*
 * Désactive l'affichage des règles appliquées à chaque étape.
 * P : système d'équations à unifier.
 * S : stratégie à utiliser.
 */
unif(P, S) :-
    clr_echo,
    unifie(P, S).

/*
 * Active l'affichage des règles appliquées à chaque étape.
 * P : système d'équations à unifier.
 * S : stratégie à utiliser.
 */
trace_unif(P, S) :-
    set_echo,
    echo("\n"),
    unifie(P,S).
