% Grid Interaction Helpers 
% ------------------------------------------------------------
get_cell(Grid, R, C, Content) :-
nth1(R, Grid, Row),
nth1(C, Row, Content).

find_robot(Grid, R, C) :-
get_cell(Grid, R, C, r).

find_all_survivors(Grid, Survivors) :-
findall((R,C), get_cell(Grid, R, C, s), Survivors).

% ------------------------------------------------------------
% Movement Logic 
% ------------------------------------------------------------
direction(-1, 0). % Up
direction(1, 0).  % Down
direction(0, -1). % Left
direction(0, 1).  % Right

% ------------------------------------------------------------
% move/4 takes the Grid, the Visited path, the Current coordinate, and returns a valid Next coordinate.
% ------------------------------------------------------------
move(Grid, Visited, (R1,C1), (R2,C2)) :-
direction(DR, DC),
R2 is R1 + DR,
C2 is C1 + DC,
is_valid(Grid, R2, C2, Visited).

% ------------------------------------------------------------
% Validity Checks
% ------------------------------------------------------------
is_valid(Grid, R, C, Visited) :-
get_cell(Grid, R, C, Content),
\+ member(Content, [d, f]),
\+ member((R,C), Visited).

% ------------------------------------------------------------
% Example 1 — 4 × 5 Grid 
% ------------------------------------------------------------
grid([[r, e, d, e, e], 
     [e, e, f, e, s], 
     [d, e, e, e, d], 
     [e, s, e, f, s]]).

%Example 2 — 3 × 3 Grid 
%grid([[r, e, s], 
%     [d, f, e], 
%     [e, s, e]]). 

% Example 3 — 3x3 No path found example
%grid([[r, e, e],
%      [e, d, d],
%      [e, d, s]]).

% ------------------------------------------------------------
% Heuristic
% ------------------------------------------------------------
heuristic(Grid, Rescued, Visited, H) :- % H -> the heuristic value (output)
    find_all_survivors(Grid, All), % finds all survivors, Stores them in list All
    length(All, Total), 		   % Total = number of all survivors in the grid
    length(Rescued, Got),          % Got = how many survivors you already rescued
    Remaining is Total - Got, 	   % Remaining = survivors still not rescued
    length(Visited, Steps),        % Steps = how many moves you made so far
    H is (Remaining * 1000) - (Got * 100) + Steps.
% 1000 is much larger than 100 and steps
%So the algorithm will always focus on rescuing survivors first, even if the path is longer

% ------------------------------------------------------------
% Expand current state into successors
% ------------------------------------------------------------
% generates all possible next states (successors) from the current state.
expand(Grid, state(Pos, Visited, Rescued), Successors) :-
    findall(
        state(NewPos, [NewPos|Visited], NewRescued),
        (
        % "move" ensures:  movement is allowed, probably avoids obstacles, avoids revisiting nodes
            move(Grid, Visited, Pos, NewPos),  
            NewPos = (NR, NC),             % split the position in to row & col.
            (   get_cell(Grid, NR, NC, s), % check if the there is S 
                \+ member(NewPos, Rescued) % & not rescured before
            ->  NewRescued = [NewPos|Rescued] % If survivor found, Add this position to rescued list
            ;   NewRescued = Rescued       % else keep list unchanged
            )
        ),
        Successors
    ).

% ------------------------------------------------------------
% Pair each successor with its heuristic score
% ------------------------------------------------------------
% rank (order) successor states based on their heuristic value 
% so the search algorithm can pick the “best” ones first.
rank_successors(Grid, Successors, SortedPairs) :- % SortedPairs-> successors sorted by heuristic value
    findall(
        H-S, % for each S compute its heuristic value and store them as pairs
        (
            member(S, Successors),       % take each state S from sucessors list
            S = state(_, Vis, Res),
            heuristic(Grid, Res, Vis, H) % compute heursitic value of each S
        ),
        Pairs % store all Successors with their H in pairs
    ),
    msort(Pairs, SortedPairs). % sort them ascending

% ------------------------------------------------------------
% Greedy Best-First Search
% ------------------------------------------------------------

% Base case: open list empty, return best found so far
greedy_search(_Grid, [], _Closed, Best, Best).

% Skip already visited positions
greedy_search(Grid, [_H-state(Pos,_Vis,_Res)|Rest], Closed, BestSoFar, BestFinal) :-
    member(Pos, Closed), % check if node is a visited node
    !,
    greedy_search(Grid, Rest, Closed, BestSoFar, BestFinal).

% take best state from open list
greedy_search(Grid, [_H-Current|Rest], Closed, BestSoFar, BestFinal) :-
    Current = state(Pos,_,_),
    update_best(BestSoFar, Current, NewBest), % compare current to best found so far
    NewClosed = [Pos|Closed],          % mark position as visited
    expand(Grid, Current, Successors), % get all possible next states
    rank_successors(Grid, Successors, RankedPairs), %Assign heuristic and sort them
    append(RankedPairs, Rest, Combined),% add new states to the remaining ones
    msort(Combined, NewOpen),
    greedy_search(Grid, NewOpen, NewClosed, NewBest, BestFinal).

% ------------------------------------------------------------
% Update best solution
% ------------------------------------------------------------
% if no best yet, current become the best
update_best(none, Current, Current) :- !.
update_best(Best, Current, Result) :-
    Best    = state(_, BestVis, BestRes),
    Current = state(_, CurVis,  CurRes),
    length(BestRes, BCount), % # of S rescued in best state
    length(CurRes,  CCount), % # of S rescued in current state
    length(BestVis, BSteps), % steps in best state
    length(CurVis,  CSteps), % steps in current state
    (   CCount > BCount
    ->  Result = Current
    ;   CCount =:= BCount, CSteps < BSteps % Same survivors, fewer steps
    ->  Result = Current
    ;   Result = Best
    ).

% ------------------------------------------------------------
% Print path
% ------------------------------------------------------------
print_path(Path) :-
    write('Path found: '),
    print_path_items(Path).

% Base case: if path empty do nothing
print_path_items([]).

% Last element case (no arrow needed)
print_path_items([(R,C)]) :-
    format("(~w,~w)~n", [R,C]).

print_path_items([(R,C)|Rest]) :-
    Rest \= [],      % check it isn't the last element
    format("(~w,~w) -> ", [R,C]),
    print_path_items(Rest).

% ------------------------------------------------------------
% run_greedy:-
% ------------------------------------------------------------
run_greedy :-
    grid(Grid),
    find_robot(Grid, SR, SC), % get start position
    StartPos = (SR, SC),

    % check if start position is S 
    (   get_cell(Grid, SR, SC, s)
    ->  InitRescued = [StartPos] % add it to rescue list
    ;   InitRescued = []
    ),

    % build intial state
    InitState = state(StartPos, [StartPos], InitRescued),
    % calculate H for intial state
    heuristic(Grid, InitRescued, [StartPos], H0),

    Open   = [H0-InitState],
    Closed = [],

    greedy_search(Grid, Open, Closed, none, BestState),
  		% if no path found
    (   BestState = none
    ->  write('No path found.'), nl
    	% if best state is found
    ;   BestState = state(_FinalPos, Visited, Rescued),
        length(Rescued, NumRescued), % get # of S rescued
    		% if no S was rescued
        (   NumRescued =:= 0  
        ->  write('No path found.'), nl
        ;   reverse(Visited, Path), % get correct order of path
            length(Path, PathLen),
            Steps is PathLen - 1, % get # of moves not # of nodes
            print_path(Path),
            format("Survivors rescued: ~w~n", [NumRescued]),
            format("Number of steps: ~w~n",   [Steps])
        )
    ),
    !.