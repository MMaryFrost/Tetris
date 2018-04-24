unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  crt, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, LMessages, StdCtrls, Menus, ComCtrls, WinCrt;

type
  { Tetris }
  StatGame = (nogame, partone, parttwo, partthree, partfour);
  items = 0..5;
  ttmas = array[1..5, 1..5] of integer;
  figurs = record
    x: integer;
    y: integer;
    vid: 1..5;
    color: 1..5;
    math_f: ttmas;
  end;


  { TTetris }
  TTetris = class(TForm)
    b_OK: TButton;
    History_: TMemo;
    ImageList1: TImageList;
    ImgFon: TImage;
    ImgBegin: TImage;
    ImgSettings: TImage;
    ImgResults: TImage;
    ImgEND: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    Name_pol: TEdit;
    GameTime: TPanel;
    NextFigure: TPanel;
    p_text: TPanel;
    p_status: TPanel;
    p_GameOver: TPanel;
    Score: TPanel;
    Timer: TTimer;
    Clock: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure GameTimeClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure p_GameOverClick(Sender: TObject);
    procedure p_statusClick(Sender: TObject);
    procedure imgResultsClick(Sender: TObject);
    procedure NextFigureClick(Sender: TObject);
    procedure ClockTimer(Sender: TObject);
    procedure p_textClick(Sender: TObject);
    procedure ScoreClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure imgBeginClick(Sender: TObject);
    procedure imgEndClick(Sender: TObject);
    procedure imgSettingsClick(Sender: TObject);
    procedure b_OKClick(Sender: TObject);
    procedure Move(Sender: TObject);
    function bMove(x, y: integer): boolean;
    function bSwap: boolean;
    procedure GameEnd(Sender: TObject);
    procedure delete_line(Sender: TObject);
    procedure swap(var mm: ttmas);
    function CreateFigure(Sender: TObject): figurs;
    procedure graphic_(Sender: TObject);
    procedure CloseGame;
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    MainFullFon: TBitmap;
    math_m: array[0..11, -4..21] of items;//Математическое представление
    graphic_m: array[1..10, 1..20] of TImage;//Графический вывод Готов
    sled_m: array[1..5, 1..5] of TImage;//Графический вывод Готов
    figura: figurs;//Движущаяся фигура
    sostgame: StatGame;//Этап игры
    ClockSec, ClockHour: longint;//Время считать
    sGameTime: string;
    status: boolean;//В настройках изменяется
    MovingFigura: boolean;//Фигура движется
    number: integer;//Номер фигуры
    points: longint;//Счет
    sled: integer;
    sledMas:ttmas;
    sledcolor:tcolor;
    bx, by: integer;
  const
    First: boolean = True;

  end;

var
  Tetris: TTetris;

  etalon1: ttmas = ((0, 0, 1, 0, 0), (0, 0, 1, 0, 0), (0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0), (0, 0, 0, 0, 0));
  etalon2: ttmas = ((0, 0, 0, 0, 0), (0, 0, 1, 0, 0), (0, 0, 1, 0, 0),
    (0, 0, 1, 1, 0), (0, 0, 0, 0, 0));
  etalon3: ttmas = ((0, 0, 0, 0, 0), (0, 0, 1, 1, 0), (0, 1, 1, 0, 0),
    (0, 0, 0, 0, 0), (0, 0, 0, 0, 0));
  etalon4: ttmas = ((0, 0, 0, 0, 0), (0, 0, 1, 0, 0), (0, 1, 1, 1, 0),
    (0, 0, 0, 0, 0), (0, 0, 0, 0, 0));
  etalon5: ttmas = ((0, 0, 0, 0, 0), (0, 1, 1, 0, 0), (0, 1, 1, 0, 0),
    (0, 0, 0, 0, 0), (0, 0, 0, 0, 0));

implementation

{$R *.lfm}

{ TTetris }


{ Tetris }

procedure TTetris.NextFigureClick(Sender: TObject);
begin
  Timer.Enabled := False;
  GameEnd(self);
  delete_line(self);
end;

{Действия после конца игры}
procedure TTetris.GameEnd(Sender: TObject);
var
  i, j: integer;
begin
  sostgame := nogame;
  b_OK.Visible := True;
  p_GameOver.Visible := True;
  p_GameOver.Caption := 'GAME OVER! Набрано очков ' + IntToStr(points) + ', время игры ' +
    IntToStr(ClockHour) + ':' + IntToStr(ClockSec);
  Name_pol.Visible := True;
  MovingFigura := False;
  GameTime.Visible := False;
  Score.Visible := False;
  NextFigure.Visible := False;
  timer.Enabled := False;
  clock.Enabled := False;
  p_text.Visible := False;
  p_status.Visible := False;
  for i := 1 to 10 do
  for j := 1 to 20 do
    begin
      graphic_m[i, j].Visible := False;
    end;

  for i := 1 to 10 do
  for j := -4 to 20 do
    begin
      math_m [i, j]:=0;

    end;

  Score.Caption := '';
  sGameTime := '';
end;

{-------------------------}

{Действия после нажатия на ОК}
procedure TTetris.b_OKClick(Sender: TObject);
var
  s: string;
  f: TextFile;
begin
  {$I-}
  AssignFile(f, 'Histrory.txt');
  if FileExists('Histrory.txt') = True then
  begin
    if (Length(Name_pol.Text) = 0) or (Name_pol.Text = ' ') then
      ShowMessage('Пустое имя запрещено! Результаты сохранены не будут! ')
    else
    begin
      s := Name_pol.Text;
      s := '| ' + s + ' | ' + IntToStr(points) + ' | ' + IntToStr(ClockHour) +
        ':' + IntToStr(ClockSec) + ' |';
      append(f);
      writeln(f, s);
      CloseFile(f);
    end;
  end
  else
    ShowMessage('Файл с результатами прошлых игр не найден');
  {$I+}
  GameTime.Caption := '';
  imgBegin.Visible := True;
  imgSettings.Visible := True;
  imgResults.Visible := True;
  imgEnd.Visible := True;
  History_.Visible := False;
  b_OK.Visible := False;
  p_GameOver.Visible := False;
  Name_pol.Visible := False;
end;

{-------------------------}

{Удаляет линию и сдвигает "остатки" от фигур}
procedure TTetris.delete_line(Sender: TObject);
var
  i, j, x, y: integer;
  l: integer;
begin
  begin
    for j := 1 to 20 do
    begin
      l := 0;
      for i := 1 to 10 do
      begin
        if math_m[i, j] > 0 then
          Inc(l);
      end;
      if l = 10 then
      begin
        if j <> 1 then
        begin
          for y := j downto 2 do
          begin
            for x := 1 to 10 do
            begin
              math_m[x, y] := math_m[x, y - 1];
            end;
          end;
        end
        else
          for x := 1 to 10 do
            math_m[x, j] := 0;
        Inc(points);
      end;
    end;
  end;
end;

{-------------------------------------------}

{Действия при нажатии на кнопку РЕЗУЛЬТАТЫ}
procedure TTetris.imgResultsClick(Sender: TObject);
var
  f: TextFile;
  s: string;
begin
//  if sostgame = nogame then
  CloseGame;
  begin
    sostgame := partthree;
    History_.Visible := True;
    imgBegin.Visible := False;
    imgSettings.Visible := False;
    imgResults.Visible := False;
    imgEnd.Visible := False;
    {$I-}
    AssignFile(f, 'Histrory.txt');
    if FileExists('Histrory.txt') = True then
    begin
      Reset(f);
      History_.Lines.Clear;
      while not (EOF(f)) do
      begin
        ReadLn(f, s);
        History_.Lines.Add(s);
      end;
      CloseFile(f);
    end
    else
      ShowMessage('Файл с результатами прошлых игр не найден');
    {$I+}
    if IOResult <> 0 then
      ShowMessage('Ошибка доступа к файлу');
  end;
end;

{-----------------------------------------}


procedure TTetris.Move(Sender: TObject);
var
  i, j: integer;
begin
  for i := 1 to 5 do
    for j := 1 to 5 do
    begin
      if math_m[i, j] <> 0 then
      begin
        math_m[i, j] := 0;
      end;
    end;
end;

function TTetris.bMove(x, y: integer): boolean;
var
  i, j: integer;
begin
  bMove := True;
  for i := 1 to 5 do
    for j := 1 to 5 do
      if figura.math_f[i, j] = 1 then
        if math_m[figura.x + i + x, figura.y + j + y] <> 0 then
        begin
          bMove := False;
          break;
        end;
end;

function TTetris.bSwap: boolean;
var
  i, j: integer;
  tmp: ttmas;
begin
  bSwap := True;
  tmp := figura.math_f;
  swap(tmp);
  for i := 1 to 5 do
    for j := 1 to 5 do
      if tmp[i, j] = 1 then
        if math_m[figura.x + i, figura.y + j] <> 0 then
        begin
          bSwap := False;
          break;
        end;
end;


{Таймер для обновления картинок}
procedure TTetris.TimerTimer(Sender: TObject);

var
  i, j, l, k: integer;
  s: string;
begin

  if (sostgame = partone) then
  begin
    if bMove(0, 1) then
      Inc(figura.y);    //Down
    if bMove(0, 1) = False then
    begin
      for i := 1 to 5 do
        for j := 1 to 5 do
          if figura.math_f[i, j] = 1 then
            math_m[figura.x + i, figura.y + j] := figura.color;
      for i:=1 to 10 do
      if math_m[i,1]<>0 then
      begin
        GameEnd(self);
        break;
      end;
      begin
        number := 0;
        CreateFigure(self);
      end;
    end;
  end;
  delete_line(self);
  Score.Caption := IntToStr(points);
  graphic_(self);
end;

{------------------------------}

{Нажатие на кнопку СТАРТ}
procedure TTetris.imgBeginClick(Sender: TObject);

{Заполняет картинки белым}
  procedure GoWhite(Sender: TObject);
  var
    x, y: integer;
  begin
    for x := 1 to 10 do
      for y := 1 to 20 do
        graphic_m[x, y].Visible := True;
  end;

begin
//  if sostgame = nogame then
  CloseGame;
  begin
    sostgame := partone;
    imgBegin.Visible := False;
    imgSettings.Visible := False;
    imgResults.Visible := False;
    imgEnd.Visible := False;

    GameTime.Visible := True;
    Score.Visible := True;
    nextfigure.visible:= status;

    History_.Visible := False;
    GoWhite(self);
    number := 0;
    CreateFigure(self);
    MovingFigura := True;
    Timer.Enabled := true;
    Clock.Enabled := true;
  end;
end;

{-----------------------}

{Нажатие на кнопку ВЫХОД}
procedure TTetris.imgEndClick(Sender: TObject);
begin
  Close;
end;

{-----------------------}

{Нажатие на кнопку НАСТРОЙКИ}
procedure TTetris.imgSettingsClick(Sender: TObject);
begin
//  if sostgame = nogame then
  CloseGame;
  begin
    sostgame := parttwo;
    imgBegin.Visible := False;
    imgSettings.Visible := False;
    imgResults.Visible := False;
    imgEnd.Visible := False;
    p_text.Caption := 'Оповещать о следующей фигуре ';
    p_text.Visible := True;
    p_status.Visible := True;
    if status = True then
      p_status.Caption := 'Да'
    else
      p_status.Caption := 'Нет';
  end;
end;

{---------------------------}

{Нажатие на кнопку НАСТРОЙКИ.ОПЕВЕЩЕНИЕ О СЛЕДУЮЩЕЙ ФИГУРЕ}
procedure TTetris.p_statusClick(Sender: TObject);
begin
  if status = True then
  begin
    p_status.Caption := 'Нет';
    status := False;
  end
  else
  begin
    p_status.Caption := 'Да';
    status := True;
  end;
end;

procedure TTetris.p_GameOverClick(Sender: TObject);
begin

end;

procedure TTetris.GameTimeClick(Sender: TObject);
begin

end;

procedure TTetris.MenuItem2Click(Sender: TObject);
begin
  close;
end;

procedure TTetris.MenuItem3Click(Sender: TObject);
begin
  imgResultsClick(self);
end;

procedure TTetris.MenuItem4Click(Sender: TObject);
begin
  imgSettingsClick(self);
end;

procedure TTetris.MenuItem5Click(Sender: TObject);
begin
  imgBeginClick(self);
end;

{---------------------------------------------------------}

{Создание формы}
procedure TTetris.FormCreate(Sender: TObject);
var
  x, y: integer;
begin
  DoubleBuffered := True;
  number := 0;
  points := 0;
  History_.Visible := False;


  for x := 1 to 5 do
    begin
      for y := 1 to 5 do
      begin
        sled_m[x, y] := TImage.Create(nextfigure);
        sled_m[x, y].parent := nextfigure;
        sled_m[x, y].Visible := true;
        sled_m[x, y].Left := 2+30 * (x-1);
        sled_m[x, y].Top := 2+30 * (y-1);
        sled_m[x, y].Picture.LoadFromFile('./TetrisImages/whiteBlock.png');
      end;
    end;

  for x := 1 to 10 do
  begin
    for y := 1 to 20 do
    begin
      math_m[x, y] := 0;
      graphic_m[x, y] := TImage.Create(self);
      graphic_m[x, y].Parent := Self;
      graphic_m[x, y].Visible := False;
      graphic_m[x, y].Left := 30 * x;
      graphic_m[x, y].Top := 30 * y;
      graphic_m[x, y].Picture.LoadFromFile('./TetrisImages/whiteBlock.png');
    end;
  end;
  for y := 1 to 20 do //рамки
  begin
    math_m[0, y] := -1;
    math_m[11, y] := -1;
  end;
  for x := 1 to 10 do
    math_m[x, 21] := -1;

  number := 0;
  b_OK.Visible := False;
  p_GameOver.Visible := False;
  Name_pol.Visible := False;
  MovingFigura := False;
  status := True;
  ClockSec := 0;
  ClockHour := 0;
  sostgame := nogame;
  imgFon.Picture.Bitmap.LoadFromFile('./TetrisImages/FullFon.bmp');
  ImgBegin.Picture.Bitmap.LoadFromFile('./TetrisImages/1.bmp');
  ImgSettings.Picture.Bitmap.LoadFromFile('./TetrisImages/2.bmp');
  ImgResults.Picture.Bitmap.LoadFromFile('./TetrisImages/3.bmp');
  ImgEnd.Picture.Bitmap.LoadFromFile('./TetrisImages/4.bmp');
end;

{--------------}

{Таймер для подсчета времени игры}
procedure TTetris.ClockTimer(Sender: TObject);
begin
  if ClockSec < 59 then
    Inc(ClockSec)
  else
  begin
    Inc(ClockHour);
    ClockSec := 0;
  end;
  sGameTime := 'Время игры ' + IntToStr(ClockHour) + ':' + IntToStr(ClockSec);
  GameTime.Caption := sGameTime;
end;

procedure TTetris.p_textClick(Sender: TObject);
begin

end;

procedure TTetris.ScoreClick(Sender: TObject);
begin

end;

{--------------------------------}

{Конвертирование из математического представления в графическое}
procedure TTetris.graphic_(Sender: TObject);
var
  i, j: integer;
begin

  for i := 1 to 10 do
    for j := 1 to 20 do
    begin
      graphic_m[i, j].Picture.Clear;
      case math_m[i, j] of
        0: graphic_m[i, j].Picture.LoadFromFile('./TetrisImages/whiteBlock.png');
        1: graphic_m[i, j].Picture.LoadFromFile('./TetrisImages/greenBlock.png');
        2: graphic_m[i, j].Picture.LoadFromFile('./TetrisImages/redBlock.png');
        3: graphic_m[i, j].Picture.LoadFromFile('./TetrisImages/blueBlock.png');
        4: graphic_m[i, j].Picture.LoadFromFile('./TetrisImages/yeBlock.png');
        5: graphic_m[i, j].Picture.LoadFromFile('./TetrisImages/yellowBlock.png');
      end;
    end;
  for i := 1 to 5 do
    for j := 1 to 5 do
      if figura.math_f[i, j] = 1 then
        if ((i + figura.x) in [1..10]) and ((j + figura.y) in [1..20]) then
          case figura.color of
            0: graphic_m[i + figura.x, j + figura.y].Picture.LoadFromFile(
                './TetrisImages/whiteBlock.png');
            1: graphic_m[i + figura.x, j + figura.y].Picture.LoadFromFile(
                './TetrisImages/greenBlock.png');
            2: graphic_m[i + figura.x, j + figura.y].Picture.LoadFromFile(
                './TetrisImages/redBlock.png');
            3: graphic_m[i + figura.x, j + figura.y].Picture.LoadFromFile(
                './TetrisImages/blueBlock.png');
            4: graphic_m[i + figura.x, j + figura.y].Picture.LoadFromFile(
                './TetrisImages/yeBlock.png');
            5: graphic_m[i + figura.x, j + figura.y].Picture.LoadFromFile(
                './TetrisImages/yellowBlock.png');
          end;


  for i := 1 to 5 do
    for j := 1 to 5 do
    begin
        sled_m[i, j].Picture.Clear;
        if sledmas[i, j]=0 then
         sled_m[i, j].Picture.LoadFromFile('./TetrisImages/whiteBlock.png')
        else
      case sled of
        0:   sled_m[i, j].Picture.LoadFromFile('./TetrisImages/whiteBlock.png');
        1:   sled_m[i, j].Picture.LoadFromFile('./TetrisImages/greenBlock.png');
        2:   sled_m[i, j].Picture.LoadFromFile('./TetrisImages/redBlock.png');
        3:   sled_m[i, j].Picture.LoadFromFile('./TetrisImages/blueBlock.png');
        4:   sled_m[i, j].Picture.LoadFromFile('./TetrisImages/yeBlock.png');
        5:   sled_m[i, j].Picture.LoadFromFile('./TetrisImages/yellowBlock.png');
      end;
    end;
end;

procedure TTetris.CloseGame;
var i,j:integer;
begin
   MovingFigura := False;
   GameTime.Visible := False;
   Score.Visible := False;
   nextfigure.visible :=false;

   NextFigure.Visible := False;
   timer.Enabled := False;
   clock.Enabled := False;
   p_text.Visible := False;
   p_status.Visible := False;
   for i := 1 to 10 do
   begin
     for j := 1 to 20 do
     begin
       graphic_m[i, j].Visible := False;
       math_m[i, j]:=0;
     end;
   end;
   imgBegin.Visible := True;
   imgSettings.Visible := True;
   imgResults.Visible := True;
   imgEnd.Visible := True;
   sostgame := nogame;
   Score.Caption := '';
   GameTime.Caption := '';
   sGameTime := '';
   ClockSec := 0;
   ClockHour := 0;
   points:=0;
   History_.Visible := False;
   b_OK.Visible := False;
   p_GameOver.Visible := False;
   Name_pol.Visible := False;
end;

procedure TTetris.ToolButton1Click(Sender: TObject);
begin
  imgBeginClick(self);
end;

procedure TTetris.ToolButton2Click(Sender: TObject);
begin
  imgSettingsClick(self);
end;

procedure TTetris.ToolButton3Click(Sender: TObject);
begin
  imgResultsClick(self);
end;

procedure TTetris.ToolButton4Click(Sender: TObject);
begin
  close;
end;

{--------------------------------------------------------------}

{Функция для поворота массива с фигурой}
procedure TTetris.swap(var mm: ttmas);
var
  i, j, n: integer;
  tmp: ttmas;
begin
  n := 5;
  tmp := mm;
  for j := 1 to n do
    for i := 1 to n do
      mm[i, j] := tmp[j, n - i + 1];
end;

{--------------------------------------}

{Функция для создания случайной фигуры}
function TTetris.CreateFigure(Sender: TObject): figurs;

begin
  if number = 0 then
  begin
    randomize;
    if First = True then
    begin
      First := False;
      sled := random(5) + 1;
    end;
    number := sled;
    sled := random(5) + 1;
  end;
  case number of
    1: figura.color := 1;
    2: figura.color := 2;
    3: figura.color := 3;
    4: figura.color := 4;
    5: figura.color := 5;
  end;

case number of
  1: figura.math_f := etalon1;
  2: figura.math_f := etalon2;
  3: figura.math_f := etalon3;
  4: figura.math_f := etalon4;
  5: figura.math_f := etalon5;
end;

  case sled of
    1: sledcolor := 1;
    2: sledcolor := 2;
    3: sledcolor := 3;
    4: sledcolor := 4;
    5: sledcolor := 5;
  end;

  case sled of
    1: sledMas := etalon1;
    2: sledMas := etalon2;
    3: sledMas := etalon3;
    4: sledMas := etalon4;
    5: sledMas := etalon5;
  end;
  figura.x := 3;
  figura.y := -3;
end;

{-------------------------------------}

{Действия при нажатии кнопок}
procedure TTetris.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  i, j: integer;
begin

  if (sostgame = partone) and (MovingFigura = True) then
  begin
    if (key = 32) and bSwap then
      swap(figura.math_f);    //Space
    if (key = 37) and bMove(-1, 0) then
      Dec(figura.x);    //Left
    if (key = 39) and bMove(1, 0) then
      Inc(figura.x);    //Right
    if (key = 40) and bMove(0, 1) then
      Inc(figura.y);    //Down
  end;

  if (sostgame <> nogame) and (key = 27) then
  begin
    CLoseGame;

  end;
end;

{---------------------------}

end.
