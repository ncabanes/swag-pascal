(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0015.PAS
  Description: Buffer Streams
  Author: ALEXANDER STAUBO
  Date: 05-25-94  08:21
*)


{
JB> AS>Use buffered streams.  That way you can access fairly many records on
JB> AS>disk without noticable speed degradation.
JB>                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^
JB> Do you mean from RAM?? Whoah! How do you go about using buffered
JB> streams?

Actually, you should write a local "cache" for your records.  Ie.,
your implement an array of records, say 1..50, or, 1..MaxCacheSize,
where MaxCacheSize is a defined constant.  Then you have a couple of
generalized procedures for putting/getting records; now, the point is,
whenever the program asks for a record -that is in the cache-, that
record is read directly from RAM.  If the record is -not- in the
cache, the record is read, and, if there is space in the cache, the
record is inserted into the cache.

Let's try a Pascal implementation.
}

        const
          MaxCacheSize = 50; (* cache can hold 50 records *)

        type
          (* this is the cache item *)
          PCacheItem = ^TCacheItem;
          TCacheItem =
            record
              Offset : Longint; (* file offset of cache record *)
              Rec    : TRecord; (* use your own record type here *)
            end;

        var
          Cache : array[1..MaxCacheSize] of PCacheItem;
          CacheSize : Word;

        procedure InitCache;
          {-Resets cache}
        begin
          CacheSize:=0;
        end;

        function FindCache (Offset : Longint) : PCacheItem;
          {-Returns cache item for Offset if found, otherwise nil}
        var
          W : Word;
        begin
          for W:=1 to CacheSize do
            if Cache[W]^.Offset = Offset then
              begin
                FindCache:=Cache[W];
                Exit;
              end;
          FindCache:=nil;
        end;

        var
          F : file of TRecord; (* file in question *)

        procedure PutRecord (Offset : Longint; var Rec : TRecord);
          {-Put record into cache and file}
        var
          P : PCacheItem;
        begin
          Write(F, Rec);

          (* if exists in RAM (cache), update it *)
          P:=FindCache(Offset);
          if P <> nil then
            P^.Rec:=Rec
          else
            begin
              (* put into cache *)
              Inc(CacheSize);
              New(Cache[CacheSize]);
              Cache[CacheSize]^.Offset:=Offset;
              Cache[CacheSize]^.Rec:=Rec;
            end;
        end;

        procedure GetRecord (Offset : Longint; var Rec : TRecord);
          {-Get record from cached file}
        var
          P : PCacheItem;
        begin
          (* if exists in RAM (cache), get it *)
          P:=FindCache(Offset);
          if P <> nil then
            Rec:=P^.Rec
          else if CacheSize < MaxCacheSize then
            begin
              (* read record from file *)
              Read(F, Rec);

              (* put into cache *)
              Inc(CacheSize);
              New(Cache[CacheSize]);
              Cache[CacheSize]^.Offset:=Offset;
              Cache[CacheSize]^.Rec:=Rec;
            end;
        end;

To use the routines:

          Assign(F, 'MYFILE.DAT');
          Reset(F);
          GetRecord(FilePos(F), MyRec);
          GetRecord(FilePos(F), MyRec);
          GetRecord(FilePos(F), MyRec);
          PutRecord(FilePos(F), MyRec);
          Close(F);

Or something like that, anyway.

Now, there is a simpler way; "simpler" in this case means "some guy
has already spent hours writing it just for you".  The concept is
called streams.  Now, I don't know how "novice" a programmer you are,
but knowledge of streams requires knowledge of OOP.  I suggest you
read about OOP right away.

Streams work in a very simple way.  You have a basic, "abstract"
object, which provides some simple I/O tools.  A stream is a type of
(abstract) file, an input/output mechanism, that you may manipulate;
most often it's on a hierarchical level, ie., the high-level
procedures call low-level procedures, just like DOS.  Think of streams
as the Pascal type "file", except now the stream is a shell for
anything.

The shell implements a -standard- interface for any kind of
information area.  You have file streams, buffered streams (streams
that caches areas of the file in memory to optimize access
efficiency), EMS streams (yes, you can have a "virtual file" that lies
in EMS memory and may be used just like a file), and so on.  The
standardization implies that you may write more flexible programs.

A tiny example:

        var
          S   : TBufStream;
          T   : TRecord;
          Str : string;
        begin
          S.Init('MYFILE.DAT', stOpen, 2048);
              (* |             |          |
                 file name     file mode  buffer size
              *)
          S.Read(T, SizeOf(T));
          S.Write(T, SizeOf(T));
          Str:=S.ReadStr^;

          S.Done;
        end;

The corresponding boring-old-Dos example'd be:

        var
          F   : file;
          T   : TRecord;
          Str : string;
        begin
          (* note: no buffering -> slower! *)
          Assign(F, 'MYFILE.DAT');
          Reset(F, 1);

          BlockRead(F, T, SizeOf(T));
          BlockWrite(F, T, SizeOf(T));
          Read(F, Str[0]);
          BlockRead(F, Str[1], Ord(Str[0]));

          Close(F);
        end;

In the end, streams -are- simpler, too.  And they are extremely fast;
a friend of mine is writing a mail reader and is using object streams
for the message/conference/etc. databases.  Now, personally I use
indexed, light-speed B-tree databases.  And his work -just fine-.

