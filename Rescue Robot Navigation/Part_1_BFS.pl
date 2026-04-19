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

% ---- Grid Definition (change to test different scenarios) ----

% Example 1 — 4x5  (uncomment one grid at a time)
% grid([[r, e, d, e, e],
%       [e, e, f, e, s],
%       [d, e, e, e, e],
%       [e, s, e, f, e]]).

% Example 2 — 3x3
% grid([[r, e, e],
%       [d, f, e],
%       [e, e, s]]).

% Example 3 — 3x3 No path found example
%grid([[r, e, e],
%      [e, d, d],
%      [e, d, s]]).

% is_survivor/3 — true when the cell (R,C) contains a survivor
is_survivor(Grid, R, C) :-
    get_cell(Grid, R, C, s).

%  BFS IMPLEMENTATION
bfs(Grid, [state((R,C), Path) | _], _Closed, Path) :-
    is_survivor(Grid, R, C).

% Recursive case — expand the current node, enqueue children at TAIL
bfs(Grid, [state(Pos, Path) | RestOpen], Closed, FinalPath) :-
    findall(
        state(Next, [Next|Path]),
        (   move(Grid, Path, Pos, Next),
            \+ member(Next, Closed)
        ),
        Children
    ),
    % Append children to the TAIL of the open list (BFS queue), mark current position as closed
    append(RestOpen, Children, NewOpen),
    bfs(Grid, NewOpen, [Pos|Closed], FinalPath).

%  OUTPUT 
print_path([]) :- !.
print_path([(R,C)]) :-
    !,
    format('(~w,~w)', [R, C]).
print_path([(R,C) | Rest]) :-
    format('(~w,~w) -> ', [R, C]),
    print_path(Rest).

%  TOP-LEVEL ENTRY POINT
% solve/0 — call this to run the search.
solve :-
    grid(Grid),
    find_robot(Grid, SR, SC),
    StartPos = (SR, SC),
    InitialOpen = [state(StartPos, [StartPos])],
    (   bfs(Grid, InitialOpen, [], ReversedPath)
    ->  reverse(ReversedPath, Path),
        length(Path, Len),
        Steps   is Len - 1,
        Battery is 100 - Steps * 10,
        (   Battery >= 0
        ->  write('Path found: '),
            print_path(Path), nl,
            format('Number of steps: ~w~n',    [Steps]),
            format('Remaining Battery: ~w%~n', [Battery])
        ;   write('No path found.'), nl
        )
    ;   write('No path found.'), nl
    ),!.
