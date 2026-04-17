% Grid Interaction Helpers 

get_cell(Grid, R, C, Content) :-
nth1(R, Grid, Row),
nth1(C, Row, Content).

find_robot(Grid, R, C) :-
get_cell(Grid, R, C, r).

find_all_survivors(Grid, Survivors) :-
findall((R,C), get_cell(Grid, R, C, s), Survivors).

% Movement Logic 

direction(-1, 0). % Up
direction(1, 0).  % Down
direction(0, -1). % Left
direction(0, 1).  % Right

% move/4 takes the Grid, the Visited path, the Current coordinate, and returns a valid Next coordinate.
move(Grid, Visited, (R1,C1), (R2,C2)) :-
direction(DR, DC),
R2 is R1 + DR,
C2 is C1 + DC,
is_valid(Grid, R2, C2, Visited).

% Validity Checks

is_valid(Grid, R, C, Visited) :-
get_cell(Grid, R, C, Content),
\+ member(Content, [d, f]),
\+ member((R,C), Visited).