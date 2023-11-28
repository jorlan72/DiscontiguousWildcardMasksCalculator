unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.RegularExpressions,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Memo: TMemo;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TIPAddress = record
    Octets: array[0..3] of Byte;
  end;

var
  Form1: TForm1;
  stoppressed : boolean;

implementation

{$R *.dfm}

function IPAddressToStr(const IPAddress: TIPAddress): string;
begin
  Result := Format('%d.%d.%d.%d', [IPAddress.Octets[0], IPAddress.Octets[1], IPAddress.Octets[2], IPAddress.Octets[3]]);
end;

function IsValidIPAddress(const IPAddress: string): Boolean;
const
  ValidOctetPattern = '^(([0-9])|([1-9][0-9])|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))$';
var
  Octets: TStringList;
  I: Integer;
begin
  Result := False;
  Octets := TStringList.Create;
  try
    Octets.Delimiter := '.';
    Octets.StrictDelimiter := True;
    Octets.DelimitedText := IPAddress;

    if Octets.Count <> 4 then
      Exit;

    for I := 0 to 3 do
    begin
      if not TRegEx.IsMatch(Octets[I], ValidOctetPattern) then
        Exit;
    end;

    Result := True;
  finally
    Octets.Free;
  end;
end;

function StrToIPAddress(const IPAddressStr: string): TIPAddress;
var
  IPAddressStrs: TStringList;
  I: Integer;
begin
  IPAddressStrs := TStringList.Create;
  try
    IPAddressStrs.Delimiter := '.';
    IPAddressStrs.StrictDelimiter := True;
    IPAddressStrs.DelimitedText := IPAddressStr;

    for I := 0 to 3 do
      Result.Octets[I] := StrToIntDef(IPAddressStrs[I], 0);
  finally
    IPAddressStrs.Free;
  end;
end;

procedure ExpandWildcardIP(const IPAddress, WildcardMask: string; Memo: TMemo);
var
  IP, Mask: TIPAddress;
  StartIP, EndIP: TIPAddress;
  CurrentIP: TIPAddress;
  I: Integer;
begin
  if not IsValidIPAddress(IPAddress) or not IsValidIPAddress(WildcardMask) then
  begin
    ShowMessage('Invalid IP address or wildcard mask.');
    Exit;
  end;
  IP := StrToIPAddress(IPAddress);
  Mask := StrToIPAddress(WildcardMask);
  for I := 0 to 3 do
  begin
    StartIP.Octets[I] := IP.Octets[I] and (not Mask.Octets[I]);
    EndIP.Octets[I] := IP.Octets[I] or Mask.Octets[I];
  end;
  CurrentIP := StartIP;
  while not CompareMem(@CurrentIP, @EndIP, SizeOf(TIPAddress)) do
  begin
    // Check if the current IP address matches the mask
    for I := 0 to 3 do
    begin
      if (CurrentIP.Octets[I] and not Mask.Octets[I]) <> (IP.Octets[I] and not Mask.Octets[I]) then
        Break;
    end;
    if I = 4 then
      Memo.Lines.Add(IPAddressToStr(CurrentIP));
      application.ProcessMessages;
              if stoppressed then
              begin
               Memo.Lines.Add('Aborted...');
               stoppressed := false;
               exit;
              end;
    // Increment the IP address
    for I := 3 downto 0 do
    begin
      Inc(CurrentIP.Octets[I]);
      if CurrentIP.Octets[I] <> 0 then
        Break;
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 stoppressed := false;
 ExpandWildcardIP(edit1.Text, edit2.text, Memo);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 stoppressed := true;
end;

end.

