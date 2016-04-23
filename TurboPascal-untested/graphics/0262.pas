{
  Gayle, could you please make sure that this is packaged with KOJAKVGA
  3.3, as that is the only unit that uses PCXCache at the moment.
  Thanks.


  FILENAME : PCXCACHE.PAS

  AUTHOR   : SCOTT TUNSTALL B.Sc

  CREATION : 24TH NOVEMBER 1996
  DATE

  PURPOSE  : TO SUPPLEMENT KOJAKVGA'S PCX WRITING ROUTINES WHICH
             SHOULD NOW BE 200% FASTER THAN THE OLDER
             CONTINUOUS DISK ACCESS ROUTINES USED IN NEWGRAPH
             AND OLDER KOJAKVGA VERSIONS.

             THIS UNIT WILL WORK WITH ANY FILE-TYPE HOWEVER.


  TESTING  : TESTED ON P133 W/ 800Mb HARD DISK CAP.
  INFO       (Guess who's started work then? :) )



  DISCLAIMER : USE THIS UNIT AT YOUR OWN RISK. I TAKE NO
               RESPONSIBILITY FOR ANY DAMAGE CAUSED TO YOUR
               PC HARDWARE OR FILES CAUSED BY THESE ROUTINES.

               THEY WORK FINE ON MY PC.


}




Unit PCXCache;


Interface
Procedure InitCache(FileName: string; DoAppend: Boolean);
Procedure FlushCache;
Procedure CacheByte(TheByte: byte);
Procedure CloseCache;


Implementation

Const PCXCacheVersion = $100;   { Version 1.00 }

Var
    CacheHandle:                File;
    CacheFile:                  string[80];
    ContDiskWrite:              boolean;
    CachePtr:                   pointer;
    CacheSeg:                   word;
    CacheOffs:                  word;
    CacheReload:                word;   { To reload CacheOffs }
    CacheStored:                word;
    CacheSize:                  word;



{ Initialise cache.

  Expects: FileName is obvious.
           DoAppend, if set TRUE means 'being writing data at
           end of file <FileName>

  Returns: Nothing

  Affects: I'm NOT documenting registers affected again!
}


Procedure InitCache(FileName: string; DoAppend: Boolean);
Var CacheMemFree: word;
Begin
     CacheFile:=FileName;
     CacheMemFree:=MaxAvail;
     If CacheMemFree < 1024 Then        { If < 1K then no point in cache }
        ContDiskWrite:=True
     Else
         Begin
         ContDiskWrite:=False;
         GetMem(CachePtr,CacheMemFree);
         CacheSize:=CacheMemFree;
         CacheStored:=0;               { Num of bytes storedin cache
                                         When CacheStored = CacheSize
                                         then all data is written to
                                         disk }

         { You didn't think I was going to totally avoid assembler,
           did you? :) }

         Asm LES DI,CachePtr
             MOV CacheSeg  ,ES
             MOV CacheOffs   ,DI
             MOV CacheReload ,DI
         End;
     End;

     Assign(CacheHandle,CacheFile);
     Rewrite(CacheHandle,1);
     If DoAppend Then
        Seek(CacheHandle,FileSize(CacheHandle));
End;




{
  Dump what's currently in the cache to disk. The cache need not
  be full.
}

Procedure FlushCache;
Begin
     If (CacheStored <>0) And Not ContDiskWrite Then  { Can't write 0 bytes ! }
        Begin
        BlockWrite(CacheHandle,CachePtr^,CacheStored);
        CacheOffs:=CacheReload;
        CacheStored:=0;
        End;
End;



{ OK, so it only works with bytes at a time, but it's STILL faster than
  continuous disk access, innit? :)

  If you feel like it, create CacheWord, cacheLong etc.
}

Procedure CacheByte(TheByte: byte);
Begin
     If Not ContDiskWrite Then
        Begin
        Mem[CacheSeg:CacheOffs]:=TheByte;
        Inc(CacheOffs);
        Inc(CacheStored);
        If CacheStored = CacheSize Then
           FlushCache;
        End
     Else
         BlockWrite(CacheHandle,TheByte,1);
End;



{ Finish with cache }

Procedure CloseCache;
Begin
     FlushCache;                        { In case there's any bytes left }
     If Not ContDiskWrite Then
        Begin
        FreeMem(CachePtr,CacheSize);
        CachePtr:=Nil;                  { Indicates cache done with }
        End;
     Close(CacheHandle);                { Close cache file }
End;




{ So you can check version capabilities }

Function GetVersion:word; Assembler;
Asm
   MOV AX,PCXCacheVersion
End;



{ Announce PCXCache routine. }

Begin
     Writeln;
     Writeln('PCX-Cache routines for KOJAKVGA 3.xx units (C) 1996 Scott Tunstall.');
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;
End.
