(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0013.PAS
  Description: Linked List Queues
  Author: WARREN PORTER
  Date: 01-27-94  12:12
*)

{
│ I'm trying to understand the rudiments of linked lists

│ 4) What are common uses for linked lists?  Is any one particular form
│    (oneway, circular etc ) preferred or used over any other form?

One use is to maintain queues.  New people, requests, or jobs come in at
the end of the line (or break in with priority), but once the head of
the line has been serviced, there is no need to maintain its location in
the queue.  I wrote the following last semester:
---------------------------------------------------------------
Purpose:
  Maintains a queue of jobs and priorities of those jobs in a linked list.
  The user will be prompted for job number and priority and can list the
  queue, remove a job from the front of the queue (as if it ran), and stop
  the program.  A count of jobs outstanding at the end will be displayed. }

type
  PriRange = 0 .. 9;
  JobPnt   = ^JobNode;
  Jobnode  = RECORD
    Numb     : integer;
    Priority : PriRange;
    Link     : JobPnt
  END;

procedure addrec(var Start : JobPnt; comprec : Jobnode);
var
  curr,
  next,
  this  : JobPnt;
  found : boolean;
begin
  new(this);
  this^.Numb := comprec.Numb;
  this^.Priority := comprec.Priority;
  if Start = NIL then
  begin
    Start := this;   {Points to node just built}
    Start^.Link := NIL; {Is end of list}
  end
  else    {Chain exists, find a place to insert it}
  if comprec.Priority > Start^.Priority then
  begin
    this^.Link := Start;     {Prep for a new beg of chain}
    Start := this
  end {Condition for insert at beg of chain}
  else
  begin {Begin loop to insert after beg of chain}
    found := false;  {To initialize}
    curr  := start;
    while not found do
    begin
      next := curr^.link;
      if (next = NIL) or (comprec.Priority > next^.Priority) then
        found := true;
        if not found then
          curr:= next  {another iteration needed}
    end;
    {Have found this^ goes after curr^ and before next^}
    this^.Link := next; {Chain to end (even if NIL)}
    curr^.Link := this;  {Insertion complete}
  end;
end;

procedure remove(Var Start : JobPnt);
var
  hold : JobPnt;
begin
  if Start = NIL then
    Writeln('Cannot remove from empty queue', chr(7))
  else
  begin
    hold := Start^.Link; {Save 1st node of new chain}
    dispose(Start);     {Delete org from chain}
    Start := hold;       {Reset to new next job}
  end;
end;

procedure list(Start : JobPnt); {List all jobs in queue. "var" omitted}
begin
  if Start = NIL then
    Writeln('No jobs in queue')
  else
  begin
    Writeln('Job No     Priority');
    Writeln;
    while Start <> NIL do
    begin
      Writeln('  ',Start^.Numb : 3, '          ', Start^.Priority);
      Start:=Start^.Link
    end;
    Writeln;
    Writeln('End of List');
  end;
end;

{Main Procedure starts here}
var
  cntr  : integer;
  build : JobNode;
  work,
  Start : JobPnt;
  Achar : char;

begin
  Start := NIL; {Empty at first}
  cntr  := 0;
  REPEAT
    Write('Enter (S)top, (R)emove, (L)ist, or A jobnumb priority to');
    Writeln(' add to queue');
    Read(Achar);

    CASE Achar of
      'A', 'a' :
      begin
        Read(build.Numb);
        REPEAT
          Readln(build.Priority);
          if (build.Priority < 0) or (build.priority > 9) then
            Write(chr(7), 'Priority between 0 and 9, try again ');
        UNTIL (build.Priority >= 0) and (build.Priority <= 9);
        addrec(Start, build);
      end;

      'R', 'r' :
      begin
        Readln;
        remove(Start);
      end;

      'L', 'l' :
      begin
        Readln;
        list(Start);
      end;

      'S', 's' : Readln; {Will wait until out of CASE loop}

      else
      begin
        Readln;
        Writeln('Invalid option',chr(7))
      end;
    end;

  UNTIL (Achar = 's') or (Achar = 'S');
  work := start;
  while work <> NIL do
  begin
    cntr := cntr + 1;
    work := work^.link
  end;
  Writeln('Number of jobs remaining in queue: ', cntr);
end.
