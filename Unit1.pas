unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    function Fill: boolean;
    procedure DFS;

    procedure FormCreate(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button1Click2(Sender: TObject);
    procedure Button1Click3(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TMyThread = class(TThread)
  protected
    procedure Execute; override;
  end;

  TMap = Array [1 .. 9, 1 .. 9] of Longint;

var
  Form1: TForm1;
  Ed: Array [1 .. 9, 1 .. 9] of TEdit;
  Map: TMap;
  F: Array [1 .. 9, 1 .. 9, 1 .. 9] of Longint;
  Wait: boolean;

implementation

{$R *.dfm}

procedure TMyThread.Execute;
begin
  FreeOnTerminate := True;
  Form1.DFS;
  Form1.Button1.Caption := '结束解算';
  Form1.Button1.OnClick := Form1.Button1Click3;
end;

function TForm1.Fill: boolean;
var
  flag: boolean;
  i, j, k, t: Longint;

begin
  flag := false;
  for i := 1 to 9 do
    for j := 1 to 9 do
    begin
      if Map[i, j] <> 0 then
        Continue;
      t := 0;
      for k := 1 to 9 do
        inc(t, ord(F[i, j, k] <= 0));
      if t = 1 then
      begin
        for k := 1 to 9 do
          if F[i, j, k] <= 0 then
          begin
            Ed[i, j].Text := IntToStr(k);
            Break;
          end;
        flag := True;
      end;
    end;
  Exit(flag);
end;

procedure TForm1.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  x, y: Longint;

begin
  x := TEdit(Sender).Top div 34 + 1;
  y := TEdit(Sender).Left div 34 + 1;
  Case Key of
    37:
      dec(y);
    38:
      dec(x);
    39:
      inc(y);
    40:
      inc(x);
  End;
  if y < 1 then
  begin
    y := 9;
    dec(x);
  end;
  if y > 9 then
  begin
    y := 1;
    inc(x);
  end;
  if x < 1 then
    x := 9;
  if x > 9 then
    x := 1;
  Ed[x, y].SetFocus;
end;

procedure TForm1.Button1Click2(Sender: TObject);
begin
  Wait := false;
  Button1.Enabled := false;
end;

procedure TForm1.Button1Click3(Sender: TObject);
var
  i, j: Longint;

begin
  for i := 1 to 9 do
    for j := 1 to 9 do
      With Ed[i, j] do
      begin
        if Font.Color = clBlue then
        begin
          Text := '';
          Font.Color := clBlack;
        end;
      end;
  Button1.Caption := '解算';
  Button1.OnClick := Button1Click;
end;

procedure TForm1.DFS;
var
  i, j, k, min, x, y, t, flag: Longint;
  Map2: TMap;

begin
  min := 10;
  x := 0;
  y := 0;
  flag := 0;
  for i := 1 to 9 do
    for j := 1 to 9 do
    begin
      t := 0;
      for k := 1 to 9 do
        inc(t, ord(F[i, j, k] <= 0));

      if (Map[i, j] = 0) and (t = 0) then
        Exit;
      if Map[i, j] <> 0 then
      begin
        inc(flag);
        Continue;
      end;
      if t = 0 then
        Continue;
      if t < min then
      begin
        min := t;
        x := i;
        y := j;
      end;
    end;

  if min = 10 then
  begin
    if flag = 81 then
    Begin
      Wait := True;
      Button1.Enabled := True;
      Button1.SetFocus;
      Repeat
        Application.ProcessMessages;
      Until Not Wait;
    End;
    Exit;
  end;

  for i := 1 to 9 do
  begin
    if F[x, y, i] <= 0 then
    begin
      Map2 := Map;
      Ed[x, y].Text := IntToStr(i);
      while Form1.Fill do;
      Application.ProcessMessages;

      DFS;

      for j := 1 to 9 do
        for k := 1 to 9 do
          Ed[j, k].Text := IntToStr(Map2[j, k]);
      Application.ProcessMessages;
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j: Longint;
  ID: THandle;

begin
  for i := 1 to 9 do
    for j := 1 to 9 do
      if Map[i, j] = 0 then
        Ed[i, j].Font.Color := clBlue;
  Button1.Caption := '下一个解';
  Button1.OnClick := Button1Click2;
  TMyThread.Create(false);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  while Fill do;
end;

procedure TForm1.EditChange(Sender: TObject);
Var
  a, b, x, y, i, j, tx, ty: Longint;
  Key: Word;
  Shift: TShiftState;

begin
  x := TEdit(Sender).Top div 34 + 1;
  y := TEdit(Sender).Left div 34 + 1;
  Try
    a := StrToInt(TEdit(Sender).Text);
  Except
    a := 0;
  End;

  if a = 0 then
    TEdit(Sender).Text := '';
  if a = Map[x, y] then
    Exit;

  if (a <> 0) and (F[x, y, a] > 0) then
  begin
    TEdit(Sender).Text := '';
    Exit;
  end;

  b := Map[x, y];
  if (b <> 0) then
  Begin
    for i := 1 to 9 do
    Begin
      dec(F[x, i, b]);
      dec(F[i, y, b]);
    End;
    tx := x;
    ty := y;
    x := ((x - 1) div 3) * 3 + 1;
    y := ((y - 1) div 3) * 3 + 1;
    for i := x to x + 2 do
      for j := y to y + 2 do
        dec(F[i, j, b]);
    x := tx;
    y := ty;
  End;

  Map[x, y] := a;
  if a = 0 then
    Exit;

  for i := 1 to 9 do
  Begin
    inc(F[x, i, a]);
    inc(F[i, y, a]);
  End;
  x := ((x - 1) div 3) * 3 + 1;
  y := ((y - 1) div 3) * 3 + 1;
  for i := x to x + 2 do
    for j := y to y + 2 do
      inc(F[i, j, a]);

  Key := 39;
  Shift := [];
  EditKeyDown(Sender, Key, Shift);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, j: Longint;

begin
  for i := 1 to 9 do
  begin
    for j := 1 to 9 do
    begin
      Ed[i, j] := TEdit.Create(Form1);
      With Ed[i, j] do
      begin
        Parent := Form1;
        BevelInner := bvSpace;
        BevelKind := bkFlat;
        BorderStyle := bsNone;
        Height := 34;
        Width := 34;
        NumbersOnly := True;
        MaxLength := 1;
        Left := 8 + (j - 1) * 33 + ord(j mod 3 <> 0);
        Top := 8 + (i - 1) * 33 + ord(i mod 3 <> 0);
        Visible := True;
        Font.Size := 18;
        Alignment := taCenter;
        OnChange := EditChange;
        OnKeyDown := EditKeyDown;
      end;
    end;
  end;
  Form1.ClientHeight := 10 * 33 + 3 * 1 + 3 * 8;
  Form1.ClientWidth := 9 * 33 + 2 * 1 + 2 * 8;

  FillChar(Map, Sizeof(Map), 0);
  FillChar(F, Sizeof(F), 0);
end;

end.
