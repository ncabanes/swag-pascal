(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0057.PAS
  Description: >64K Blockread/Blockwrite
  Author: JOSE CAMPIONE
  Date: 08-25-94  09:04
*)

(*************************************************************************

           =====================================================
           Breaking the 64K barrier for BlockRead and BlockWrite
           =====================================================
                 Copyright (c) 1992,1994 by José Campione
                   Ottawa-Orleans Personal Systems Group
                          Fidonet: 1:163/513.3

 Turbo Pascal implements two procedures for fast transfer of data from 
 files to memory blocks and viceversa: Blockread and Blockwrite. One of 
 the commonly encountered limitation in these procedures is the fact that 
 they can only handle blocks not exceeding 65535 bytes.

 This limitation bears a connection with the often asked question on how 
 to brake the 64K barrier for arrays declared in Pascal. Several answers 
 have been proposed to this effect. Perhaps one of the most elegant is 
 the one proposed by Neil Rubenking in his book on Turbo Pascal 6.0 
 Techniques and Utilities (Ziff-Davis Press, 1991). Albeit elegant, 
 Neil's approach uses OOP which may not be fully appreciated by many 
 Pascal users. 

 So, here is a less ambitious approach with several procedures and 
 functions permitting the direct handling of large memory blocks. In the 
 following unit large memory blocks are defined as arrays of blocks each
 not exceeding 64K. The only limitation for the size of the overall large 
 block is that it must not exceed the normal RAM. A longint pointer is 
 then used to access individual positions. 

 This unit uses a modified heapfunc that permits the replacement of "new" 
 with "getmem". This, together with range checking off, allows an array 
 to be declared as a single byte. During runtime it can be assigned any 
 size determined by the program. This ensures that the "tail" of the big 
 block will never be larger than strictly necessary. 

 Functions BigBlockRead and BigBlockWrite permit the reading and writing 
 of blocks from and to a file much in the same way as Pascal's BlockRead
 and BlockWrite. Only difference is that the 64K limit is not a problem 
 anymore. Note that the size of the blocks can only be defined in terms 
 of bytes and that the file being read or write must have been previously 
 assigned to variable f (an untyped file declared within the unit). Also, 
 these are not procedures but functions returning false if the reading or 
 the writing of the big block was not completed. 

 In the present implementation only one array of big blocks is permitted. 
 Variable BigBlkExist ensures that MakeBig will only work if a previous 
 big block has not been created. BigBlk is the array of blocks reserved 
 in the heap. SizBlk is an array containing the sizes in bytes of each 
 block reserved in the heap as part of the big block. NumVec contains the
 number of blocks used by the big block. 

 And last, some acknowledgements:

 Part of this unit was inspired by code contained in a file posted at 
 garbo.uwasa.fi by Prof. Timo Salmi. The code itself was based on a 
 submission by Naji Moawad. Prof. Salmi's code contained the following 
 message: 

    The code below is based on a UseNet posting in comp.lang.pascal by 
    Naji Mouawad nmouawad@watmath.waterloo.edu. Naji's idea was for a 
    vector, my adaptation is for a two-dimensional matrix. The realization
    of the idea is simpler than the one presented by Kent Porter in 
    Dr.Dobb's Journal, March 1988. 
***************************************************************************)

{$R-} { R has to be off... }
{$M 8096,0,655360}

unit bigarru;

interface

   uses crt,dos;

   const
       SizVec = $FFFF;
       MaxBlk = $FF;

   type
       Vec = array [0..0] of byte;

   var
       BigBlk  : array[0..MaxBlk] of ^Vec;
       SizBlk  : array[0..MaxBlk] of word;
       TotSizBlk : longint;
       NumVec : byte;
       HeapTop : pointer;
       BigBlkExist : boolean;

   {$F+} function HeapFunc(Size: word) : integer; {$F-}
   function MakeBig(HeapNeeded: longint): boolean;
   function Peek(p: longint; var error: boolean): byte;
   procedure Poke(b : byte; p: longint; var error: boolean);
   procedure FillRange(fromby, toby :longint; b : byte);
   procedure FillAll(b: byte);
   function BigBlockRead (var f: file): boolean;
   function BigBlockWrite(var f: file): boolean;

implementation

   {$F+} function HeapFunc(Size: word) : integer; {$F-}
   begin
     HeapFunc:= 1;
   end;

   { Create the dynamic variables }
   { HeapNeeded is the needed number of BYTES }
   function MakeBig(HeapNeeded: longint): boolean;
   var
     i          : integer;
     error      : boolean;
   begin
     error:= false;
     if BigBlkExist then begin
       Makebig:= false;
       exit;
     end;
     fillchar(sizblk,sizeof(sizblk),0);
     NumVec:= (HeapNeeded div SizVec);
     if (HeapNeeded < SizVec) then begin
       SizBlk[NumVec]:= HeapNeeded;
       BigBlk[NumVec]:= nil;
       GetMem(BigBlk[NumVec], SizBlk[NumVec]);
       if BigBlk[NumVec] = nil then error:= true;
     end else begin
       i:= -1;
       while not error and (i < NumVec - 1) do begin
         inc(i,1);
         SizBlk[i]:= SizVec;
         BigBlk[i]:= nil;
         GetMem(BigBlk[i],SizBlk[i]);
         if BigBlk[i] = nil then error:= true;
       end;
       if not error then begin
         SizBlk[NumVec]:= HeapNeeded - ((i + 1) * SizVec);
         BigBlk[NumVec]:= nil;
         GetMem(BigBlk[NumVec], SizBlk[NumVec]);
         if BigBlk[NumVec] = nil then error:= true;
       end;
     end;
     if not error then begin
       TotSizBlk:= HeapNeeded;
       BigBlkExist:= true;
       MakeBig:= true;
     end else begin
       MakeBig:= false;
       release(heaptop);
     end;
   end;  { makebig }

   function Peek(p: longint; var error: boolean): byte;
   var
     VecNum: byte;
     BytNum: word;
   begin
     if BigBlkExist and not (p > totsizblk) then begin
       error:= false;
       VecNum:= p div SizVec;
       BytNum:= p - (VecNum * SizVec);
       peek:= BigBlk[VecNum]^[BytNum];
     end else begin
       error:= true;
       peek:= 0;
     end;
   end;

   procedure Poke(b: byte; p: longint; var error: boolean);
   var
     VecNum: byte;
     BytNum: word;
   begin
      if BigBlkExist and not (p > totsizblk) then begin
        error:= false;
        VecNum:= p div SizVec;
        BytNum:= p - (VecNum * SizVec);
        BigBlk[VecNum]^[BytNum]:= b;
      end else error:= true;
   end;

   procedure FillRange(fromby, toby :longint; b : byte);
   var
     p: longint;
     VecNum: byte;
     BytNum: word;
   begin
     If BigBlkExist then begin
       for p:= fromby to toby do begin
         VecNum:= p div SizVec;
         BytNum:= p - (VecNum * SizVec);
         BigBlk[VecNum]^[BytNum]:= b;
       end;
     end;
   end;

   procedure FillAll(b: byte);
   var
     i : byte;
   begin
     if BigBlkExist then
       for i:= 0 to NumVec do
         fillchar(BigBlk[i]^,SizBlk[i],b);
   end;

   function BigBlockRead (var f: file): boolean;
   var
     i : integer;
     error : boolean;
   begin
     error:= false;
     BigBlockRead:= true;
     {$I-} reset(f,1); {$I+}
     if (ioresult = 0) and bigblkexist then begin
       i:= -1;
       while not error and (i < NumVec) do begin
         inc(i,1);
         {$I-} BlockRead(f,BigBlk[i]^,SizBlk[i]); {$I+}
         if ioresult <> 0 then error:= true;
       end;
       if not error then {$I-}close(f){$I+} else BigBlockRead:= false;
     end else BigBlockRead:= false;
   end;

   function BigBlockWrite(var f: file): boolean;
   var
     i : integer;
     error : boolean;
   begin
     error:= false;
     BigBlockWrite:= true;
     {$I-} rewrite(f,1); {$I+}
     if (ioresult = 0) and bigblkexist then begin
       i:= -1;
       while not error and (i < NumVec) do begin
         inc(i,1);
         {$I-} BlockWrite(f,BigBlk[i]^,SizBlk[i]); {$I+}
         if ioresult <> 0 then error:= true;
       end;
       if not error then {$I-}close(f){$I+} else BigBlockWrite:= false;
     end else BigBlockWrite:= false;
   end;

begin
  heaperror:= @heapfunc;
  BigBlkExist:= false;
  mark(heaptop);
end.


