% Definition de l'operateur "?=".
:- op(20,xfy,?=).

% Predicats d'affichage fournis

% set_echo: ce predicat active l'affichage par le predicat echo.
set_echo :- assert(echo_on).

% clr_echo: ce predicat inhibe l'affichage par le predicat echo.
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionne, echo(T) affiche le terme T
%          sinon, echo(T) reussit simplement en ne faisant rien.
echo(T) :- echo_on, !, write(T).
echo(_).

/*
 * Predicat echoNL : permet d'afficher le terme T est de faire
 * un retour a la ligne.
 * T : terme a afficher.
 */
echoNL(T) :- echo(T), nl.

/*
 * Predicat split : permet de couper une equation E en 2 et de recuperer
 * la partie gauche G et la partie droite D.
 * E : equation a couper.
 * G : partie gauche de l'equation.
 * D : partie droite de l'equation.
 */
split(E, G, D) :-
    arg(1, E, G),
    arg(2, E, D).


% ------------------------------------------------------------------------
% Predicat regle(E, R) :
% Determine la regle de transformation R qui s'applique � l'equation E.

/*
 * Regle clean : renvoie true si X et T sont egaux.
 * E : equation donnee.
 * R : regle clean.
 */
regle(E, clean) :-
    split(E, X, T),
    X == T, !.

/*
 * Regle rename : renvoie true si X et T sont des variables.
 * E : equation donnee.
 * R : regle rename.
 */
regle(E, rename) :-
    split(E, X, T),
    var(X),
    var(T),
    X \== T, !.

/*
 * Regle simplify : renvoie true si X est une variable et T une
 * constante.
 * E : equation donnee.
 * R : regle simplify.
 */
regle(E, simplify) :-
    split(E, X, T),
    var(X),
    atom(T), !.

/*
 * Regle expand : renvoie true si X est une variable, T un terme
 * compose et si X n'est pas dans T.
 * E : equation donnee.
 * R : regle expand.
 */
regle(E, expand) :-
    split(E, X, T),
    var(X),
    compound(T),
    not(occur_check(X, T)), !.

/*
 * Regle check : renvoie true si X et T sont differents et si X est dans
 * T.
 * E : equation donnee.
 * R : regle check.
 */
regle(E, check) :-
    split(E, X, T),
    X \== T,
    occur_check(X, T), !.

/*
 * Regle orient : renvoie true si T n'est pas une variable et si X en
 * est une.
 * E : equation donnee.
 * R : regle orient.
 */
regle(E, orient) :-
    split(E, T, X),
    not(var(T)),
    var(X), !.

/*
 * Regle decompose : renvoie true si X et T sont des termes composes et
 * s'ils ont le meme nombre d'arguments et le meme nom.
 * E : equation donnee.
 * R : regle decompose.
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
 * Regle clash : renvoie true si X et T sont des termes composes et
 * s'ils n'ont pas le meme nombre d'arguments.
 * E : equation donnee.
 * R : regle clash.
 */
regle(E, clash) :-
    split(E, Fg, Fd),
    compound(Fg),
    compound(Fd),
    functor(Fg, _, ArityG),
    functor(Fd, _, ArityD),
    ArityG \== ArityD, !.

/*
 * Regle clash : renvoie true si X et T sont des termes composes et
 * s'ils n'ont pas le meme nom.
 * E : equation donnee.
 * R : regle clash.
 */
regle(E, clash) :-
    split(E, Fg, Fd),
    compound(Fg),
    compound(Fd),
    functor(Fg, NameG, _),
    functor(Fd, NameD, _),
    NameG \== NameD, !.

/*
 * Regle fail : renvoie true si aucune autre regle n'a pu etre
 * appliquee.
 * R : regle fail.
 */
regle(_, fail) :- !.


% ------------------------------------------------------------------------
% Predicat occur_check(V, T) :
% Teste si la variable V apparait dans le terme T.

/*
 * Test si V est dans T si T est un terme compose. (on
 * verifie dans tous les arguments de T si V s'y trouve).
 * V : variable a trouve dans T.
 * T : terme a verifier.
 */
occur_check(V, T) :-
	var(V),
	compound(T),
	functor(T, _, NbArgs),
	occur_check_args(V, T, NbArgs).

/*
 * Test si V et T sont des variables et sont egales.
 * V : variable a trouve dans T.
 * T : variable a verifier.
 */
occur_check(V, T) :-
	var(V),
	var(T),
	V == T.


% Predicat occur_check_args(V, T, N) :
% Teste si la variable V apparait dans un argument du terme T.

/*
 * Test si V est dans le premier argument de T.
 * V : variable a trouve dans T.
 * T : terme a verifier.
 * N : indice du premier argument
 */
occur_check_args(V, T, 1) :-
	arg(1, T, Arg), !,
	occur_check(V, Arg).

% Predicat occur_check_args: regarde si V est dans un des arguments
% de T (NbArgs : nombre d'arguments de T).
/*
 * Test si V est dans un des arguments de T. (on verifie dans
 * tous les arguments de T si V s'y trouve).
 * V : variable a trouve dans T.
 * T : terme a verifier.
 * N : nombre d'arguments et verifier.
 */
occur_check_args(V, T, NbArgs) :-
	arg(NbArgs, T, Arg),
	occur_check(V, Arg);
	NbArgs2 is (NbArgs - 1),
	occur_check_args(V, T, NbArgs2).


% ------------------------------------------------------------------------
% Predicat reduit(R, E, P, Q) :
% Transforme le systeme d'equations P en le systeme d'equations Q par
% application de la regle de transformation R a l'equation E.

/*
 * Retourne le systeme P sans l'equation E.
 * R : regle clean.
 * P : reste des equations de P.
 * Q : systeme P sans l'equation E apres application de la regle R.
 */
reduit(clean, _, P, P) :- !.

/*
 * Substitue X part T, et renvoie le syst�me P sans l'equation traitee
 * (X et T sont des variables).
 * R : regle rename.
 * E : premiere equation de P.
 * P : reste des equations de P.
 * Q : systeme P sans l'equation E apres application de la regle R.
 */
reduit(rename, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Substitue X par T, et renvoie le syst�me P sans l'equation traitee
 * (X est une variable, T est une constante).
 * R : regle simplify.
 * E : premiere equation de P.
 * P : reste des equations de P.
 * Q : systeme P sans l'equation E apres application de la regle R.
 */
reduit(simplify, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Substitue X par T, et renvoie le systeme P sans l'equation traitee
 * (X est une variable, T est un terme compose).
 * R : regle expand.
 * E : premiere equation de P.
 * P : reste des equations de P.
 * Q : systeme P sans l'equation E apres application de la regle R.
 */
reduit(expand, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Retourne bottom si la regle check est appliquee.
 * R : regle check.
 * Q : bottom.
 */
reduit(check, _, _, bottom) :- !.

/*
 * Inverse T et X et ajoute l'equation inversee dans le systeme Q en
 * lui concatenant le systeme P.
 * R : regle orient.
 * E : equation � inversee.
 * P : reste des equations de P.
 * Q : systeme P avec l'equation E inversee apres application de la
 * regle R.
 */
reduit(orient, E, P, [X ?= T|P]) :-
    split(E, T, X), !.

/*
 * Decompose les 2 termes composes de E dans une liste Decomp et
 * unifie cette liste avec le systeme P.
 * R : regle decompose.
 * E : equation � decomposee.
 * P : reste des equations de P.
 * Q : systeme P avec les equations decomposees apres application
 * de la regle R.
 */
reduit(decompose, E, P, Q) :-
    decompose_liste(E, Decomp),
    union_systemes(Decomp, P, Q), !.

/*
 * Retourne bottom si la regle clash est appliquee.
 * R : regle clash.
 * Q : bottom.
 */
reduit(clash, _, _, bottom) :- !.

/*
 * Retourne bottom si la regle fail est appliquee.
 * R : regle fail.
 * Q : bottom.
 */
reduit(fail, _, _, bottom) :- !.


% ------------------------------------------------------------------------
% Predicat decompose_liste(E, Decomp) :
% Decompose une equation E de la forme f(s1,...,sn) = f(t1,...,tn) en
% une liste Decomp de forme [s1 ?= t1, ...., sn ?= tn].

/*
 * Decompose l'equation E en 2 dans la liste Decomp. Fg est le terme
 * compose de gauche et Fd celui de droite.
 * E : equations a decomposee.
 * Decomp : liste des equations decomposees.
 */
decompose_liste(E, Decomp) :-
    split(E, Fg, Fd),
    functor(Fg, _, NbArgs),
    decompose_liste_args(Fg, Fd, NbArgs, [], Decomp).


% Predicat decompose_liste_args(Fg, Fd, N, Le, Ls) :
% Prend le Nieme argument de chaque terme composee Fg et Fd, cree
% l'equation En (Xn ?= Tn), l'ajoute dans la liste de sortie Ls
% et concatene cette liste avec la liste d'entree Le.
/*
 * Decompose le premier argument de Fg et Fd, cree l'equation E1
 * (X1 ?= T1), l'ajoute dans Ls et concatene Le.
 * Fg : terme compose de gauche.
 * Fd : terme compose de droite.
 * N : indice du premier argument.
 * Le : liste des equations deja decomposees.
 * Lr : liste des equations decomposees a laquelle on ajoute E1.
 */
decompose_liste_args(Fg, Fd, 1, Le, [X1 ?= T1|Le]) :-
    arg(1, Fg, X1),
    arg(1, Fd, T1), !.

/*
 * Decompose le Nieme argument de Fg et Fdn cree l'equation En
 * (Xn ?= Tn), l'ajoute dans Le et appelle recursivement ce
 * predicat avec le (N-1)ieme terme.
 * Fg : terme compose de gauche.
 * Fd : terme compose de droite.
 * N : indice du Nieme argument.
 * Le : liste des equations deja decomposees.
 * Lr : liste des equations decomposes a laquelle on ajoute En.
 */
decompose_liste_args(Fg, Fd, N, Le, Lr) :-
    arg(N, Fg, XN),
    arg(N, Fd, TN),
    N2 is (N-1),
    decompose_liste_args(Fg, Fd, N2, [XN ?= TN|Le], Lr).


% ------------------------------------------------------------------------
% Predicat union_systems(S1, S2, Q) :
% Unifie les systemes S1 et S2 en systeme Q.

/*
 * Si S1 est vide, alors on renvoie le systeme S2.
 * S1 : systeme vide.
 * S2 : second systeme.
 * Q : systeme S2 a renvoyer.
 */
union_systemes([], S2, S2).

/*
 * Ajoute X (tete de S1) en tete du systeme Q et unifie L (reste de
 * S1) avec le systeme S2.
 * S1 : premier systeme.
 * S2 : second systeme.
 * Q : systeme unifie a renvoyer.
 */
union_systemes([X|L], S2,[X|Q]) :- union_systemes(L, S2, Q).


% ------------------------------------------------------------------------
% Predicat choix_strategie(S, P, Q, E, R) :
% Choisis la strategie a utiliser en fonction de S. Transforme le
% systeme P en systeme Q et indique l'equation E a traiter ainsi que la
% regle R a appliquer sur cette equation.

/*
 * Choix de la strategie ou l'on selectionne la premiere equation
 * du systeme P.
 * S : choix premier.
 * P : systeme d'equations.
 * Q : systeme d'equations transformee.
 * E : equation a traitee.
 * R : regle a appliquer a E.
 */
choix_strategie(choix_premier, P, Q, E, R) :-
    choix_premier(P, Q, E, R), !.

/*
 * Choix de la strategie ou l'on selectionne l'equation de plus
 * grand poids du systeme P.
 * S : choix pondere.
 * P : systeme d'equations.
 * Q : systeme d'equations transformee.
 * E : equation a traitee.
 * R : regle a appliquer a E.
 */
choix_strategie(choix_pondere, P, Q, E, R) :-
    choix_pondere(P, Q, E, R), !.

/*
 * Choix de la strategie ou l'on selectionne la derniere equation
 * du systeme P.
 * S : choix dernier.
 * P : systeme d'equations.
 * Q : systeme d'equations transformee.
 * E : equation a traitee.
 * R: regle a appliquer a E.
 */
choix_strategie(choix_dernier, P, Q, E, R) :-
    choix_dernier(P, Q, E, R), !.


% ------------------------------------------------------------------------
% Predicat choix(P, Q, E ,R) :
% Trouve l'equation E a traiter ainsi que la regle R a appliquer a cette
% equation. Transforme le systeme P en systeme Q en enlevant l'equation
% E a traiter.

/*
 * Choix de l'equation avec la strategie premier. Selectionne la
 * regle pouvant etre appliquee a la premiere equation.
 * P : systeme d'equations (X tete du systeme et L reste du systeme).
 * Q : systeme d'equations transformee.
 * E : equation a traiter.
 * R : regle a appliquer a E.
 */
choix_premier([E|L], L, E, R) :-
    regle(E, R), !.

/*
 * Choix de l'equation avec la strategie pondere. Selectionne la
 * premiere equation a laquelle on peut appliquer la regle de plus
 * grand poids. Transforme ensuite le systeme P en systeme Q en
 * enlevant l'equation E trouvee.
 * P : systeme d'equations.
 * Q : systeme d'equations transformee.
 * E : equation a traiter.
 * R : regle a appliquer a E.
 */
choix_pondere(P, Q, E, R) :-
    equation_a_traitee(P, E, R),
    transformer_systeme(P, E, Q), !.

/*
 * Choix de l'equation avec la strategie dernier. Selectionne la
 * regle pouvant etre appliquee a la derniere equation.
 * P : systeme d'equations.
 * Q : systeme d'equations transformee.
 * E : equation a traiter.
 * R : regle a appliquer a E.
 */
choix_dernier(P, L, E, R) :-
    reverse(P, [E|L]),
    regle(E, R), !.


% ------------------------------------------------------------------------
% Predicat poids(R, P) :
% Donne le poids P associe a une regle R.
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
% Predicat equation_a_traitee(P, E, R) :
% Trouve l'equation E a traiter d'un systeme P avec la regle R a lui
% appliquer dans le choix pondere.

/*
 * S'il n'y a plus qu'une equation dans P, on la renvoie ainsi
 * que la regle qui peut lui etre appliquee.
 * P : systeme d'une equation.
 * E : equation a traiter.
 * R : regle a utiliser sur l'equation E.
 */
equation_a_traitee([E], E, R) :-
    regle(E, R), !.

/*
 * Compare une equation N et une equation N+1 et determine laquelle
 * des 2 est plus prioritaire en fonction du poids de la regle qui
 * lui est associee. Recommence l'operation avec l'equation choisie
 * et le reste des equations de P.
 * P : systeme d'equations (E1 Nieme equation, E2 (N+1)ieme equation,
 * L reste des equations).
 * E : equation a traiter.
 * R : regle a utiliser sur l'equation E.
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
% Predicat transformer_systeme(P, E, Q) :
% Trouve l'equation E du systeme P, la retire de P et indique le
% resultat dans Q.

/*
 * Si le systeme est vide, on renvoit un systeme vide.
 * P : systeme vide.
 * Q : systeme vide.
 */
transformer_systeme([], _, []) :- !.

/*
 * Si l'equation en tete de P est egal a l'equation E, on retourne le
 * reste de P concatene a toutes les equations precedant E dans P. Sinon
 * on relance le predicat avec le reste des equations de P.
 * P : systeme d'equations (X premiere equation de P, L reste des
 * equations de P).
 * E : equation a trouver.
 * Q : systeme d'equations sans l'equation E.
 */
transformer_systeme([X|L], E, Q) :-
    (   X == E
    ->  Q = L, !
    ;   transformer_systeme(L, E, L2),
        Q = [X|L2]).


% ------------------------------------------------------------------------
% Predicat unifie(P, S) :
% Resout le systeme d'equation P avec la strategie S.

/*
 * Si le systeme P est vide, on a reussi a unifier (Prolog se
 * charge d'ecrire le mgu).
 * P : systeme vide.
 */
unifie([], _) :- nl, !.

/*
 * Si le systeme P est egal a bottom, alors on ne peut pas l'unifier.
 * P : bottom.
 */
unifie(bottom, _) :- nl, fail, !.

/*
 * Trouve l'equation E a traiter et la regle R a lui appliquer en
 * fonction de la strategie S. Transforme le systeme P en systeme P2,
 * qui contient toutes les equations de P sans l'equation E.
 * Applique la regle R a l'equation E et transforme le systeme P2 en
 * systeme Q. Appelle ensuite unifie sur le nouveau systeme Q.
 * P : systeme d'equations a unifier.
 * S : strategie a utiliser.
 */
unifie(P, S) :-
    choix_strategie(S, P, P2, E, R),
    echo(system: P), echo("\n"),
    echo(R: E), echo("\n"),
    reduit(R, E, P2, Q),
    unifie(Q, S), !.


% ------------------------------------------------------------------------
% Predicat unif(P,S) et trace_unif(P,S) :
% Inhibe ou active la trace d'affichage des regles appliquees a chaque
% etape de l'algorithme d'unification.

/*
 * Desactive l'affichage des regles appliquees a chaque etape.
 * P : systeme d'equations a unifier.
 * S : strategie a utiliser.
 */
unif(P, S) :-
    clr_echo,
    unifie(P, S).

/*
 * Active l'affichage des regles appliquees a chaque etape.
 * P : systeme d'equations a unifier.
 * S : strategie a utiliser.
 */
trace_unif(P, S) :-
    set_echo,
    echo("\n"),
    unifie(P,S).


% ------------------------------------------------------------------------
% Interface en lignes de commande pour executer l'algorithme.

/*
 * Demande a l'utilisateur d'entrer un systeme d'equations, de
 * choisir la strategie a utiliser et s'il activer la trace ou
 * non.
 */
algorithme_martelli() :-
    writeln("=== Algorithme d'unification de Martelli-Montanari ==="), nl,

    systeme_equations(P), nl,
    strategie(S), nl,
    affichage(A), nl,

    writeln("=== Debut de l'algorithme ==="), nl,
    write("Systeme : "), writeln(P),

    (   A == 1
    ->  trace_unif(P, S)
    ;   unif(P, S)).


/*
 * Demande a l'utilisateur le systeme d'equations qu'il souhaite
 * unifier.
 * P : systeme d'equations a unifier.
 */
systeme_equations(P) :-
    writeln("Entrez le systeme d'equations a unifier :"),
    writeln("(Systeme de la forme [S1 ?= T1, ... ,SN ?= TN].)"),
    read(P),
    is_list(P),
    verifier_equations(P).


% Verifie le systeme d'equations

/*
 * Si le systeme est vide, alors on a atteint la fin.
 * P : systeme d'equations a verifier.
 */
verifier_equations([]).

/*
 * Si une equation n'est pas de la forme Sn ?= Tn alors le
 * systeme n'est pas bon.
 * P : systeme d'equations a verifier.
 */
verifier_equations([E|L]) :-
    split(E, S, T),
    (   E == S ?= T
    ->  verifier_equations(L)
    ;   write("Systeme incorrect"), fail, !).


/*
 * Demande a l'utilisateur la strategie qu'il souhaite utiliser.
 * Si l'entree donnee n'est pas bonne, alors il y a une erreur.
 * S : strategie a utiliser.
 */
strategie(S) :-
    writeln('Ecrivez le numero de strategie a utiliser :'),
    writeln('1: choix premier'),
    writeln('2: choix pondere'),
    writeln('3: choix dernier'),
    read(N),
    (   integer(N)
    -> ( N >= 1, 3 >= N
       ->  strat(N, S)
       ;   write("Strategie incorrecte"), fail, !)
    ;   write("Ce n'est pas un entier"), fail, !).

% Numero des strategies.
strat(1, choix_premier).
strat(2, choix_pondere).
strat(3, choix_dernier).


/*
 * Demande a l'utilisateur s'il veut activer la trace des regles.
 * Si l'entree donnee n'est pas bonne, alors il y a une erreur.
 * A : affichage a utiliser.
 */
affichage(A) :-
    writeln("Voulez vous activer la trace des etapes ? :"),
    writeln('1: Oui'),
    writeln('2: Non'),
    read(A),
    (   integer(A), A >= 1, 2 >= A
    ->  !
    ;   write("Reponse incorrecte"), fail, !).
