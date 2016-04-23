{
   So does anyone have any good read-write routines that
   will read/write words of bit legnths 9-13?
}

function add_code : integer;
  const Input_bit_count : integer = 0;
        Inbuf : longint =0;
  var i : longint;
  begin
    while input_bit_count <= 24 do
    begin
      i := getnextbyte; { shftL/R is an asm longint shift }
      InBuf := InBuf or shftL(i,24-input_bit_count);
      inc(input_bit_count,8);
    end;
    i := shftR(InBuf,32-num_bits);
    InBuf := shftL(InBuf,num_bits);
    input_bit_count := input_bit_count -num_bits;
    add_code := i;
  end;

procedure add_code (code:word);
  const bits : integer = 0;
  begin
    lz_buffer[lz_cnt] := lo(bit_buf or (code shl bits));
    inc(lz_cnt);
    if (code_len + bits) < 16
    then begin
           bit_buf := lo(code shr (8-bits));
           bits := bits +code_len -8;
         end
    else begin
           lz_buffer[lz_cnt] := lo(code shr (8-bits));
           inc(lz_cnt);
           bit_buf := lo(code shr (16-bits));
           bits := (bits + code_len -16);
         end;
  end;
