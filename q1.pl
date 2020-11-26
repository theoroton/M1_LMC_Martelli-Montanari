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

split(E, G, D) :-
    arg(1, E, G),
    arg(2, E, D).

regle(E, rename) :-
    split(E, G, D),
    var(D),
    var(G).

regle(E, simplify) :-
    split(E, G, D),
    var(G),
    not(var(D)),
    not(compound(D)).

regle(E, expand) :-
    split(E, G, D),
    var(G),
    compound(D),
    not(occur_check(G, D)).

%occur_check(G, D) :-.

regle(E, check) :-
    split(E, G, D),
    G \== D,
    occur_check(G, D).

regle(E, orient) :-
    split(E, G, D),
    not(var(G)),
    var(D).

regle(E, decompose) :-
    split(E, G, D),
    func(G,D).

regle(E, clash) :-
    split(E, G, D),
    not(func(G, D)).

func(G, D) :-
    compound(G),
    compound(D),
    functor(G, NameG, ArityG),
    functor(D, NameD, ArityD),
    NameG == NameD,
    ArityG == ArityD.
