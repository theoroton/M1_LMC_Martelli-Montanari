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
    substitution_terme_args(Sub, X, T, NbP, Rs).

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