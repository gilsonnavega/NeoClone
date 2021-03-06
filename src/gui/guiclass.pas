unit guiclass;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, containers, chat, gamewindow, player, contextmenus, cooldown,
   addresses, equipment, map, hotkey;

type
  TGUI = class
  private                                 //Declaring everything this way we only have to
                                          //do this to get info "gui.map.Update" for example
    FMap: TMap;
    FCooldown: TCooldown;
    FContainers: TContainers;
    FChat: TChat;
    FGameWindow: TGameWindow;
    FPlayer: TPlayer;
    FContextMenu: TContextMenu;
    FEquipment: TEquipment;
    FTibiaHotKey: TTibiaHotkey;

    FServerCount: array of TItem;
    function findServerCount( id: integer ): integer;
  public

    procedure setServerCount( value: TItem );
    function serverCount( itemId: integer ): integer; overload;
    function serverCount( itemName: string ): integer; overload;

    function getSize(): TRect;
    procedure setCursorClient( x,y: integer );

    function expToLevel( level: integer = -1 ): integer;

    function itemCost( itemId: integer ): integer; overload;
    function itemCost( itemName: string ): integer; overload;

    function itemValue( itemId: integer ): integer; overload;
    function itemValue( itemName: string ): integer; overload;

    function itemWeight( itemId: integer ): extended; overload;
    function itemWeight( itemName: string ): extended; overload;

    function itemId( itemName: string ): integer;
    function itemName( itemId: integer ): string;

    function ground( x,y,z: integer ): string;
    function groundToLocation( location: string ): TLocation;

    property Map: TMap read FMap;
    property CoolDown: TCoolDown read FCoolDown;
    property Containers: TContainers read FContainers;
    property Chat: TChat read FChat;
    property GameWindow: TGameWindow read FGameWindow;
    property Player: TPlayer read FPlayer;
    property ContextMenu: TContextMenu read FContextMenu;
    property Equipment: TEquipment read FEquipment;
    property TibiaHotKey: TTibiaHotKey read FTibiaHotKey;

  published
    constructor Create; overload;
    destructor Destroy; override;
  end;

implementation

uses
  unit1;

constructor TGUI.Create;
begin
  inherited;
  FMap := TMap.Create;
  FCoolDown := TCooldown.Create;
  FContainers := TContainers.Create;
  FChat := TChat.Create;
  FGameWindow := TGameWindow.Create;
  FPlayer := TPlayer.Create;
  FContextMenu := TContextMenu.Create;
  FEquipment := TEquipment.Create;
  FTibiaHotKey := TTibiaHotKey.Create;
end;

destructor TGUI.Destroy;
begin
  FMap.Free;
  FCoolDown.Free;
  FContainers.Free;
  FChat.Free;
  FGameWindow.Free;
  FPlayer.Free;
  FContextMenu.Free;
  FEquipment.Free;
  FTibiaHotKey.Free;
  inherited;
end;

function TGUI.findServerCount( id: integer ): integer;
var
  i: integer;
begin
  result := -1;
  if length(FServerCount) > 0 then
  begin
    for i := 0 to length(FServerCount)-1 do
    begin
      if ( FServerCount[i].id = id ) then
      begin
        result := i;
        break;
      end;
    end;
  end;
end;

procedure TGUI.setServerCount( value: TItem );
var
  find: integer;
begin
  find := findServerCount( value.id );
  if ( find > -1 ) then
  begin
    FServerCount[find].id := value.id;
    FServerCount[find].count := value.count;
  end else
  begin
    setlength( FServerCount, length(FServerCount)+1 );
    FServerCount[high(FServerCount)].id := value.id;
    FServerCount[high(FServerCount)].count := value.count;
  end;
end;

function TGUI.serverCount( itemId: integer ): integer;
begin
  result := findServerCount( itemId );
  if result = -1 then
  begin
    result := 0;
    exit;
  end;
  result := FServerCount[result].count;
end;

function TGUI.serverCount( itemName: string ): integer;
begin
  result := serverCount( itemId( itemName ) );
end;

function TGUI.getSize(): TRect;
var
  addr: integer;
begin
  addr := Memory.ReadInteger(Integer(ADDR_BASE) +  addresses.guiPointer );

  result.Left := Memory.ReadInteger( addr + $14 );
  result.Top := Memory.ReadInteger( addr + $18 );
  result.Right := Memory.ReadInteger( addr + $1C );
  result.Bottom := Memory.ReadInteger( addr + $20 );
end;

procedure TGUI.setCursorClient( x,y: integer );
var
  p: Tpoint;
begin
  p.X := x;
  p.y := y;
  Windows.ClientToScreen( Main.THand, p );
  SetCursorPos(abs(p.x), abs(p.y));
end;

function TGUI.expToLevel( level: integer = -1 ): integer;
var
  curlvl: integer;
begin
//  curlvl := Player.get
end;

function TGUI.itemCost( itemId: integer ): integer;
begin
  result := StrToInt(xmlItemList.Root.FindEx2('id', IntToStr(itemId)).Attribute['npcprice']);
end;

function TGUI.itemCost( itemName: string ): integer;
begin
  result := StrToInt(xmlItemList.Root.FindEx2('name', itemName).Attribute['npcprice']);
end;

function TGUI.itemValue( itemId: integer ): integer;
begin
  result := StrToInt(xmlItemList.Root.FindEx2('id', IntToStr(itemId)).Attribute['npcvalue']);
end;

function TGUI.itemValue( itemName: string ): integer;
begin
  result := StrToInt(xmlItemList.Root.FindEx2('name', itemName).Attribute['npcvalue']);
end;

function TGUI.itemWeight( itemId: integer ): Extended;
begin
  result := StrToFloat(xmlItemList.Root.FindEx2('id', IntToStr(itemId)).Attribute['weight']);
end;

function TGUI.itemWeight( itemName: string ): Extended;
begin
  result := StrToFloat(xmlItemList.Root.FindEx2('name', itemName).Attribute['weight']);
end;

function TGUI.itemId( itemName: string ): integer;
begin
  result := xmlItemId(xmlItemList.Root.FindEx2('name', itemName).Attribute['id']);
end;

function TGUI.itemName( itemId: integer ): string;
begin
  result := xmlItemList.Root.FindEx2('id', inttostr(itemId)).Attribute['name'];
end;

function TGUI.ground( x,y,z: integer ): string;
begin
  result := format('ground %d %d %d', [ x, y, z ]);
end;

function TGUI.groundToLocation( location: string ): TLocation;
begin
  if ( pos('ground', location) > 0 ) then
  begin
    delete(location, 1, 7 );
    result.x := StrToInt(copy(location, 1, pos(' ', location)-1));

    delete(location, 1, pos(' ', location));
    result.y := StrToInt(copy(location, 1, pos(' ', location)-1));

    delete(location, 1, pos(' ', location));
    result.z := StrToInt(location);
  end else
  begin
    // location "depot"
  end;
end;

end.
