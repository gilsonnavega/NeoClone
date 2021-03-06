unit gamewindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Addresses, map;

type
  TGameWindow = class
  private

    FMap: TMap;

  public

    function getSize(): TRect;
    function getSize2(): TRect;
    function absoluteToCursor( x,y: integer ): TRect;
    function map2mouse( x,y,z: integer ): TPoint;
function GetGameWindow(): TRect;

    property Map: TMap read FMap;

  published
    constructor Create; overload;
    destructor Destroy; override;
  end;


implementation

uses
  Unit1;

constructor TGameWindow.Create;
begin
  inherited;

  FMap := TMap.Create;
end;

destructor TGameWindow.Destroy;
begin
  FMap.Free;

  inherited;
end;
                     {function from a guy in tpforum... but doesnt work... wtf}
function TGameWindow.GetGameWindow(): TRect;
var
p,offset1,offset2,rx,ry,rw,rh: integer;
begin
 p := Memory.ReadInteger(Integer(ADDR_BASE) + Addresses.GUIPointer);
             offset1 := Memory.ReadInteger(p + Addresses.ClientGameWindow);
             offset2 := Memory.ReadInteger(offset1 + Addresses.ClientFirstChild);

             rx := Memory.ReadInteger(offset2 + Addresses.ClientY);
             ry := Memory.ReadInteger(offset2 + Addresses.ClientY);
             rw := Memory.ReadInteger(offset2 + Addresses.ClientWidth);
             rh := Memory.ReadInteger(offset2 + Addresses.ClientHeight);
             showmessage(inttostr(rw));
         //   result:= new Rectangle(rx, ry, rw, rh);
   result.Left := rx;
  result.Top := ry;
  result.Right := rw;
  result.Bottom :=rh;
  end;


function TGameWindow.getSize(): TRect;
var
  tmp, i: integer;
begin                              //yo have to be logged!
  tmp := Memory.ReadPointer(Integer(ADDR_BASE) + Addresses.guiPointer, [ $30, $24 ] ); // game window

  result.Left := Memory.ReadInteger( tmp + $14); //  X left grey stuff
  result.Top := Memory.ReadInteger( tmp + $18);  //  Y top grey stuff
  result.Right := Memory.ReadInteger( tmp + $1c); // Width of the char screen
  result.Bottom := Memory.ReadInteger( tmp + $20);// Height of the char screen
  //   showmessage(inttostr(result.Left)+':Left  '+inttostr(result.Top)+':Top  '+inttostr(result.right)+':right  '+inttostr(result.bottom)+':bottom  ');
end;

function TGameWindow.getSize2(): TRect;
var
  num, i,x ,y: integer;
  r: TRect;
begin
getwindowrect(Main.THand,r);
       num := Memory.ReadInteger(Integer(ADDR_BASE) +GUIpointer);
       x := Memory.ReadInteger(num + 20);
       y := Memory.ReadInteger(num + $18);
     showmessage(inttostr(r.Right-r.Left)+':X  '+inttostr(r.Bottom-r.Top)+':Y  ');
end;

function TGameWindow.absoluteToCursor( x,y: integer ): TRect;
var
  r: TRect;
  player: TPoint;
  tileWidth, tileHeight: integer;
begin

  r := getSize();
  player.X := Gui.Player.getLocation.X;
  player.Y := Gui.Player.getLocation.Y;

  tileWidth := round( r.Right / 15 );   // 7 de cada lado + 1 del char
  tileHeight := round( r.Bottom / 11 );   // 5 de cada lado + 1 del char

  player.X := player.X - 7; // x lewego g�rnego rogu
  player.Y := player.Y - 5; // y lewego g�rnego rogu

  result.Left := x - player.X;
  result.Top := y - player.Y;

  result.Left := (tileWidth * result.Left);
  result.Top := (tileHeight * result.Top);
  result.Right := tileWidth;
  result.Bottom := tileHeight;

end;

function TGameWindow.map2mouse( x,y,z: integer ): TPoint;
var
gLoc: TLocation;
d,s: TRect;
begin
  result.X:=0; result.Y:=0; //we reset them just in case

  gloc := Gui.Player.getLocation();
             //if not in our visible game window...
  if (Abs(gLoc.X - X) > 7) or (Abs(gLoc.Y - Y) > 5) or (z <> gLoc.Z) then
    exit;

  d := GUI.GameWindow.getSize();
  s := GUI.GameWindow.absoluteToCursor( X, Y );   //Z not needed

  result.X:= d.Left + s.Left + round(s.Right / 2);
  result.Y:= d.Top  + s.Top  + round(s.Bottom / 2);
end;

end.
