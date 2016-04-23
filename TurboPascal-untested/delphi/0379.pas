
Jon Gilkison wrote:
>
> Anyone have code to convert degrees to radians? 8)
>
> Jon.Gilkison;

Here's a couple of different approaches; first the cannonical function
definition (converted from an old BASIC math library):

------------------------>8 cut here 8<------------------------
function Deg2Rad( Degrees : extended ) : extended ;
(* convert degress to radians *)
begin
  Deg2Rad := ( PI * Degrees ) / 180.0 ;
end (* function Deg2Rad *) ;

function Rad2Deg( Rads : extended ) : extended ;
(* convert radians to degrees *)
begin
  Rad2Deg := ( Rads * 180.0 ) / PI ;
end (* function Rad2Deg *) ;
------------------------>8 cut here 8<------------------------



These are stolen from a Pascal math library I found on the net:

------------------------>8 cut here 8<------------------------
const
  ONE_RAD   = 57.295779513082320876798155;   { 1 rad in degs }
  ONE_DEG   =  0.017453292519943295769237;   { 1 deg in rads }

function deg_to_rad(x : extended ): extended;
{ convert degrees to radians }
begin
  deg_to_rad := ONE_DEG * x
end;

function rad_to_deg(x : extended): extended ;
{ convert radians to degrees }
begin
  rad_to_deg := ONE_RAD * x
end;
