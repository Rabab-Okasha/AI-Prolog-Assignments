%%%%%%%%%%%%%%%%%%%%%%%%%%% Students Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% student(Name, Year)

student(ali, first).
student(sara, second).
student(omar, third).
student(mona, second).
student(yousef, first).
student(nour, fourth).
student(karim, third).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Books Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% book(Title, Author)

book(prolog_fundamentals, dr_hassan).
book(recursion_in_depth, dr_sara).
book(list_programming, dr_ahmed).
book(ai_intro, dr_mona).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Borrow Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% borrowed(Student, Book)

borrowed(ali, prolog_fundamentals).
borrowed(ali, list_programming).

borrowed(sara, recursion_in_depth).
borrowed(sara, ai_intro).

borrowed(omar, recursion_in_depth).

borrowed(mona, prolog_fundamentals).
borrowed(mona, recursion_in_depth).
borrowed(mona, list_programming).

borrowed(yousef, list_programming).

borrowed(nour, ai_intro).

borrowed(karim, recursion_in_depth).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Topics Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% topics(Book, TopicsList)

topics(prolog_fundamentals, [facts, rules, queries, unification]).
topics(recursion_in_depth, [base_case, recursive_case, tracing, termination]).
topics(list_programming, [head_tail, member, append, length, prefix, suffix]).
topics(ai_intro, [search, logic, knowledge_representation]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Ratings Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rating(Student, Book, Score)

rating(ali, prolog_fundamentals, 85).
rating(ali, list_programming, 90).

rating(sara, recursion_in_depth, 95).
rating(sara, ai_intro, 88).

rating(omar, recursion_in_depth, 80).

rating(mona, prolog_fundamentals, 92).
rating(mona, recursion_in_depth, 89).
rating(mona, list_programming, 91).

rating(yousef, list_programming, 60).

rating(nour, ai_intro, 78).

rating(karim, recursion_in_depth, 83).

%-------------------Task 1-------------------
my_not(Goal) :-
    Goal, !, fail.
my_not(_).

my_member(X, [X|_]).
my_member(X, [_|T]) :- my_member(X, T).

my_append([], L, L).
my_append([H|T], L, [H|R]) :- my_append(T, L, R).

books_borrowed_by_student(Student, L) :-
    books_borrowed_by_student(Student, [], L).

books_borrowed_by_student(Student, Acc, L) :-
    borrowed(Student, Book),
    my_not(my_member(Book, Acc)),!,
    my_append(Acc, [Book], NewAcc),
    books_borrowed_by_student(Student, NewAcc, L).

books_borrowed_by_student(_, L, L).

%-------------------Task 2-------------------

% get unique borrowers list then count
borrowers_count(Book, N) :-
    get_unique_borrowers(Book, [], Borrowers),
    my_length(Borrowers, N).


get_unique_borrowers(Book, Acc, Borrowers) :-
    borrowed(Student, Book),
    my_not(my_member(Student, Acc)),!,
    get_unique_borrowers(Book, [Student|Acc], Borrowers).

get_unique_borrowers(_, Borrowers, Borrowers).

% get lenght of a list
my_length([], 0).
my_length([_|T], N) :-
    my_length(T, N1),
    N is N1 + 1.

%-------------------Task 5-------------------
get_max_score(MaxScore) :-
    rating(_, _, Score),
    my_not((rating(_, _, TempScore), TempScore > Score)),
    !,
    MaxScore = Score.

top_reviewer(Student) :-
    get_max_score(MaxScore),
    rating(Student, _, MaxScore),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
most_borrowed_book(B) :-
borrowed(_, B),
borrowers_count(B, Count),
    my_not((
        borrowed(_, OtherB),
       
        B \= OtherB, 
        borrowers_count(OtherB, OtherCount),
        OtherCount > Count
    )),
    !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_member(X, [X|_]) :- !.
is_member(X, [_|T]) :- is_member(X, T).
not_member(X, List) :- is_member(X, List), !, fail.
not_member(_, _).
% to restore original order
to_original_order(L, R) :- original_acc(L, [], R).
original_acc([], Acc, Acc).
original_acc([H|T], Acc, R) :- original_acc(T, [H|Acc], R).

collect_ratings(Book, Acc, L) :-
rating(S, Book, Score),
  not_member((S, Score), Acc),
!,
collect_ratings(Book,[(S, Score)|Acc], L).
collect_ratings(_, L, L).

ratings_of_book(Book, L) :-
    collect_ratings(Book, [], Temp),
    to_original_order(Temp, L),
    !.



%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%1)get all books borrowed by student 

borrowed_book(Student, Books) :-
    collect_books(Student, [], RevBooks),   % collect in reverse order
    to_original_order(RevBooks, Books).            % restore to original order


collect_books(Student, Acc, Books) :-
    borrowed(Student, Book),
    my_not(my_member(Book, Acc)),
    collect_books(Student, [Book|Acc], Books).
collect_books(_, Books, Books).
%2) collect all topic of this list 

books_topics([], []).
books_topics([Book|RestBooks], [Topics|RestTopics]) :-
    topics(Book, Topics),          % fetch the topics for this book
    books_topics(RestBooks, RestTopics).

borrowed_topics(Student, Topics) :-
    borrowed_book(Student, Books),   
    books_topics(Books, Topics).


% flatten_list/2 – flattens a list of lists (and handles non‑list elements)
flatten_list([], []).
flatten_list([H|T], Flat) :-
    is_list(H), !,                % if H is a list, flatten it first
    flatten_list(H, FlatH),
    flatten_list(T, FlatT),
    my_append(FlatH, FlatT, Flat).
flatten_list([H|T], [H|FlatT]) :-  % H is not a list, keep it as an element
    flatten_list(T, FlatT).

borrowed_topics_flat(Student, FlatTopics) :-
    borrowed_book(Student, Books),      
    books_topics(Books, BooksTopics),  
    flatten_list(BooksTopics, FlatTopics).

count_topic(_, [], 0).

count_topic(X, [X|T], N) :-
    count_topic(X, T, N1),
    N is N1 + 1.

count_topic(X, [_|T], N) :-
    count_topic(X, T, N).
most_frequent([H|T], Topics, Best) :-
    count_topic(H, Topics, N),
    most_frequent(T, Topics, H, N, Best).

most_frequent([], _, Best, _, Best).   

most_frequent([H|T], Topics, CurrBest, CurrMax, Best) :-
    count_topic(H, Topics, N),
    N > CurrMax,
    NewBest = H,
    CurrBest \= NewBest,
    most_frequent(T, Topics, NewBest, N, Best).

most_frequent([H|T], Topics, CurrBest, CurrMax, Best) :-
    count_topic(H, Topics, N),
    N =< CurrMax,
    most_frequent(T, Topics, CurrBest, CurrMax, Best).
most_common_topic_for_student(Student, Topic) :-
    borrowed_topics_flat(Student, Topics),
    most_frequent(Topics, Topics, Best),
    count_topic(Best, Topics, N),!,
    ( N > 1 ->
        Topic = Best
    ;
        Topic = no_common_topic
    ).
    
