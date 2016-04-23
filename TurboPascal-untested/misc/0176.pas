unit ScaleStr ;
interface

function ScaleFill( C1 , C2 : Char ; Len : byte ; Part : Real ) : String ;
function FoxScaleFill( C1 : Char ; Len : byte ; Part : Real ) : String ;
function FoxScale( C1 : Char ; Len : byte ; Part : Real ) : String ;
function SRScaleFill( Len : byte ; Part : Real ) : String ;

const

      OnlyOne   : Boolean = FALSE ;
      A_La_Zip  : Boolean = FALSE ;
      A_La_ZipM : Boolean = FALSE ;

implementation

const
    maxC = 23;
    minC = 0 ;
    CurC   : Byte = 0  ;

type
    CharsT = array[ minC .. maxC ] of char ;

function SRScaleFill( Len : byte ; Part : Real ) : String ;
var
   s      : String ;
   l      : word   ;
begin
   s[ 0 ] := Chr( Len ) ;
   FillChar( S[ 1 ] , Len , #249 ) ;
   if ( Part < 1 ) and ( Part >= 0 ) then
      l := Round( Len * Part * 2 )
   else
      l := Len shl 1 ;
   if l > 0 then
   begin
      if odd( l ) then
         s[ l shr 1 + 1 ] := #221
      else
         s[ l shr 1 ] := #222
   end
   else
      s[ 1 ] := #221 ;
   SRScaleFill := S ;
end ;

function FoxScaleFill ;
var
   s      : String ;
   l      : Word   ;
begin
   s[ 0 ] := Chr( Len ) ;
   FillChar( S[ 1 ] , Len , C1 ) ;
   if ( Part < 1 ) and ( Part >= 0 ) then
      l := Round( Len * Part * 2 )
   else
      l := Len shl 1 ;
   if l > 0 then
   begin
      FillChar( S[ 1 ] , l shr 1 , #219 ) ;
      if odd( l ) then
         s[ l shr 1 + 1 ] := #221
   end
   else
      s[ 1 ] := #221 ;
   FoxScaleFill := S ;
end ;

Function FoxScale ;
Var
   S      : string ;
   L      : word   ;
begin
   if ( Part < 1 ) and ( Part >= 0 ) then
      L := Round( Len * Part )
   else
      L := Len  ;
   S[0] := Chr( L ) ;
   FillChar( S[ 1 ] , L , C1 ) ;
   FoxScale := S ;
end ;

function ScaleFill( C1 , C2 : Char ; Len : byte ; Part : Real ) : String ;
var
   s      : String ;
   l      : byte   ;
   CC,
   CX,CL  : CharsT ;
begin
   CL := '//--\\//--\\//--\\//--\\' ;
   CX := '////////--------\\\\\\\\' ;
   s[ 0 ] := Chr( Len ) ;
   FillChar( S[ 1 ] , Len , C2 ) ;
   if ( Part < 1 ) and ( Part >= 0 ) then
      l := Round( Len * Part )
   else
      l := Len ;

   if ( Not OnlyOne ) then
      FillChar( S[ 1 ] , L , C1 ) ;
   if A_La_Zip then
     CC := CL ;
   if A_La_ZipM then
     CC := CX ;

   if A_La_Zip or A_La_ZipM  then
   begin
      if l > 0 then
      begin
         s[ l ] := CC[ CurC ] ;
         if Part = 1.0 then
           s[ l ] := ' ' ;
      end
      else
         s[ 1 ] := CC[ CurC ] ;
      inc( CurC ) ;
      if CurC > MaxC then
         CurC := MinC ;
   end
   else
      if OnlyOne then
      begin
         if l > 0 then
            s[ l ] := C1
         else
            s[ 1 ] := C1
      end ;
   ScaleFill := S ;
end ;

end .
