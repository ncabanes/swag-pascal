(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0003.PAS
  Description: Line counter
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

{
>I'm wondering if anyone can post me a source For another way to
>find out the max lines in a Text File.
}

 {.$DEFinE DebugMode}

 {$ifDEF DebugMode}

   {$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V+,X-}

 {$else}

   {$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}

 {$endif}

 {$M 1024,0,0}

Program LineCounter;

Const
  co_LineFeed = 10;

Type
  byar_60K = Array[1..61440] of Byte;

Var
  wo_Index,
  wo_BytesRead : Word;

  lo_FileSize,
  lo_BytesProc,
  lo_LineCount : LongInt;

  fi_Temp      : File;

  byar_Buffer  : byar_60K;

begin
              (* Attempt to open TEST.doC File.                       *)
  assign(fi_Temp, 'linecnt.pas');
  {$I-}
  reset(fi_Temp, 1);
  {$I+}

              (* Check if attempt was sucessful.                      *)
  if (ioresult <> 0) then
    begin
      Writeln('ERRor opening TEST.doC File');
      halt
    end;

              (* Record the size in Bytes of TEST.doC .               *)
  lo_FileSize := Filesize(fi_Temp);

              (* Initialize Variables.                                *)
  lo_LineCount := 0;
  lo_BytesProc := 0;

              (* Repeat Until entire File has been processed.         *)
  Repeat
              (* Read in all or a 60K chunk of TEST.doC into the      *)
              (* "buffer" For processing.                             *)
    blockread(fi_Temp, byar_Buffer, sizeof(byar_60K), wo_BytesRead);

              (* Count the number of line-feed Characters in the      *)
              (* "buffer".                                            *)
    For wo_Index := 1 to wo_BytesRead do
      if (byar_Buffer[wo_Index] = co_LineFeed) then
        inc(lo_LineCount);

              (* Record the number of line-feeds found in the buffer. *)
    inc(lo_BytesProc, wo_BytesRead)

  Until (lo_BytesProc = lo_FileSize);

              (* Close the TEST.doC File.                             *)
  close(fi_Temp);

              (* Display the results.                                 *)
  Writeln(' total number of lines in LinECNT.PAS = ', lo_LineCount)

end.
{
  ...to find a specific line, you'll have to process the Text File up
  to the line you are after, then use a "seek" so that you can read
  in just this line into a String Variable. (You'll have to determine
  the length of the String, and then set the String's length-Byte.)
}
