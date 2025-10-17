
:- set_prolog_flag(encoding, utf8).
:- consult('books').
:- consult('library_members').
:- dynamic borrowed/3.


:- use_module(library(date)).


/**
 * search_author(Author, BookID, Title, Publisher):
 * Searches for books by Author
*/
search_author(Author, BookID, Title, Publisher) :- 
    book(BookID, Title, Authors, Publisher), 
    member(Author, Authors).


% ID -> Title, Authors, Publisher SINGLE OUTPUT!
/**
 * search(BookID, Title, Authors, Publisher):
 * Search by BookID will return a single unique output.
 * No two books can have the same ID.
 */
search(BookID, Title, Authors, Publisher) :- 
    book(BookID, Title, Authors, Publisher).


/**
 * get_todays_date(Year, Month, Day):
 * Using library 'date' it fetches the current date in terms of the 
 * Year, Month, Day.
 * Serves as a helper method to the __ predicate.
*/
get_todays_date(Year, Month, Day) :-
    get_time(Timestamp),
    stamp_date_time(Timestamp, DateTime, 'UTC'),
    DateTime = date(Year, Month, Day, _, _, _, _, _, _).
% date(Y,M,D,H,Mn,S,Off,TZ,DST)


/**
 * is_available(BookID):
 * Checks if the book with BookID is available for a member to borrow.
*/
is_available(BookID) :- 
    \+ borrowed(BookID, _, _).


/** 
 * borrow(BookID, MemberID):
 * Let's a member with MemberID borrow a book with BookID.
 * Fails if a book doesn't exist or isn't available.
 * 
*/
borrow(BookID, MemberID) :- 
    search(BookID, BookTitle, _, _), 
    is_available(BookID), 
    get_todays_date(Year, Month, Day),
    assertz(borrowed(BookID, MemberID, date(Year, Month, Day))),
    format('Book "~w" was borrowed successfully.', [BookTitle]), !,
    true.
% Book doesn't exist
borrow(BookID, _) :-
    \+ search(BookID, _, _, _),
    write('Error: Book wasn\'t found in the database.'), !,
    fail.
% Books isn't available
borrow(BookID, _) :-
    \+ is_available(BookID),
    write('Error: Book isn\'t available. It has already been borrowed.'), !,
    fail. 


/**
 * return(BookID):
 * Returns a book with BookID.
*/
return(BookID) :-
    search(BookID, BookTitle, _, _),
    borrowed(BookID, MemberID, DueDate),
    retract(borrowed(BookID, MemberID, DueDate)),
    format('Book "~w" has been succesfully returned.', [BookTitle]).


/**
 * is_due(BookID):
 * Given BookID, checks whether the book is overdue.
*/
is_due(BookID) :- 
    search(BookID, _, _, _),
    borrowed(BookID, _, DateBorrowed),
    DateBorrowed = date(StartY, StartM, StartD),
    get_todays_date(CurYear, CurMonth, CurDay),
    calculate_due_date(StartY, StartM, StartD, DueY, DueM, DueD),
    compare(CurYear, CurMonth, CurDay, DueY, DueM, DueD), !,
    true.
% Book doesn't exist
is_due(BookID) :- 
    \+ search(BookID, _, _, _), 
    write('Error: Book wasn\'t found in the database.'), !,
    fail.
% Book wasn't borrowed
is_due(BookID) :- 
    \+ borrowed(BookID, _, _),
    write('Error: Book wasn\'t borrowed by anyone.'), !,
    fail.
/**
 * calculate_due_date(StartYear, StartMonth, StartDay, DueYear, DueMonth, DueDay):
 * This is a helper predicate. Given the start date, outputs the deadline of 
 * the loan period (3 weeks = 21 days).
 */
calculate_due_date(StartYear, StartMonth, StartDay, DueYear, DueMonth, DueDay) :-
    LoanPeriod = 21,  % 3 weeks
    StartDate = date(StartYear, StartMonth, StartDay),
    date_time_stamp(StartDate, StartTimeStamp),
    DueTimeStamp is StartTimeStamp + LoanPeriod * 84600,
    stamp_date_time(DueTimeStamp, DueDate, 'UTC'),
    DueDate = date(DueYear, DueMonth, DueDay, _, _, _, _, _, _).
/**
 * compare(StartYear, StartMonth, StartDay, DueYear, DueMonth, DueDay):
 * Helper predicate that checks whether the start date is past the due date.
 */
compare(StartYear, StartMonth, StartDay, DueYear, DueMonth, DueDay) :-
    (   StartYear > DueYear
    ;   StartYear = DueYear, StartMonth > DueMonth
    ;   StartYear = DueYear, StartMonth = DueMonth, StartDay = DueDay
    ).


% Borrowed Books are listed below: 
% borrowed(MemberID, BookID, BorrowedDate)
borrowed(13504, 1, date(2024, 10, 9)).
borrowed(10210, 1, date(2025, 1, 3)).
borrowed(51, 2, date(2024, 2, 22)).
borrowed(26420, 2, date(2024, 12, 30)).
borrowed(43236, 2, date(2025, 1, 5)).
borrowed(28348, 3, date(2025, 1, 10)).


% Example executions
% search(BookID, Title, Author, 'O''Reilly Media').
% search(BookID, '1984', Author, Publisher).
% search(BookID, Title, Author, 'Penguin').
