(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0029.PAS
  Description: RDC Compression
  Author: MIKE CHAPIN
  Date: 02-28-95  10:05
*)


{
Well here it is as promised. This is a Pascal port of Ross
Data compression. This particular unit does no buffer
compression/decompression but you can add it if you want.
The C implementation I did has Buffer to file compression
and file to buffer decompression.

This is a freebie and is availble for SWAG if they
want it.


Common data types unit I use a lot. Looks like Delphi
incorporated similar types.

}
(*
  Common data types and structures.
*)

Unit Common;
Interface

Type
  PByte = ^Byte;
  ByteArray = Array[0..65000] Of Byte;
  PByteArray = ^ByteArray;

  PInteger = ^Integer;
  IntArray = Array[0..32000] Of Integer;
  PIntArray = ^IntArray;

  PWord = ^Word;
  WordArray = Array[0..32000] Of Word;
  PWordArray = ^WordArray;

Implementation

END.

(***************************************************
 * RDC Unit                                        *
 *                                                 *
 * This is a Pascal port of C code from an article *
 * In "The C Users Journal", 1/92 Written by       *
 * Ed Ross.                                        *
 *                                                 *
 * This particular code has worked well under,     *
 * Real, Protected and Windows.                    *
 *                                                 *
 * The compression is not quite as good as PKZIP   *
 * but it decompresses about 5 times faster.       *
 ***************************************************)
Unit RDCUnit;
Interface
Uses
  Common;

Procedure Comp_FileToFile(Var infile, outfile: File);
Procedure Decomp_FileToFile(Var infile, outfile: File);

Implementation
Const
  HASH_LEN =  4096;    { # hash table entries }
  HASH_SIZE = HASH_LEN * Sizeof(word);
  BUFF_LEN = 16384;    { size of disk io buffer }


(*
 compress inbuff_len bytes of inbuff into outbuff
 using hash_len entries in hash_tbl.

 return length of outbuff, or "0 - inbuff_len"
 if inbuff could not be compressed.
*)
Function rdc_compress(ibuff      : Pointer;
                      inbuff_len : Word;
                      obuff      : Pointer;
                      htable     : Pointer) : Integer;
Var
  inbuff      : PByte Absolute ibuff;
  outbuff     : PByte Absolute obuff;
  hash_tbl    : PWordArray Absolute htable;
  in_idx      : PByte;
  in_idxa     : PByteArray absolute in_idx;
  inbuff_end  : PByte;
  anchor      : PByte;
  pat_idx     : PByte;
  cnt         : Word;
  gap         : Word;
  c           : Word;
  hash        : Word;
  hashlen     : Word;
  ctrl_idx    : PWord;
  ctrl_bits   : Word;
  ctrl_cnt    : Word;
  out_idx     : PByte;
  outbuff_end : PByte;
Begin
  in_idx := inbuff;
  inbuff_end := Pointer(LongInt(inbuff) + inbuff_len);
  ctrl_idx := Pointer(outbuff);
  ctrl_cnt := 0;

  out_idx := Pointer(longint(outbuff) + Sizeof(Word));
  outbuff_end := Pointer(LongInt(outbuff) + (inbuff_len - 48));

  { skip the compression for a small buffer }

  If inbuff_len <= 18 Then
  Begin
    Move(outbuff, inbuff, inbuff_len);
    rdc_compress := 0 - inbuff_len;
    Exit;
  End;

  { adjust # hash entries so hash algorithm can
    use 'and' instead of 'mod' }

  hashlen := HASH_LEN - 1;

  { scan thru inbuff }

  While LongInt(in_idx) < LongInt(inbuff_end) Do
  Begin
    { make room for the control bits
      and check for outbuff overflow }

    If ctrl_cnt = 16 Then
    Begin
      ctrl_idx^ := ctrl_bits;
      ctrl_cnt := 1;
      ctrl_idx := Pointer(out_idx);
      Inc(word(out_idx), 2);
      If LongInt(out_idx) > LongInt(outbuff_end) Then
      Begin
        Move(outbuff, inbuff, inbuff_len);
        rdc_compress := inbuff_len;
        Exit;
      End;
    End
    Else
      Inc(ctrl_cnt);

      { look for rle }

      anchor := in_idx;
      c := in_idx^;
      Inc(in_idx);

      While (LongInt(in_idx) < longint(inbuff_end))
            And (in_idx^ = c)
            And (LongInt(in_idx) - LongInt(anchor) < (HASH_LEN + 18)) Do
        Inc(in_idx);

      { store compression code if character is
        repeated more than 2 times }

      cnt := LongInt(in_idx) - LongInt(anchor);
      If cnt > 2 Then
      Begin
        If cnt <= 18 Then     { short rle }
        Begin
          out_idx^ := cnt - 3;
          Inc(out_idx);
          out_idx^ := c;
          Inc(out_idx);
        End
        Else                    { long rle }
        Begin
          Dec(cnt, 19);
          out_idx^ := 16 + (cnt and $0F);
          Inc(out_idx);
          out_idx^ := cnt Shr 4;
          Inc(out_idx);
          out_idx^ := c;
          Inc(out_idx);
        End;

        ctrl_bits := (ctrl_bits Shl 1) Or 1;
        Continue;
      End;

      { look for pattern if 2 or more characters
        remain in the input buffer }

      in_idx := anchor;

      If (LongInt(inbuff_end) - LongInt(in_idx)) > 2 Then
      Begin
        { locate offset of possible pattern
          in sliding dictionary }

        hash := ((((in_idxa^[0] And 15) Shl 8) Or in_idxa^[1]) Xor
                 ((in_idxa^[0] Shr 4) Or (in_idxa^[2] Shl 4)))
                 And hashlen;

        pat_idx := in_idx;
        Word(pat_idx) := hash_tbl^[hash];
        hash_tbl^[hash] := Word(in_idx);

        { compare characters if we're within 4098 bytes }

        gap := LongInt(in_idx) - LongInt(pat_idx);
        If (gap <= HASH_LEN + 2) Then
        Begin
          While (LongInt(in_idx) < LongInt(inbuff_end))
                And (LongInt(pat_idx) < LongInt(anchor))
                And (pat_idx^ = in_idx^)
                And (LongInt(in_idx) - LongInt(anchor) < 271) Do
          Begin
            Inc(in_idx);
            Inc(pat_idx);
          End;

          { store pattern if it is more than 2 characters }

          cnt := LongInt(in_idx) - LongInt(anchor);
          If cnt > 2 Then
          Begin
            Dec(gap, 3);

            If cnt <= 15 Then     { short pattern }
            Begin
              out_idx^ := (cnt Shl 4) + (gap And $0F);
              Inc(out_idx);
              out_idx^ := gap Shr 4;
              Inc(out_idx);
            End
            Else                    { long pattern }
            Begin
              out_idx^ := 32 + (gap And $0F);
              Inc(out_idx);
              out_idx^ := gap Shr 4;
              Inc(out_idx);
              out_idx^ := cnt - 16;
              Inc(out_idx);
            End;

            ctrl_bits := (ctrl_bits Shl 1) Or 1;
            Continue;
          End;
        End;
      End;

      { can't compress this character
        so copy it to outbuff }

      out_idx^ := c;
      Inc(out_idx);
      Inc(anchor);
      in_idx := anchor;
      ctrl_bits := ctrl_bits Shl 1;
  End;

  { save last load of control bits }

  ctrl_bits := ctrl_bits Shl (16 - ctrl_cnt);
  ctrl_idx^ := ctrl_bits;

  { and return size of compressed buffer }

  rdc_compress := LongInt(out_idx) - LongInt(outbuff);
End;

(*
 decompress inbuff_len bytes of inbuff into outbuff.

 return length of outbuff.
*)
Function RDC_Decompress(inbuff     : PByte;
                        inbuff_len : Word;
                        outbuff    : PByte) : Integer;
Var
  ctrl_bits    : Word;
  ctrl_mask    : Word;
  inbuff_idx   : PByte;
  outbuff_idx  : PByte;
  inbuff_end   : PByte;
  cmd, cnt     : Word;
  ofs, len     : Word;
  outbuff_src  : PByte;
Begin
  ctrl_mask := 0;
  inbuff_idx := inbuff;
  outbuff_idx := outbuff;
  inbuff_end := Pointer(LongInt(inbuff) + inbuff_len);

  { process each item in inbuff }
  While LongInt(inbuff_idx) < LongInt(inbuff_end) Do
  Begin
    { get new load of control bits if needed }
    ctrl_mask := ctrl_mask Shr 1;
    If ctrl_mask = 0 Then
    Begin
      ctrl_bits := PWord(inbuff_idx)^;
      Inc(inbuff_idx, 2);
      ctrl_mask := $8000;
    End;

    { just copy this char if control bit is zero }
    If (ctrl_bits And ctrl_mask) = 0 Then
    Begin
      outbuff_idx^ := inbuff_idx^;
      Inc(outbuff_idx);
      Inc(inbuff_idx);
      Continue;
    End;

    { undo the compression code }
    cmd := (inbuff_idx^ Shr 4) And $0F;
    cnt := inbuff_idx^ And $0F;
    Inc(inbuff_idx);

    Case cmd Of
      0 :     { short rle }
      Begin
        Inc(cnt, 3);
        FillChar(outbuff_idx^, cnt, inbuff_idx^);
        Inc(inbuff_idx);
        Inc(outbuff_idx, cnt);
      End;

      1 :     { long rle }
      Begin
        Inc(cnt,  inbuff_idx^ Shl 4);
        Inc(inbuff_idx);
        Inc(cnt, 19);
        FillChar(outbuff_idx^, cnt, inbuff_idx^);
        Inc(inbuff_idx);
        Inc(outbuff_idx, cnt);
      End;

      2 :     { long pattern }
      Begin
        ofs := cnt + 3;
        Inc(ofs, inbuff_idx^ Shl 4);
        Inc(inbuff_idx);
        cnt := inbuff_idx^;
        Inc(inbuff_idx);
        Inc(cnt, 16);
        outbuff_src := Pointer(LongInt(outbuff_idx) - ofs);
        Move(outbuff_src^, outbuff_idx^, cnt);
        Inc(outbuff_idx, cnt);
      End;

      Else    { short pattern}
      Begin
        ofs := cnt + 3;
        Inc(ofs, inbuff_idx^ Shl 4);
        Inc(inbuff_idx);
        outbuff_src := Pointer(LongInt(outbuff_idx) - ofs);
        Move(outbuff_src^, outbuff_idx^, cmd);
        Inc(outbuff_idx, cmd);
      End;
    End;
  End;

  { return length of decompressed buffer }
  RDC_Decompress := LongInt(outbuff_idx) - LongInt(outbuff);
End;

Procedure Comp_FileToFile(Var infile, outfile: File);
Var
  code         : Integer;
  bytes_read   : Integer;
  compress_len : Integer;
  HashPtr      : PWordArray;
  inputbuffer,
  outputbuffer : PByteArray;
Begin
  Getmem(HashPtr, HASH_SIZE);
  Fillchar(hashPtr^, HASH_SIZE, #0);
  Getmem(inputbuffer, BUFF_LEN);
  Getmem(outputbuffer, BUFF_LEN);

  { read infile BUFF_LEN bytes at a time }

  bytes_read := BUFF_LEN;
  While bytes_read = BUFF_LEN Do
  Begin
    Blockread(infile, inputbuffer^, BUFF_LEN, bytes_read);

    { compress this load of bytes }
    compress_len := RDC_Compress(PByte(inputbuffer), bytes_read,
                                 PByte(outputbuffer), HashPtr);

    { write length of compressed buffer }
    Blockwrite(outfile, compress_len, 2, code);

    { check for negative length indicating the buffer could not be compressed }
    If compress_len < 0 Then
      compress_len := 0 - compress_len;

    { write the buffer }
    Blockwrite(outfile, outputbuffer^, compress_len, code);
    { we're done if less than full buffer was read }
  End;

  { add trailer to indicate End of File }
  compress_len := 0;
  Blockwrite(outfile, compress_len, 2, code);
  {
  If (code <> 2) then
     err_exit('Error writing trailer.'+#13+#10);
  }
  Freemem(HashPtr, HASH_SIZE);
  Freemem(inputbuffer, BUFF_LEN);
  Freemem(outputbuffer, BUFF_LEN);
End;

Procedure Decomp_FileToFile(Var infile, outfile: File);
Var
  code         : Integer;
  block_len    : Integer;
  decomp_len   : Integer;
  HashPtr      : PWordArray;
  inputbuffer,
  outputbuffer : PByteArray;
Begin
  Getmem(inputbuffer, BUFF_LEN);
  Getmem(outputbuffer, BUFF_LEN);
  { read infile BUFF_LEN bytes at a time }
  block_len := 1;
  While block_len <> 0 do
  Begin
    Blockread(infile, block_len, 2, code);
    {
    If (code <> 2) then
      err_exit('Can''t read block length.'+#13+#10);
    }
    { check for End-of-file flag }
    If block_len <> 0 Then
    Begin
      If (block_len < 0) Then { copy uncompressed chars }
      Begin
        decomp_len := 0 - block_len;
        Blockread(infile, outputbuffer^, decomp_len, code);
        {
        If code <> decomp_len) then
          err_exit('Can''t read uncompressed block.'+#13+#10);
        }
      End
      Else                { decompress this buffer }
      Begin
        Blockread(infile, inputbuffer^, block_len, code);
        {
        If (code <> block_len) then
          err_exit('Can''t read compressed block.'+#13+#10);
        }
        decomp_len := RDC_Decompress(PByte(inputbuffer), block_len,
                                     PByte(outputbuffer));
      End;
      { and write this buffer outfile }
      Blockwrite(outfile, outputbuffer^, decomp_len, code);
      {
      if (code <> decomp_len) then
        err_exit('Error writing uncompressed data.'+#13+#10);
      }
    End;
  End;

  Freemem(inputbuffer, BUFF_LEN);
  Freemem(outputbuffer, BUFF_LEN);
End;

END.

<------------------- CUT ------------------------->

Here is the test program I used to test this. You will
have to change it to reflect other file names but it
will give you an idea of how to use the unit.

<------------------- CUT ------------------------->
Program RDCTest;
Uses
  RDCUnit;

Var
  fin, fout : File;
  a         : Array[0..50] Of Byte;

BEGIN
{
  Assign(fin, 'ASMINTRO.TXT');
  Reset(fin, 1);

  Assign(fout, 'ASMINTRO.RDC');
  Rewrite(fout, 1);

  Comp_FileToFile(fin, fout);
}
  Assign(fin, 'ASMINTRO.RDC');
  Reset(fin, 1);

  Assign(fout, 'ASMINTRO.2');
  Rewrite(fout, 1);

  Decomp_FileToFile(fin, fout);

  Close(fin);
  Close(fout);
END.

