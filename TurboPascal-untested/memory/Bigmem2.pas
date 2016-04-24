(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0002.PAS
  Description: BIGMEM2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{
BP7 is not limited to 16Meg of memory, by running the Program below in a
Windows 3.1 Window, it created 744 Objects allocating 30Meg of memory. The
final printout verified that all the items were still there.

So if you use a third party DPMI server, you should be able to use all your
memory.

I might point out that I allocated 30Meg of memory on my 16Meg machine. I run
Windows 3.1 With a 32Meg permanent swap File.
}

Program BigMemory;
Uses
 OpStrDev,Objects;

Type
 PDataType=^DataType;
 DataType=Object(tObject)
   C:LongInt;
   S:String;
   Stuffing:Array[1..40000] of Byte;
   Constructor Init(I:LongInt);
 end;
Var
 Counter:LongInt;
 List:TCollection;

Constructor DataType.Init(I:LongInt);
begin
 tObject.Init;
 C:=I;
 Write(tpstr,'I = ',I,' I div 2 =',I div 2);
 S:=returnstr;
end;

Procedure Printall;
 Procedure PrintOne(P:PDataType);Far;
 begin
   Writeln(P^.C,' - ',P^.S);
 end;
begin
 List.Foreach(@PrintOne);
end;

begin
 Counter:=0;
 List.Init(1000,1000);
 Repeat
   inc(Counter);
   List.Insert(New(PDataType,Init(Counter)));
   Write(Counter,' mem =',Memavail,^M);
 Until Memavail<50000;
 PrintAll;
end.

