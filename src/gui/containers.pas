unit containers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Addresses, containerWindows, math, inputer, player;

type
  TContainers = class
  private
    FWindow: TWindow;
    FContainers: array[0..14] of TContainer;
  public
    procedure refreshContainers();

    function findItem( itemId: integer; locationItem: string = '' ): TItemLoc;
    function useItem( itemId: integer; locationItem: string = '';uselocation: string=''): boolean;

    function getSize: TRect;

    procedure closeWindows( location: string = ''; onlyfirst: boolean = false );
    procedure resizeWindows( size: integer = 0; location: string = ''; onlyfirst: boolean = false );

    property Window: TWindow read FWindow;

  published
    constructor Create; overload;
    destructor Destroy; override;
  end;

implementation

uses
  unit1;

constructor TContainers.Create;
begin
  inherited;

  FWindow := TWindow.Create;
end;

destructor TContainers.Destroy;
begin
  FWindow.Free;

  inherited;
end;

{function TContainers.getItem( item: integer ): TContainer;
begin
  result := FItems[item];
end;
}
procedure TContainers.refreshContainers(); // dupa dupa cycki...
var
  i,j, count: integer;
  addr, itemaddr: integer;
begin

  addr := Addresses.containersAddr;
  for i := 0 to 14 do
  begin

    FContainers[i].name := memory.ReadString(Integer(ADDR_BASE) +  addr + Addresses.ContainersName + ( i * Addresses.ContainersStep ) );
    FContainers[i].itemId := memory.ReadInteger(Integer(ADDR_BASE) +  addr + Addresses.ContainersId + ( i * Addresses.ContainersStep ) );
    FContainers[i].slots := memory.ReadInteger(Integer(ADDR_BASE) +  addr + Addresses.ContainersVolume + ( i * Addresses.ContainersStep ) );
    FContainers[i].filled := memory.ReadInteger(Integer(ADDR_BASE) +  addr + Addresses.ContainersAmout + ( i * Addresses.ContainersStep ) );
    FContainers[i].isOpened := inttobool(memory.ReadInteger(Integer(ADDR_BASE) +  addr + Addresses.ContainersIsOpen + ( i * Addresses.ContainersStep ) ));
    FContainers[i].isChild := inttobool(memory.ReadInteger(Integer(ADDR_BASE) +  addr + Addresses.ContainersIsChild + ( i * Addresses.ContainersStep ) ));

    itemaddr :=Integer(ADDR_BASE) +  addr + Addresses.ContainersItemsStart + ( i * Addresses.ContainersStep );
    for j := 0 to FContainers[i].slots-1 do
    begin
      FContainers[i].items[j].count := memory.ReadInteger( itemaddr + Addresses.ContainersItemCount + ( j * Addresses.ContainersItemStep ) );
      FContainers[i].items[j].id := memory.ReadInteger( itemaddr + Addresses.ContainersItemId + ( j * Addresses.ContainersItemStep ) );
    end;

  end;

end;

function TContainers.findItem( itemId: integer; locationItem: string = '' ): TItemLoc;
var
  i, j: integer;
  name: string;
begin
  refreshContainers();
  result.found := false;
  if locationItem = '' then
  begin
    result.ground := false;
    result.slot := -1;
    for i := 0 to 14 do
    begin

      if FContainers[i].isOpened then
      begin
        for j := 0 to FContainers[i].filled do
        begin
          if FContainers[i].items[j].id = itemId then
          begin
            result.found := true;
            result.container := i;
            result.containerName := FContainers[i].name;
            result.slot := j+1; // +1 cuz of the j=0
            break;
          end;
        end;
      end;
      if result.found then break;
    end;
  end else
  begin
    result.ground := false;
    result.slot := -1;
    for i := 0 to 14 do
    begin
      if (FContainers[i].isOpened) and (pos(lowercase(locationItem), lowercase(FContainers[i].name)) > 0) then
      begin
        for j := 0 to FContainers[i].filled do
        begin
          if FContainers[i].items[j].id = itemId then
          begin
            result.found := true;
            result.container := i;
            result.containerName := FContainers[i].name;
            result.slot := j+1; // +1 cuz of the j=0
            break;
          end;
        end;
      end;
      if result.found then break;
    end;
  end;
end;

function TContainers.useItem( itemId: integer; locationItem: string = '' ;uselocation: string=''): boolean;
var
  hotkeyId: integer;
  itemLoc: TItemLoc;
  addr, i: integer;
  r,d,s: TRect;
  gLoc: TLocation;
  tile: TTile;
  canContinue: boolean;
player: Tplayer;
begin
if not Gui.Player.OnLine then exit;
  result := false;
  if uselocation = '' then uselocation:= 'Self';

  if (pos('ground', locationItem) = 0) then
  begin
    hotkeyId := Gui.TibiaHotKey.Find( itemId );
    if hotkeyId > -1 then
    begin
      // znaleziono w hotkeyu --found in hotkeyu
      Gui.TibiaHotKey.ID := hotkeyId;
      Gui.TibiaHotKey.ExecuteHotkey();
      if (uselocation = 'Self') then
        begin
        if Gui.TibiaHotkey.ObjectType = 2 then
          result := true
        else if (Gui.TibiaHotkey.ObjectType = 1) or (Gui.TibiaHotkey.ObjectType = 0) then
          begin
          gloc := Player.getLocation();
          d := GUI.GameWindow.getSize();
          s := GUI.GameWindow.absoluteToCursor( gLoc.x, gLoc.y );   //we click on us :D
          Inputer.SendClick( d.Left + s.Left + round(s.Right / 2), d.Top + s.Top + round(s.Bottom / 2) );
          result:= true;
          end;
        end;
    end else              //WE HAVE TO FIX THE CONTAINERS PART
    begin         {
      itemLoc := findItem( itemId, locationItem );
      if (itemLoc.found) and (itemLoc.ground = false) then
      begin
        // znaleziono w bp --found in bp
        addr := Window.getAddressByName( itemLoc.containerName );
        r := Window.scrollToSlot( addr, itemLoc.slot );
        Inputer.SendRClick( r.CenterPoint.X, r.CenterPoint.Y );
        result := true;
      end;                  }
    end;
  end else
  begin      //map
    canContinue := ( itemId = 0 );
    gLoc := GUI.groundToLocation( locationItem );
    tile := GUI.GameWindow.Map.getTile( gLoc );
    if not canContinue then
    begin
      if GUI.GameWindow.Map.tileTopItem(tile).id = itemId then
        canContinue := true;
    end;

    if canContinue then
    begin
      d := GUI.GameWindow.getSize();
      s := GUI.GameWindow.absoluteToCursor( gLoc.x, gLoc.y );
      Inputer.SendRClick( d.Left + s.Left + round(s.Right / 2), d.Top + s.Top + round(s.Bottom / 2) );
    end;
  end;
end;


function TContainers.getSize: TRect;
var
  tmp, i: integer;
begin
  tmp := Memory.ReadPointer(Integer(ADDR_BASE) +  Addresses.guiPointer, [ $24 ] ); // container handler struct

  result.Left := Memory.ReadInteger( tmp + $14);
  result.Top := Memory.ReadInteger( tmp + $18);
  result.Right := Memory.ReadInteger( tmp + $1c);
  result.Bottom := Memory.ReadInteger( tmp + $20);
end;

procedure TContainers.closeWindows( location: string = ''; onlyfirst: boolean = false );
var
  point: TPoint;
  hrect, crect: TRect;
  addr, i, count: integer;
begin
  hrect := getSize();
  count := 15;

  if not (location = '') then
  begin
    if onlyfirst then count := 0;

    for i := 0 to count do
    begin

      addr := window.getAddressByName( location );
      if addr = 0 then break;

      crect := window.getSize( addr );
      point.X := (hrect.Left + hrect.Right) - 10;
      point.Y := (hrect.Top + crect.Top) + 8;

      Inputer.SendClickPoint( point );
      sleep(200);
    end;
  end
  else
  begin
    for i := 15 downto 0 do
    begin
      addr := window.getAddress(i);

      if (addr > 0)
        and not (window.getName(addr) = 'Skills')
          and not (window.getName(addr) = 'VIP')
            and not (window.getName(addr) = 'Battle') then
      begin
        crect := window.getSize( addr );

        point.X := (hrect.Left + hrect.Right) - 10;
        point.Y := (hrect.Top + crect.Top) + 8;

        Inputer.SendClickPoint( point );
        sleep(200);
      end;
    end;
  end;
end;

procedure TContainers.resizeWindows( size: integer = 0; location: string = ''; onlyfirst: boolean = false );
var
  point: TPoint;
  hrect, crect: TRect;
  addr, i, count: integer;
begin
  hrect := getSize();
  count := 15;
  addr := 0;
  if not (location = '') then
  begin
    if onlyfirst then count := 0;

    for i := 0 to count do
    begin
      addr := window.getAddressByName( location, addr );
      if addr = 0 then break;

      crect := window.getSize( addr );
      point.X := (hrect.Left + hrect.Right) - 50;
      point.Y := (hrect.Top + crect.Top + crect.bottom) - 3;

      inputer.SendDrag( point.X, point.Y, point.X, (hrect.Top + crect.Top + 57) + size);
      sleep(200);
    end;
  end
  else
  begin
    for i := 0 to count do
    begin
      addr := window.getAddress(i);
      if addr = 0 then break;

      if not (window.getName(addr) = 'Skills')
          and not (window.getName(addr) = 'VIP')
            and not (window.getName(addr) = 'Battle') then
      begin

        crect := window.getSize( addr );
        point.X := (hrect.Left + hrect.Right) - 50;
        point.Y := (hrect.Top + crect.Top + crect.bottom) - 3;

        inputer.SendDrag( point.X, point.Y, point.X, (hrect.Top + crect.Top + 57) + size);
        sleep(200);
      end;
    end;
  end;

end;

end.
