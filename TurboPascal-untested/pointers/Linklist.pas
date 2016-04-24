(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0002.PAS
  Description: LINKLIST.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:54
*)

{
The following is the LinkList Unit written by Peter Davis in his wonderful
but, unFortunately, short-lived newsletter # PNL002.ZIP.  I have used this
Unit to Write tests of three or four of the Procedures but have stumped my toe
on his DELETE_HERE Procedure, the last one in the Unit.  I will post my tests
in the next message For any who may wish to see it:  Pete's Unit is unmodified.
 I almost think there is some kind of error in DELETE_HERE but he was too
thorough For that.  Can you, or someone seeing this show me how to use this
Procedure?  It will help me both With Pointers and With Units.

Here is the Unit:
}

Unit LinkList;

{ This is the linked list Unit acCompanying The Pascal NewsLetter, Issue #2.
  This Unit is copyrighted by Peter Davis.
  It may be freely distributed in un-modified Form, or modified For use in
  your own Programs. Programs using any modified or unmodified Form of this
(107 min left), (H)elp, More?   Unit must include a run-time and source visible recognition of the author,
  Peter Davis.
}

{ The DataType used is Integer, but may be changed to whatever data Type
  that you want.
}

Interface


Type
  DataType = Integer;    { Change this data-Type to whatever you want  }

  Data_Ptr = ^Data_Rec;  { Pointer to our data Records                 }

  Data_Rec = Record      { Our Data Record Format                      }
    OurData  : DataType;
    Next_Rec : Data_Ptr;
  end;


Procedure Init_List(Var Head : Data_Ptr);
Procedure Insert_begin(Var Head : Data_Ptr; Data_Value : DataType);
Procedure Insert_end(Var Head : Data_Ptr; Data_Value : DataType);
Procedure Insert_In_order(Var Head : Data_Ptr; Data_Value : DataType);
Function Pop_First(Var Head : Data_Ptr) : DataType;
Function Pop_Last(Var Head : Data_Ptr) : DataType;
Procedure Delete_Here(Var Head : Data_Ptr; Our_Rec : Data_Ptr);



Implementation

Procedure Init_List(Var Head : Data_Ptr);

begin
  Head := nil;
end;

Procedure Insert_begin(Var Head : Data_Ptr; Data_Value : DataType);

{ This Procedure will insert a link and value into the
  beginning of a linked list.                             }

Var
  Temp : Data_Ptr;                { Temporary  Pointer.            }

begin
  new(Temp);                      { Allocate our space in memory.  }
  Temp^.Next_Rec := Head;         { Point to existing list.        }
  Head:= Temp;                    { Move head to new data item.    }
  Head^.OurData := Data_Value;    { Insert Data_Value.             }
end;

Procedure Insert_end(Var Head : Data_Ptr; Data_Value : DataType);

{ This Procedure will insert a link and value into the
  end of the linked list.                                 }

Var
  Temp1,             { This is where we're going to put new data }
  Temp2 : Data_Ptr;  { This is to move through the list.         }

begin
  new(Temp1);
  Temp2 := Head;
  if Head=nil then
    begin
      Head := Temp1;                  { if list is empty, insert first   }
      Head^.OurData := Data_Value;    { and only Record. Add value and   }
      Head^.Next_Rec := nil;          { then put nil in Next_Rec Pointer }
    end
  else
    begin
      { Go to the end of the list. Since Head is a Variable parameter,
        we can't move it through the list without losing Pointer to the
        beginning of the list. to fix this, we use a third Variable:
        Temp2.
      }
      While Temp2^.Next_Rec <> nil do    { Find the end of the list. }
        Temp2 := Temp2^.Next_Rec;

      Temp2^.Next_Rec := Temp1;          { Insert as last Record.    }
      Temp1^.Next_Rec := nil;            { Put in nil to signify end }
      Temp1^.OurData := Data_Value;      { and, insert the data      }
    end;
end;

Procedure Insert_In_order(Var Head : Data_Ptr; Data_Value : DataType);

{ This Procedure will search through an ordered linked list, find
  out where the data belongs, and insert it into the list.        }

Var
  Current,              { Where we are in the list               }
  Next     : Data_Ptr;  { This is what we insert our data into.  }

begin
  New(Next);
  Current := Head;      { Start at the top of the list.          }

  if Head = Nil then
    begin
      Head:= Next;
      Head^.OurData := Data_Value;
      Head^.Next_Rec := Nil;
    end
  else
  { Check to see if it comes beFore the first item in the list   }
  if Data_Value < Current^.OurData then
    begin
      Next^.Next_Rec := Head;      { Make the current first come after Next }
      Head := Next;                { This is our new head of the list       }
      Head^.OurData := Data_Value; { and insert our data value.             }
    end
  else
    begin
      { Here we need to go through the list, but always looking one step
        ahead of where we are, so we can maintain the links. The method
        we'll use here is: looking at Current^.Next_Rec^.OurData
        A way to explain that in english is "what is the data pointed to
        by Pointer Next_Rec, in the Record pointed to by Pointer
        current." You may need to run that through your head a few times
        beFore it clicks, but hearing it in English might make it a bit
        easier For some people to understand.                            }

      While (Data_Value >= Current^.Next_Rec^.OurData) and
            (Current^.Next_Rec <> nil) do
        Current := Current^.Next_Rec;
      Next^.OurData := Data_Value;
      Next^.Next_Rec := Current^.Next_Rec;
      Current^.Next_Rec := Next;
    end;
end;

Function Pop_First(Var Head : Data_Ptr) : DataType;

{ Pops the first item off the list and returns the value to the caller. }

Var
  Old_Head : Data_Ptr;

begin
  if Head <> nil then   { Is list empty? }
    begin
      Old_Head := Head;
      Pop_First := Head^.OurData;  { Nope, so Return the value }
      Head := Head^.Next_Rec;      { and increment head.       }
      Dispose(Old_Head);           { Get rid of the old head.  }
    end
  else
    begin
      Writeln('Error: Tried to pop an empty stack!');
      halt(1);
    end;
end;


Function Pop_Last(Var Head : Data_Ptr) : DataType;

{ This Function pops the last item off the list and returns the
  value of DataType to the caller.                              }

Var
  Temp : Data_Ptr;

begin
  Temp := Head;       { Start at the beginning of the list. }
  if head = nil then  { Is the list empty? }
    begin
      Writeln('Error: Tried to pop an empty stack!');
      halt(1);
    end
  else
  if head^.Next_Rec = Nil then { if there is only one item in list, }
    begin
      Pop_Last := Head^.OurData;  { Return the value               }
      Dispose(Head);              { Return the memory to the heap. }
      Head := Nil;                { and make list empty.           }
    end
  else
    begin
      While Temp^.Next_Rec^.Next_Rec <> nil do  { otherwise, find the end }
        Temp := Temp^.Next_rec;
      Pop_Last := Temp^.Next_Rec^.OurData;  { Return the value          }
      Dispose(Temp^.Next_Rec);              { Return the memory to heap }
      Temp^.Next_Rec := nil;                { and make new end of list. }
    end;
end;


Procedure Delete_Here(Var Head : Data_Ptr; Our_Rec : Data_Ptr);


{ Deletes the node Our_Rec from the list starting at Head. The Procedure
  does check For an empty list, but it assumes that Our_Rec IS in the list.
}

Var
  Current : Data_Ptr;  { Used to move through the list. }

begin
  Current := Head;
  if Current = nil then   { Is the list empty? }
    begin
      Writeln('Error: Cant delete from an empty stack.');
      halt(1);
    end
  else
    begin   { Go through list Until we find the one to delete. }
      While Current^.Next_Rec <> Our_Rec do
        Current := Current^.Next_Rec;
      Current ^.Next_Rec := Our_Rec^.Next_Rec; { Point around old link. }
      Dispose(Our_Rec);                        { Get rid of the link..  }
    end;
end;


end.

