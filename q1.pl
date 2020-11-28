:- op(20,xfy,?=).

% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.

echo(T) :- echo_on, !, write(T).
echo(_).

% Prédicat split, récupère le premier et deuxième argument d'une
% équation E.
split(E, G, D) :-
    arg(1, E, G),
    arg(2, E, D).


% ------------------------------------------------------------------------
% Prédicat regle :
% Détermine la règle R pouvant être appliqué à l'équation E.

% Règle rename : renvoie true si G et D sont des variables.
regle(E, rename) :-
    split(E, G, D),
    var(G),
    var(D),
    G \== D, !.

% Règle simplify : renvoie true si G est une variable et D une
% constante.
regle(E, simplify) :-
    split(E, G, D),
    var(G),
    not(var(D)),
    not(compound(D)), !.

% Règle expand : renvoie true si G est une varible, D un terme composé
% et que G n'est pas dans D.
regle(E, expand) :-
    split(E, G, D),
    var(G),
    compound(D),
    not(occur_check(G, D)), !.

% Règle check : renvoie true si G et D sont différent et si G est dans
% D.
regle(E, check) :-
    split(E, G, D),
    G \== D,
    occur_check(G, D), !.

% Règle orient : renvoie true si G n'est pas une variable et si D en est
% une.
regle(E, orient) :-
    split(E, G, D),
    not(var(G)),
    var(D), !.

% Règle clash : renvoie true si G et D sont des termes composés et
% qu'ils n'ont pas le même nombre d'arguments.
regle(E, clash) :-
    split(E, G, D),
    compound(G),
    compound(D),
    functor(G, _, ArityG),
    functor(D, _, ArityD),
    ArityG \== ArityD, !.

% Règle clash : renvoie true si G et D sont des termes composés et
% qu'ils n'ont pas le même nom.
regle(E, clash) :-
    split(E, G, D),
    compound(G),
    compound(D),
    functor(G, NameG, _),
    functor(D, NameD, _),
    NameG \== NameD, !.

% Règle decompose : renvoie true si G et D sont des termes composés et
% si ils ont le même nombre d'arguments et le même nom.
regle(E, decompose) :-
    split(E, G, D),
    compound(G),
    compound(D),
    functor(G, NameG, ArityG),
    functor(D, NameD, ArityD),
    NameG == NameD,
    ArityG == ArityD, !.

% Règle clean : renvoie true si G et D sont des variables et si elles
% sont égales.
regle(E, clean) :-
    split(E, G, D),
    var(G),
    var(D),
    G == D, !.


% ------------------------------------------------------------------------
% Prédicat occur_check :
% Teste si la variable V apparait dans le terme T.

% Prédicat occur_check : test si V est dans T.
occur_check(V,T) :-
	var(V),
	compound(T),
	functor(T,_,NbP),
	occur_check_comp(V,T,NbP).

% Prédicat occur_check : test si V est égal à T.
occur_check(V,T) :-
	var(V),
	var(T),
	V==T.

% Prédicat occur_check_comp : regarde si V est dans le premier
% argument de T.
occur_check_comp(V,T,1) :-
	arg(1,T,Arg),!,
	occur_check(V,Arg).

% Prédicat occur_check_comp : prédicat récursif, regarde pour chaque
% argument de T si V est dedans.
occur_check_comp(V,T,NbP) :-
	arg(NbP,T,Value),
	occur_check(V,Value);
	NbP2 is (NbP-1),
	occur_check_comp(V,T,NbP2).


% ------------------------------------------------------------------------
% Prédicat reduit :
% Transforme le système P en système Q en appliquant la règle R à
% l'équation E.

% Prédicat reduit avec la règle rename :
% On remplace dans P tous les X par T et on récupère le système après
% substitution dans Q.
% T est une variable.
reduit(rename, E, P, Q) :-
    split(E, X, T),
    substitution(P, X, T, Q), !.

% Prédicat reduit avec la règle simplify :
% On remplace dans P tous les X par T et on récupère le système après
% substitution dans Q.
% T est une constante.
reduit(simplify, E, P, Q) :-
    split(E, X, T),
    substitution(P, X, T, Q), !.

% Prédicat reduit avec la règle expand :
% On remplace dans P tous les X par T et on récupère le système après
% substitution dans Q.
% T est un terme composé.
reduit(expand, E, P, Q) :-
    split(E, X, T),
    substitution(P, X, T, Q), !.

% Prédicat reduit avec la règle check :
% On retourne bottom dans Q si la règle check est appliquée.
reduit(check, _, _, Q) :-
    Q = bottom, !.

% Prédicat reduit avec la règle orient :
% On inverse T et X et on l'ajoute dans le système Q. On
% concatène ensuite P à ce système.
reduit(orient, E, P, Q) :-
    split(E, T, X),
    Q = [X ?= T|P], !.

% Prédicat reduit avec la règle decompose :
% On décompose les 2 termes de E dans Lr. On unifie ensuite Lr et P dans
% Q.
reduit(decompose, E, P, Q) :-
    decompose_liste(E, Lr),
    union(Lr,P,Q).

% Prédicat reduit avec la règle clash :
% On retourne bottom dans Q si la règle clash est appliquée.
reduit(clash, _, _, Q) :-
    Q = bottom, !.

% Prédicat reduit avec la règle clean :
% On retourne P sans l'équation traité pour la règle clean.
reduit(clean, _, P, Q) :-
    Q = P, !.


% ------------------------------------------------------------------------
% Prédicat substitution :
% Remplace toutes les occurences de X par T dans le système P et renvoie
% un système Q.

% Si le système P est vide, on ne renvoie rien.
substitution([],_,_,[]) :- !.

% Substitue la partie droite Dr de l'équation Eq, et appelle
% récursivement substitution pour substituer la partie restante L du
% système d'équations.
% A chaque substitution, on ajoute à la liste résultat l'équation "Ga ?=
% DrS", où Ga est la partie gauche de l'équation Eq courante et DrS la
% partie droite de l'équation après substitution, à laquelle on
% concatène le reste de la liste résultat.
substitution([Eq|L], X, T, [Ga ?= DrS|SubL]) :-
    split(Eq, Ga, Dr),
    substitution_terme(Dr, X, T, DrS),
    substitution(L, X, T, SubL).

% Si la partie à substitué Sub est différente de X, alors on renvoie
% Sub.
substitution_terme(Sub, X, _, Sub) :-
    not(compound(Sub)),
    Sub \== X, !.

% Si la partie à substitué Sub est égal à X, alors on renvoie le terme
% T.
substitution_terme(Sub, X, T, T) :-
    not(compound(Sub)),
    Sub == X, !.

% Si la partie à substitué Sub est un terme composé, on va regarder si
% les termes qui la compose contiennent X. Le résultat de cette
% substitution se trouvera dans Rs.
substitution_terme(Sub, X, T, Rs) :-
    compound(Sub),
    functor(Sub, _, NbP),
    substitution_arg(Sub, X, T, NbP, Rs).

% On substitue le premier argument de Sub, et on renvoie le résultat
% dans Rs.
substitution_terme_args(Sub, X, T, 1, Rs) :-
    arg(1, Sub, Value),
    substitution_terme(Value, X, T, V),
    functor(Sub, N, A),
    functor(Rs, N, A),
    arg(1, Rs, V), !.

% On substitue chacun des arguments de Sub, et on renvoie le résultat
% dans Rs.
substitution_terme_args(Sub, X, T, N1, Rs) :-
    arg(N1, Sub, Value),
    substitution_terme(Value, X, T, V),
    functor(Sub, N, A),
    functor(Rs, N, A),
    arg(N1, Rs, V),
    N2 is (N1-1),
    substitution_terme_args(Sub, X, T, N2, Rs).


% ------------------------------------------------------------------------
% Prédicat decompose_liste :
% Décompose une équation de la forme f(s1,...,sn) = f(t1,...,tn) en une
% liste.

% Décompose l'équation E dans la liste Lr.
decompose_liste(E,Lr) :-
    split(E, Fg, Fd),
    functor(Fg, _, N),
    decompose_liste_arg(Fg, Fd, N, [], Lr).

% Décompose les premiers arguments de chaque fonction et les places dans
% Lr.
decompose_liste_arg(Fg, Fd, 1, Le, Lr) :-
    arg(1, Fg, X1),
    arg(1, Fd, Y1),
    Lr = [X1 ?= Y1|Le], !.

% Décompose tous les arguments de chaque fonction et les places dans Lr.
decompose_liste_arg(Fg, Fd, N, Le, Lr) :-
    arg(N, Fg, XN),
    arg(N, Fd, YN),
    L = [XN ?= YN|Le],
    N2 is (N-1),
    decompose_liste_arg(Fg, Fd, N2, L, Lr).


% ------------------------------------------------------------------------
% Prédicat unifie :
% Résout le système d'équation P.

% Si on arrive la liste vide, le système P a était résolu.
unifie([]) :- nl, echo('Yes'), !.

% Si on trouve bottom, le système P ne peut pas être résolu.
unifie(bottom) :- nl, echo('No'), !, false.

% Applique la règle R à l'équation E et affiche la règle
% utilisé. Appel récursif unifie pour le système Q.
unifie([E|P]) :-
    regle(E, R),
    echo(system: [E|P]), nl,
    echo(R: E), nl,
    reduit(R, E, P, Q),
    unifie(Q).


