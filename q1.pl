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

%Règle rename : renvoie true si G et D sont des variables.
regle(E, rename) :-
    split(E, G, D),
    var(D),
    var(G), !.

%Règle simplify : renvoie true si G est une variable et D une constante.
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

%Règle check : renvoie true si G et D sont différent et si G est dans D.
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

% Règle clash 1 : renvoie true si G et D sont des termes composés et
% qu'ils n'ont pas le même nombre d'arguments.
regle(E, clash) :-
    split(E, G, D),
    compound(G),
    compound(D),
    functor(G, _, ArityG),
    functor(D, _, ArityD),
    ArityG \== ArityD, !.

% Règle clash 1 : renvoie true si G et D sont des termes composés et
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

%Prédicat occur_check 1 : test si V est dans T.
occur_check(V,T) :-
	var(V),
	compound(T),
	functor(T,_,NbP),
	occur_check_comp(V,T,NbP).

%Prédicat occur_check 2 : test si V est égal à T.
occur_check(V,T) :-
	var(V),
	var(T),
	V==T.

% Prédicat occur_check_comp 1 : regarde si V est dans le premier
% argument de T.
occur_check_comp(V,T,1) :-
	arg(1,T,Arg),!,
	occur_check(V,Arg).

% Prédicat occur_check_comp 2 : prédicat récursif, regarde pour chaque
% argument de T si V est dedans.
occur_check_comp(V,T,NbP) :-
	arg(NbP,T,Value),
	occur_check(V,Value);
	NbP2 is (NbP-1),
	occur_check_comp(V,T,NbP2).
