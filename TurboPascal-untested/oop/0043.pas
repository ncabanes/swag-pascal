{
 RJS> Just a quick question... In the variable declaration field, you define
 RJS> an array with array [0..9] of foo, But let's say I didn't know exactly
 RJS> how big the array was going to be... How would I declare an array with
 RJS> a variable endpoint?

There are a couple of ways around this, and they employ the use of pointers,
which in turn, require a little additional code to maintain. If you are useing
Borlands Pascal 6 or 7, the tCollection objects work quite well, or else make
use of linked lists. There is still the option of using a variable lengthed
array too.

As an example,
}
{$A+,B-,D-,E-,F+,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 16384,0,655360}
Program VariableArrayETC;
uses objects;
Type
   Data = Record
            name : string[80];
            age  : integer;
          end;

  VArray = array[0..0] of Data;   {variable sized array}
  VAPtr  = ^Varray;

  VLPtr = ^VList;                 {linked list}
  VList = Record
            rec : Data;
            next,
            prev: VLPtr;
          end;

  DataPtr = ^data;                {OOP types from the objects unit}
  VObj    = Object(tCollection)
              procedure FreeItem(item:pointer); virtual;
            end;
  VObjPtr = ^VObj;
              Procedure VObj.FreeItem(item:pointer);
                 begin
                   dispose(DataPtr(item));
                 end;


procedure MakeTestFile;
   var i:integer;
       f:file of Data;
       d:data;
   Begin
     writeln;
     writeln('blank name will exit');
     assign(f,'test.dat');
     rewrite(f);
     fillchar(d,sizeof(d),0);
     repeat
       write('name : '); readln(d.name);
       if   d.name <> ''
       then begin
              repeat
                write('age : '); readln(d.age);
              until ioresult = 0;
              write(f,d);
            end;
     until d.name = '';
     close(f);
   End;

Procedure VariableArrayExample; {turn Range Checking off...}
   var f:file;
       v:VAPtr;
       i,res:integer;
       d:data;
       m:longint;
   Begin
     writeln;
     Writeln('output of variable array ... ');
     m := memavail;
     assign(f,'test.dat');
     reset(f,sizeof(data));
     getmem(v,filesize(f)*SizeOf(Data));
     blockRead(f,v^,filesize(f),res);
     for i := 0 to res - 1 do
        begin
          writeln(v^[i].name);
          writeln(v^[i].age);
        end;
     freemem(v,filesize(f)*SizeOf(Data));
     close(f);
     if m <> memavail then writeln('heap ''a trouble...');
   End;

Procedure LinkedListExample;
   var f:file of Data;
       curr,hold : VLPtr;
       m:longint;
   Begin
     curr := nil; hold := nil;
     writeln;
     writeln('Linked List example ... ');
     m := memavail;
     assign(f,'test.dat');
     reset(f);
     while not eof(f) do
        begin
          new(curr);
          curr^.prev := hold;
          read(f,curr^.rec);
          curr^.next := nil;
          if hold <> nil then hold^.next := curr;
          hold := curr;
        end;
    close(f);
    hold := curr;
    if   hold <> nil
    then begin
           while hold^.prev <> nil do hold := hold^.prev;
           while hold <> nil do
           begin
             writeln(hold^.rec.name);
             writeln(hold^.rec.age);
             hold := hold^.next;
           end;
           hold := curr;
           while hold <> nil do
             begin
               hold := curr^.prev;
               dispose(curr);
               curr := hold;
             end;
         end;
    if m <> memavail then writeln('heap ''a trouble...');
  End;

Procedure tCollectionExample;  {requires the object unit}
   var p:VObjPtr;
       d:DataPtr;
       f:file of Data;
       m:longint;
   procedure WriteEm(dp:DataPtr); far;
      begin
        writeln(dp^.name);
        writeln(dp^.age);
      end;
   begin
     writeln;
     writeln('object tCollection example ... ');
     m := memavail;
     assign(f,'test.dat');
     new(p,init(5,2));
     reset(f);
     while not eof(f) do
        begin
          new(d);
          system.read(f,d^);
          p^.insert(d);
        end;
     close(f);
     p^.forEach(@WriteEm);
     dispose(p,done);
     if m <> memavail then writeln('heap ''a trouble...');
  end;


Begin
  maketestfile;
  variablearrayexample;
  linkedListExample;
  tcollectionExample;
End.

