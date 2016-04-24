(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0004.PAS
  Description: LL_TEST.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:54
*)

{
This is the test Program that I drew up to test the Procedures in Pete
Davis' LinkList.Pas posted in the previous message.  It could be a little more
dressed up but it does work and offers some insight, I think, into the use of
Pointers and linked lists:  note that I ran a little manual test to locate a
designated Pointer in a given list.  Here it is:
}

Uses
  Crt, LinkList;

Var
  AList1, AList2, AList3, AList4 : Data_Ptr;
  ANum : DataType;
  Count : Integer;

begin
  ClrScr;
  Init_List(AList1);
  Writeln('Results of inserting links at the beginning of a list: ');
  For Count := 1 to 20 do
  begin
    ANum := Count;
    Write(' ',ANum);
    Insert_begin(AList1, ANum); {pay out first link (1) to last (20) like}
                                {a fishing line With #-cards.  You end up}
  end;                          {with 20 in your hand going up to 1}
  Writeln;
  Writeln('Watch - Last link inserted is the highest number.');
  Writeln('You are paying out the list like reeling out a fishing line,');
  Writeln('Foot 1, Foot 2, Foot 3, etc. - last one is Foot 20.');
  Writeln('Now, mentally reel in the line to the fourth number.');
  Writeln(' ',alist1^.Next_Rec^.Next_Rec^.Next_Rec^.OurData);
  Writeln;
  Writeln('Now insert one additional number at beginning of list');
  begin
    ANum := 21;
    Insert_begin(AList1,ANum);
  end;
  Writeln(' ',AList1^.OurData);
   Writeln;


  Init_List(Alist2);
  Writeln('Results of Inserting links in turn at the end of a list: ');
  For Count := 1 to 20 do
  begin
    ANum := Count;
    Write(' ',ANum);
    Insert_end(Alist2,ANum);
  end;
  Writeln;
  Writeln('note, just the reverse situation of the process above.');
  Writeln('Reel in the line to the fourth number.');
  Writeln(' ',Alist2^.Next_Rec^.Next_Rec^.Next_Rec^.OurData);
          {We inserted at the end so we are now going out toward the 20}



 Init_List(Alist3);
 Writeln('Results of Inserting links in turn in orDER');
 For Count := 1 to 20 do
 begin
   Anum := Count;
   Write(' ',ANum);
   Insert_In_order(Alist3,ANum);
 end;
 Writeln;
 Writeln(' ',Alist3^.Next_Rec^.Next_Rec^.Next_Rec^.OurData);

end.
{
        In Case anybody missed Pete Davis' Linklist Unit in the previous
message but may have it in her/his library (PNL002.ZIP) what I was asking is
some help With writing code to test the Procedure DELETE_HERE which is the last
Procedure in the Unit.
}
