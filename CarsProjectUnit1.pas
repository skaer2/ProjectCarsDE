unit CarsProjectUnit1;

{$mode objfpc}{$H+}

interface

uses
 Classes,SysUtils,FileUtil,Forms,Controls,Graphics,Dialogs,ExtCtrls,StdCtrls,
 Windows,math;

Const
 RedMoneyCost=10;
 GreenMoneyCost=20;
 MaxLvlSX=12;
 MaxLvlSY=12;
 MaxCrossCount=5;
 MinCrossDistanceFromCenter=3;
 MaxCrossChance=8;
 MinRoadCount=((MaxLvlSX*MaxLvlSY) div 10)*35;
 MaxRockCount=16;
 TileSize=600;
 BackUpTime=40;
 CostCar2=100;


 //массивы moveI, moveJ хранят индексы перемещений возможные значения -1, 0, +1
// ###   (j-1,i-1) (j+0,i-1) (j+1,i-1)
// #x#   (j-1,i+0)  (j, i)   (j+1,i+0)
// ###   (j-1,i+1) (j+0,i+1) (j+1,i+1)
  moveX : Array [1..4] Of shortint = ( 0,  0,  1, -1);
  moveY : Array [1..4] Of shortint = (-1,  1,  0,  0);

type
  //тип данных машины
 car=record
   xCent,yCent:Integer; //центральные координаты машины
   direction:Integer;   //направление машины
   NeedDirection:Integer; //направление которое должно быть
   MultiplierDirectionX,MultiplierDirectionY:Integer; //множитель направления()
   Speed:Integer; //скорость машины
   SpeedMax:Integer; //max скорость машины
   SpeedMin:Integer; //min скорость машины
   collisionSize:Integer; //размер колизии для машины
   roadSpeed:Integer;
 end;

 //тип данных объектов
 entity=record
   xCent,yCent:Integer; //центральные координаты
   xUpLeft,yUpLeft:Integer;        //верхняя левая точка
   xDownRight,yDownRight:Integer;  //нижняя правая точка
   width:Integer; //ширина объекта
   height:Integer; //высота объекта
   index:Integer; //индекс объекта
 end;

 BackGround=record
   xLeft,yUp:Integer;
   GroundType:Integer; //0 пустой тайл; 1 тайл с преградой; 2 тайл с перекрёстком;
                       //3 тайл с дорогой слева направо; 4 дорога сверху вниз;
   changed:Boolean;
 end;

 ProtocolBackUp=record
  Bool:Boolean;
  Count:Integer;
  CoordX:Integer;
  CoordY:Integer;
 end;

 //gameLevel=record
 // g:array[0..MaxLvlSX, 0..MaxLvlSY] of BackGround;
 //end;

 { TForm1 }

 TForm1 = class(TForm)
   AcceptSettingsBtn: TButton;
   BuyCarBtn: TButton;
   LULZImg: TImageList;
   LOLBtn: TButton;
   CostCarLbl: TLabel;
   DonateImg: TImage;
   SelectCarOneBtn: TButton;
   SelectCarTwoBtn: TButton;
   ExitBtn: TButton;
   DonateBtn: TButton;
   CarOneImg: TImage;
   CarTwoImg: TImage;
   ImageList1: TImageList;
   Label1: TLabel;
   Label2: TLabel;
   ListImageCarTwo: TImageList;
   MoneyColLbl: TLabel;
   SettingsPnl: TPanel;
   SettingsBtn: TButton;
   ChooseCar: TButton;
  Button3:TButton;
  Image1: TImage;
  ScoreLbl: TLabel;
  MoneyImageList: TImageList;
  BackgroundListImage:TImageList;
  ListImageBot:TImageList;
  ListImageEntity:TImageList;
  ListImage:TImageList;
  MainMenuPnl: TPanel;
  ChooseCarPnl: TPanel;
  Timer1:TTimer;
  SpinnerTimer: TTimer;
  procedure AcceptSettingsBtnClick(Sender: TObject);
  procedure Button3Click(Sender:TObject);
  procedure BuyCarBtnClick(Sender: TObject);
  procedure ChooseCarClick(Sender: TObject);
  procedure DonateBtnClick(Sender: TObject);
  procedure ExitBtnClick(Sender: TObject);
  procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
  procedure LOLBtnClick(Sender: TObject);
  procedure SettingsBtnClick(Sender: TObject);
  procedure SettingsPnlClick(Sender: TObject);
  procedure FormCreate(Sender:TObject);
  procedure Image1Click(Sender: TObject);
  procedure Image1MouseMove(Sender:TObject; Shift:TShiftState; X,Y:Integer);
  procedure SpinnerTimerTimer(Sender: TObject);
  procedure Timer1Timer(Sender:TObject);

  procedure InitLevel(Sender:TObject{; level:gameLevel});
  Procedure ProLevelGen(Sender:TObject; x,y:Integer; BeforeDirection:Integer; CrossCount:Integer; k:Integer);
  Procedure calcMultDir(Sender:TObject; var o:car );
  Procedure ChangeCarDir(Sender:TObject; var o:car);
  procedure DecSpeed(Sender:TObject; var o:car);
  procedure IncSpeed(Sender:TObject; var o:car);

 private
  { private declarations }
 public
  { public declarations }
 end;

var
 Form1: TForm1;

 Sp:integer;

 p:car;  //игрок

 k:Integer;    //число шагов таймера

 xM,yM:Integer; //xMouse yMouse

 yMReal,xMReal:Real;//кажется не нужно

 //g:BackGround;
 g:array[0..MaxLvlSX, 0..MaxLvlSY] of BackGround;   //задний фон
 movingBck:Boolean;

 mon:array[0..MaxLvlSX, 0..MaxLvlSY] of integer;

 RoadCount:Integer; //количество дорог

 ScoreStorage,ScoreContainer:integer; //очки

 LevelCentX:Integer;
 LevelCentY:Integer;

 obst:array[0..MaxRockCount] of entity; //массив препятствий

 bot:car;

 PBU:ProtocolBackUp;

 MoneyCount:integer;

 data:TextFile;

implementation

{$R *.lfm}

{ TForm1 }




function ArcCos(cosA:Real):Real;     //функция нахождения угла из косинуса
Var
 sinA,a:Real;
Begin
 sinA:=Sqrt(1-Sqr(cosA));             //нахождение синуса
 If cosA<>0 then
 Begin
  a:=ArcTan(sinA/cosA);              //нахождение угла в радианах
  a:=a*(180/Pi);                     //перевод угла в градусы
 end
  else a:=0;
 result:=a;
end;

function WhatDirection(o:car; xM,yM:Integer):Integer;       //функция определения направления машины
Var
 gip:real;
 angle:real;
 yMReal,xMReal:Real;
Begin
 yMReal:=Real(Abs(yM));
 xMReal:=Real(Abs(xM));
 Gip:=sqrt(sqr(Abs(xM))+sqr(Abs(yM)));   //Нахождение гипотенузы

  If ((yMReal<>0) or (gip<>0))and((xM>0) and (yM<0)) then        //1 четверть
    angle:=ArcCos(yMReal/gip);

  If ((xMReal<>0) or (gip<>0))and((xM>0) and (yM>0)) then        //4 четверть
    angle:=ArcCos(xMReal/gip)+90;

  If ((yMReal<>0) or (gip<>0))and((xM<0) and (yM>0)) then        //3 четверть
    angle:=ArcCos(yMReal/gip)+180;

  If ((xMReal<>0) or (gip<>0))and((xM<0) and (yM<0)) then        //2 четверть
    angle:=ArcCos(xMReal/gip)+270;


  If Round(angle)div 10=36 then o.direction:=0
   else o.direction:=Round(angle) div 10;

  result:=o.direction;
end;

function calcShortestWay(was, mouseTo: integer):Integer;     //нахождение кратчайшего пути справо налево
var
 oneWay, anotherWay: integer;
begin
 oneWay := abs(mouseTo-was) mod 35;
 anotherWay := ((35 - mouseTo) mod 35  + was) mod 35;
 if (anotherWay > oneWay) then
 if (mouseTo-was>0) then result:=1 else result:=-1
 else
 result:=-1; // oneWay > anotherWay
end;

Function FastestWay(was,need:Integer):Integer;               //нахождение кратчайшего пути слева направо
Var
 minusWay, plusWay: integer;
Begin
 minusWay:=(was-need);
 plusWay:=36-was+need;
 If (minusWay<plusWay) and (minusWay>0) then FastestWay:=-1
  else If (plusWay<minusWay) or (minusWay<0) then FastestWay:=1;
end;

function RealFastWay(was,need:Integer):Integer;              //получение правильного кратчайшего пути
Begin
 If (was>=18) and (need<=18) then result:=FastestWay(was,need);
 If (was<18) and (need>18) then result:=calcShortestWay(was,need)
  else result:=FastestWay(was,need);
end;

function collisionX(o:car; e:entity):Boolean;     //проверка колизии  x
Begin
 If (o.xCent+o.collisionSize+o.MultiplierDirectionX<e.xUpLeft)
    or (o.xCent-o.collisionSize+o.MultiplierDirectionX>e.xDownRight)
    then collisionX:=false
     else collisionX:=true;
end;

function collisionY(o:car; e:entity):Boolean;     //проверка колизии y
Begin
 If (o.yCent+o.collisionSize+o.MultiplierDirectionY<=e.yUpLeft-1)
    or (o.yCent-o.collisionSize+o.MultiplierDirectionY>e.yDownRight)
    then collisionY:=false
     else collisionY:=true;
end;

function checkBounds(i,j: byte):boolean;
begin
 Result:=((j>=0) and (j<=MaxLvlSY)) and ((i>=0) and (i<=MaxLvlSX)); //Если true то всё в порядке
end;

procedure TForm1.InitLevel(Sender:TObject);      //Инициализация уровня
Var
 lk,x,y:Integer;
 FromCenter:Integer;
 CrossChance:Integer;
 numberOfDirections,direction:Integer; // 1-up 2-right 3-down 4-left
 rockCount:Integer;
Begin
 For x:=0 to MaxLvlSX do
  For y:=0 to MaxLvlSY do g[x,y].changed:=False;

 For x:=0 to MaxLvlSX do
  For y:=0 to MaxLvlSY do g[x,y].GroundType:=0;

 //For x:=0 to MaxLvlSX do
  //For y:=0 to MaxLvlSY do g[x,y].ChangeCount:=0;

 Randomize;

 //For i:=0 to MaxLvlSX do
 // For j:=0 to MaxLvlSY do g[i,j].GroundType:=Random(5);

  //0 пустой тайл; 1 тайл с преградой; 2 тайл с перекрёстком;
 //3 дорога сверху вниз; 4 тайл с дорогой слева направо;


 x:=MaxLvlSX div 2+Random(10)-5;
 y:=MaxLvlSX div 2+Random(10)-5;
 If checkBounds(x,y) then
  Begin
   g[x,y].GroundType:=2;
   g[x,y].changed:=True;
  end
  else
   Begin
    x:=MaxLvlSX div 2+Random(4)-2;
    y:=MaxLvlSX div 2+Random(4)-2;
    g[x,y].GroundType:=2;
    g[x,y].changed:=True;
   end;


 //Memo1.Lines.Add('start  x '+IntToStr(x)+' y '+IntToStr(y));

 ProLevelGen(Sender,x,y,0,1,1);

 RockCount:=0;
 Repeat
  x:=MaxLvlSX div 2+Random(10)-5;
  y:=MaxLvlSX div 2+Random(10)-5;
  If not g[x,y].changed then
   Begin
    Inc(rockCount);
    g[x,y].GroundType:=1;
   end;
 until rockCount=MaxRockCount;
end;

Procedure TForm1.ProLevelGen(Sender:TObject; x,y:Integer; BeforeDirection:Integer; CrossCount:Integer; k:Integer);
Var
 lk:Integer;
 FromCenter:Integer;
 CrossChance:Integer;
 prevDir,numberOfDirections,direction:Integer; // 1-up 2-right 3-down 4-left

 CrossX,CrossY:Integer;

 i,j:Integer;
 index:Integer;
 TimeBefore:Integer;
Begin

 //Randomize;
 If CrossCount<MaxCrossCount then
  Begin
   CrossX:=x;
   CrossY:=y;


   Repeat
    direction:=Random(4)+1;
   until direction<>BeforeDirection;

   numberOfDirections:=Random(2)+2;

   FromCenter:=0;

   For lk:=1 to numberOfDirections do
    Begin
     x:=CrossX;
     y:=CrossY;
     Repeat
       Inc(RoadCount);

      {for i:=0 to MaxLvlSX-1 do
       for j:=0 to MaxLvlSY-1 do
        Begin
         index:=g[i,j].GroundType;
         MoneyImageList.Draw(Image1.Canvas,i*64,j*64,index);
        end;}

      //Memo1.Lines.Add(IntToStr(k)+'    x '+IntToStr(x)+' y '+IntToStr(y)+' direction   '
       //+IntToStr(direction)+' c '+IntToStr(g[x,y].ChangeCount));

      Case direction of
       1: Dec(y);
       2: Dec(x);
       3: Inc(y);
       4: Inc(x);
      end;


      Inc(FromCenter);

      CrossChance:=Random(MaxCrossChance);
      If (CrossChance=3) and (FromCenter>MinCrossDistanceFromCenter)
       and (CrossCount<MaxCrossCount) and (checkBounds(x,y))
       then
       Begin
        Inc(CrossCount);
        g[x,y].GroundType:=2;
        g[x,y].changed:=True;
        ProLevelGen(Sender,x,y,direction,CrossCount,k);
       end
       else  If (checkBounds(x,y)) then
        Begin
         If ((direction=1) or (direction=3)) and not(g[x,y].changed)
            then g[x,y].GroundType:=3;
         If ((direction=2) or (direction=4)) and not(g[x,y].changed)
            then g[x,y].GroundType:=4;

         //If g[x,y].ChangeCount=1 then g[x,y].GroundType:=2;

         If (g[x,y].GroundType=3) and ((direction=2) or (direction=4)) then g[x,y].GroundType:=2;
         If (g[x,y].GroundType=4) and ((direction=1) or (direction=3)) then g[x,y].GroundType:=2;

         g[x,y].changed:=True;
        end;

     //If checkBounds(x,y) then Inc(g[x,y].ChangeCount);

     Until (y-1<0) or (y+1>MaxLvlSY) or (x-1<0) or (x+1>MaxLvlSX);

     prevDir:=direction;
     Repeat
      direction:=Random(4)+1;
     until direction<>prevDir;
    end;

  end;
end;

Procedure TForm1.ChangeCarDir(Sender:TObject; var o:car);   //меняем направление машины
Begin
 If (o.Direction<>o.NeedDirection) then
  o.direction:=o.direction+RealFastWay(o.direction,o.NeedDirection);
 If o.direction>=36 then o.direction:=0;
 If o.direction<=-1 then o.direction:=35;
end;

procedure TForm1.calcMultDir(Sender:TObject; var o:car);   //высчитывание множителя направления
Begin
 //надо описать весь этот процесс
 Case o.direction of
  0:Begin
     o.MultiplierDirectionX:=0;
     o.MultiplierDirectionY:=-3-o.Speed - o.roadSpeed;
    end;
  1..4:Begin
        o.MultiplierDirectionX:=o.direction+o.Speed + o.roadSpeed;
        o.MultiplierDirectionY:=-o.direction-1-o.Speed - o.roadSpeed;
       end;
  5..8:Begin
        o.MultiplierDirectionX:=5-1*(o.direction-5)+o.Speed + o.roadSpeed;
        o.MultiplierDirectionY:=-4-1*(-o.direction+5)-o.Speed - o.roadSpeed;
       end;
  9:Begin
        o.MultiplierDirectionX:=3+o.Speed + o.roadSpeed;
        o.MultiplierDirectionY:=0;
    end;
  10..13:Begin
          o.MultiplierDirectionX:=2+1*(o.direction-10)+o.Speed + o.roadSpeed;
          o.MultiplierDirectionY:=2+1*(o.direction-10)+o.Speed + o.roadSpeed;
         end;
  14..17:Begin
          o.MultiplierDirectionX:=3-1*(o.direction-15)+o.Speed + o.roadSpeed;
          o.MultiplierDirectionY:=3-1*(o.direction-15)+o.Speed + o.roadSpeed;
         end;
  18:Begin
      o.MultiplierDirectionX:=0;
      o.MultiplierDirectionY:=3+o.Speed + o.roadSpeed;
     end;
  19..22:Begin
          o.MultiplierDirectionX:=-(2+1*(o.direction-19))-o.Speed - o.roadSpeed;
          o.MultiplierDirectionY:=(2+1*(o.direction-19))+o.Speed + o.roadSpeed;
         end;
  23..26:Begin
          o.MultiplierDirectionX:=-(3-1*(o.direction-24))-o.Speed - o.roadSpeed;
          o.MultiplierDirectionY:=(3-1*(o.direction-24))+o.Speed + o.roadSpeed;
         end;
  27:Begin
      o.MultiplierDirectionX:=-3-o.Speed - o.roadSpeed;
      o.MultiplierDirectionY:=0;
     end;
  28..31:Begin
          o.MultiplierDirectionX:=-(2+1*(o.direction-28))-o.Speed - o.roadSpeed;
          o.MultiplierDirectionY:=-(2+1*(o.direction-28))-o.Speed - o.roadSpeed;
         end;
  32..35:Begin
          o.MultiplierDirectionX:=-(3-1*(o.direction-33))-o.Speed - o.roadSpeed;
          o.MultiplierDirectionY:=-(3-1*(o.direction-33))-o.Speed - o.roadSpeed;
         end;
 end;
end;

procedure TForm1.DecSpeed(Sender:TObject; var o:car);
Begin
 If (o.Speed>o.SpeedMin) and (k mod 3=0) then Dec(o.Speed);
end;

procedure TForm1.IncSpeed(Sender:TObject; var o:car);
Begin
 If (o.Speed<o.SpeedMax) and (k mod 3=0) then Inc(o.Speed);
end;

procedure TForm1.FormCreate(Sender:TObject);
Var
 i,j,lk:Integer;
 moneyRandX,moneyRandY:integer;
 s:string;
begin
 AssignFile(data,'Data.txt');
 if FileExists('Data.txt') then
 begin
   Reset(data);
   while not Eof(data) do
   begin
     readln(data,s);
     ScoreStorage:=StrToInt(s);
     readln(data,s);
     MoneyCount:=StrToInt(s);
   end;
 end
 else
 begin
   rewrite(data);
   ScoreStorage:=0;
   MoneyCount:=0;
 end;

 LevelCentX:=0;
 LevelCentY:=0;


//координаты тайлов
  For i:=0 to MaxLvlSX do
   For j:=0 to MaxLvlSY do
    Begin
     g[i,j].xLeft:=-((MaxLvlSX div 2)*TileSize)+i*TileSize;
     g[i,j].yUp:=-((MaxLvlSY div 2)*TileSize)+j*TileSize;
    end;


//обнуление шага таймера
 k:=0;

//скорость игрока
 p.Speed:=1;
 p.SpeedMax:=17;
 p.SpeedMin:=-7;

//скорость бота
 bot.Speed:=1;
 bot.SpeedMax:=15;
 bot.SpeedMin:=-7;

 PBU.Bool:=False;

//определение координат машины игрока
 p.xCent:=Image1.Width div 2;
 p.yCent:=Image1.Height div 2;
 p.direction:=0;
 p.collisionSize:=90;

//определение координат машины бота
 bot.xCent:=Image1.Width-100;
 bot.yCent:=Image1.Height-100;
 bot.direction:=0;
 bot.collisionSize:=90;


 //начальная обработка канваса
 Image1.Canvas.Clear;                       // отчиска канваса
 Image1.Canvas.Brush.Color:=clWhite;          // смена цвета кисти канваса
 Image1.Canvas.Pen.Color:=clWhite;              // смена цвета ручки канваса
 Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);// заливка канваса белым цветом

 //отрисовка машины игрока
 ListImage.Draw(Image1.Canvas,p.xCent,p.yCent,p.direction);

 //отрисовка машины бота
 ListImageBot.Draw(Image1.Canvas,bot.xCent,bot.yCent,bot.direction);


//инициализация уровня
 RoadCount:=0;
 lk:=0;
 Repeat
  RoadCount:=0;
  InitLevel(Sender);
  Inc(lk);
 until (RoadCount>=MinRoadCount) or (lk>=15);

//

//координаты препятствий

  lk:=0;

  For i:=0 to MaxLvlSX do
   For j:=0 to MaxLvlSY do
    If g[i,j].GroundType=1 then
     Begin
      With obst[lk] do
       Begin
        xUpLeft:=g[i,j].xLeft;
        yUpLeft:=g[i,j].yUp;
        xDownRight:=xDownRight+TileSize;
        yDownRight:=yDownRight+TileSize;
        xCent:=TileSize div 2;
        yCent:=TileSize div 2;
        width:=TileSize-200;
        height:=TileSize-200;
       end;
      Inc(lk);
     end;

//

  For i:=0 to MaxLvlSX do
   For j:=0 to MaxLvlSY do
    mon[i,j]:=0;
  For i:=0 to 10 do
  begin
    moneyRandX:=random(MaxLvlSX);
    moneyRandy:=random(MaxLvlSY);
    if (mon[moneyRandX,moneyRandY]=0) and (g[moneyRandX,moneyRandY].GroundType=0) then
      mon[moneyRandX,moneyRandY]:=1;
  end;
  For i:=0 to 15 do
  begin
    moneyRandX:=random(MaxLvlSX);
    moneyRandy:=random(MaxLvlSY);
    if (mon[moneyRandX,moneyRandY]=0) and (g[moneyRandX,moneyRandY].GroundType=0) then
      mon[moneyRandX,moneyRandY]:=2;
  end;

  For i:=0 to MaxLvlSX do
   For j:=0 to MaxLvlSY do
   begin
    If g[i,j].GroundType=1 then
     Begin
      BackgroundListImage.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,0);
      ImageList1.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,0);
     end
     else BackgroundListImage.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,g[i,j].GroundType);
    If (g[i,j].GroundType=0)and(mon[i,j]=1) then
      MoneyImageList.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,1);
    If (g[i,j].GroundType=0)and(mon[i,j]=2) then
      MoneyImageList.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,0);
   end;

  MoneyColLbl.Caption:='Money:'+IntToStr(MoneyCount);
end;

procedure TForm1.Image1Click(Sender: TObject);
begin

end;


procedure TForm1.Image1MouseMove(Sender:TObject; Shift:TShiftState; X,Y:Integer
 );
begin
 //xM:=x-Image1.Width div 2;
 //yM:=y-Image1.Height div 2;
 xM:=x-p.xCent;
 yM:=y-p.yCent;
end;

procedure TForm1.SpinnerTimerTimer(Sender: TObject);
begin
 inc(sp);
 if sp>=36 then sp:=0;
 CarOneImg.Canvas.Clear;                       // отчиска канваса
 CarOneImg.Canvas.Brush.Color:=clWhite;          // смена цвета кисти канваса
 CarOneImg.Canvas.Pen.Color:=clWhite;              // смена цвета ручки канваса
 CarOneImg.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);// заливка канваса белым цветом
 ListImage.Draw(CarOneImg.Canvas,CarOneImg.Width div 2-p.collisionSize,CarOneImg.Height div 2-p.collisionSize,sp);
 CartwoImg.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);// заливка канваса белым цветом
 CartwoImg.Canvas.Clear;                       // отчиска канваса
 CartwoImg.Canvas.Brush.Color:=clWhite;          // смена цвета кисти канваса
 CartwoImg.Canvas.Pen.Color:=clWhite;              // смена цвета ручки канваса
 CartwoImg.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);// заливка канваса белым цветом
 ListImageCarTwo.Draw(CarTwoImg.Canvas,CarOneImg.Width div 2-p.collisionSize,CarOneImg.Height div 2-p.collisionSize,sp);
end;


procedure TForm1.Button3Click(Sender:TObject);
begin
 Timer1.Enabled:=true;
 p.xCent:=0+Image1.Width div 2;
 p.yCent:=0+Image1.Height div 2;
 movingBck:=not movingBck;
 MainMenuPnl.Visible:=false;
 ScoreLbl.Visible:=true;
 ChooseCarPnl.Visible:=false;
 ScoreContainer:=0;
end;

procedure TForm1.BuyCarBtnClick(Sender: TObject);
begin
  if MoneyCount>=CostCar2 then
    begin
     moneyCount:=MoneyCount-CostCar2;
     SelectCarTwoBtn.Enabled:=true;
     BuyCarBtn.Visible:=false;
     CostCarLbl.Visible:=false;
     MoneyColLbl.Caption:='Money:'+IntToStr(MoneyCount);
    end;
end;

procedure TForm1.AcceptSettingsBtnClick(Sender: TObject);
begin
  MainMenuPnl.Visible:=true;
  SettingsPnl.Visible:=false;
end;

procedure TForm1.ChooseCarClick(Sender: TObject);
begin
  sp:=0;
  ChooseCarPnl.Visible:=not ChooseCarPnl.Visible;
  SpinnerTimer.Enabled:=not SpinnerTimer.Enabled;
  CostCarLbl.Caption:='Cost:'+IntToStr(CostCar2);
end;

procedure TForm1.DonateBtnClick(Sender: TObject);
begin
 Image1.Visible:=false;
 MainMenuPnl.Visible:=false;
 ChooseCarPnl.Visible:=false;
 MoneyColLbl.Visible:=false;
 DonateImg.Visible:=True;
 LOLBtn.Visible:=True;
 DonateImg.Canvas.Clear;
 DonateImg.Canvas.Brush.Color:=clWhite;
 DonateImg.Canvas.Pen.Color:=clWhite;
 DonateImg.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);
 DonateImg.Picture.LoadFromFile('003.png');
end;

procedure TForm1.ExitBtnClick(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
 s:string;
begin
  rewrite(data);
  s:=IntToStr(ScoreStorage);
  WriteLn(Data,s);
  s:=IntToStr(MoneyCount);
  writeln(Data,s);
  CloseFile(data);
end;

procedure TForm1.LOLBtnClick(Sender: TObject);
begin
 Image1.Visible:=true;
 MainMenuPnl.Visible:=true;
 MoneyColLbl.Visible:=true;
 DonateImg.Visible:=false;
 LOLBtn.Visible:=false;
end;

procedure TForm1.SettingsBtnClick(Sender: TObject);
begin
  ChooseCarPnl.Visible:=false;
  MainMenuPnl.Visible:=false;
  SettingsPnl.Visible:=true;
end;

procedure TForm1.SettingsPnlClick(Sender: TObject);
begin

end;

procedure TForm1.Timer1Timer(Sender:TObject);
Var
 i,j:Integer;
 indexX,indexY:integer;
 collisionBool:Boolean;
 lk:Integer;
begin
 If k+1=MaxInt then k:=0  //увеличение шага таймера
  else Inc(k);

//подготовка канваса
 Begin
 Image1.Canvas.Clear;                       // отчиска канваса
 Image1.Canvas.Brush.Color:=clWhite;          // смена цвета кисти канваса
 Image1.Canvas.Pen.Color:=clWhite;              // смена цвета ручки канваса
 Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);// заливка канваса белым цветом
 end;

//

//Определяем направление машины игрока
  p.NeedDirection:=WhatDirection(p,xM,yM);

//

//меняем направление машины
  ChangeCarDir(Sender, p);

//


//поворот машины игрока  на стрелочки
 Begin
 If GetKeyState(39)<-126 then               //если нажата стрелка вправо
  Begin
   Inc(p.direction);
   If p.direction>=36 then p.direction:=0;
  end;
 If GetKeyState(37)<-126 then               //если нажата стрелка влево
  Begin
   Dec(p.direction);
   If p.direction<=-1 then p.direction:=35;
  end;
 end;

//


//газ тормоз игрока
  //увеличение и пониженние происходит каждые 3 шага таймера
 Begin
 If GetKeyState(38)<-126 then
  Begin
   If (p.Speed<p.SpeedMax) and (k mod 3=0) then Inc(p.Speed);
  end
   else
    If GetKeyState(40)<-126 then
     Begin
      If (p.Speed>p.SpeedMin) and (k mod 3=0) then Dec(p.Speed);
     end
    else If (p.Speed>0) and (k mod 3=0) then Dec(p.Speed);
 end;

//

//определяет находится ли игрок на дороге
 Begin
 For i:=0 to MaxLvlSX do
  For j:=0 to MaxLvlSY do
   Begin
    If ((g[i,j].xLeft+TileSize div 2)>=(Image1.Width div 2)-(TileSize div 2))
     and ((g[i,j].xLeft+TileSize div 2)<=(Image1.Width div 2)+(TileSize div 2))
      then indexX:=i;
    If ((g[i,j].yUp+TileSize div 2)>=(Image1.Height div 2)-(TileSize div 2))
     and ((g[i,j].yUp+TileSize div 2)<=(Image1.Height div 2)+(TileSize div 2))
      then indexY:=j;
   end;

 If checkBounds(indexX,indexY) then
  Begin
   If (g[indexX,indexY].GroundType=2)
    or (g[indexX,indexY].GroundType=3)
    or (g[indexX,indexY].GroundType=4)
     then p.roadSpeed:=5
      else p.roadSpeed:=0;
  end
  else
    For i:=0 to MaxLvlSX do
     For j:=0 to MaxLvlSY do
      Begin
       g[i,j].xLeft:=-((MaxLvlSX div 2)*TileSize)+i*TileSize;
       g[i,j].yUp:=-((MaxLvlSY div 2)*TileSize)+j*TileSize;
      end;
 end;

//

//
 If checkBounds(indexX,indexY) then
  if (g[indexX,indexY].GroundType=0)and(mon[indexX,indexY]=1)then
   begin
     mon[indexX,indexY]:=0;
     ScoreContainer:=ScoreContainer+RedMoneyCost;
     MoneyCount:=MoneyCount+RedMoneyCost;
     BackgroundListImage.Draw(Image1.Canvas,g[indexX,indexY].xLeft,g[indexX,indexY].yUp,g[indexX,indexY].GroundType);
   end;
 If checkBounds(indexX,indexY) then
  if (g[indexX,indexY].GroundType=0)and(mon[indexX,indexY]=2)then
   begin
     mon[indexX,indexY]:=0;
     ScoreContainer:=ScoreContainer+GreenMoneyCost;
     MoneyCount:=MoneyCount+GreenMoneyCost;
     BackgroundListImage.Draw(Image1.Canvas,g[indexX,indexY].xLeft,g[indexX,indexY].yUp,g[indexX,indexY].GroundType);
   end;


 ScoreLbl.Caption:='SCORE:'+IntToStr(ScoreContainer);
//



//высчитывание множителя направления
 calcMultDir(Sender, p);
 If p.Speed=0 then
  Begin
   p.MultiplierDirectionX:=0;
   p.MultiplierDirectionY:=0;
  end
  else If p.Speed<0 then
   Begin
    p.MultiplierDirectionX:=p.MultiplierDirectionX*-1;
    p.MultiplierDirectionY:=p.MultiplierDirectionY*-1;
   end;
//


//проверка колизии игрока и движение
 Begin
 collisionBool:=False;

 For lk:=0 to MaxRockCount do
   If (collisionX(p,obst[lk]) and collisionY(p,obst[lk]))
    then collisionBool:=True; //если колизия по x и колизия по y нет то машина едет
 If not collisionBool then
  Begin
   If movingBck then
    Begin
     bot.xCent:=bot.xCent-p.MultiplierDirectionX;
     bot.yCent:=bot.yCent-p.MultiplierDirectionY;
     For i:=0 to MaxLvlSX do
      For j:=0 to MaxLvlSY do
       Begin
        g[i,j].xLeft:=g[i,j].xLeft-p.MultiplierDirectionX;
        g[i,j].yUp:=g[i,j].yUp-p.MultiplierDirectionY;
       end;
    end
   else
    Begin
     p.xCent:=p.xCent+p.MultiplierDirectionX;   //движение машины игрока по x
     p.yCent:=p.yCent+p.MultiplierDirectionY;   //движение машины игрока по y
    end;
  end;
 end;

//

  //Определяем направление машины бота
      bot.NeedDirection:=WhatDirection(bot,(Image1.Width div 2)-bot.xCent,(Image1.Height div 2)-bot.yCent);
      ChangeCarDir(Sender, bot);
    //

 calcMultDir(Sender, bot);
 //If p.Speed=0 then
 // Begin
 //  p.MultiplierDirectionX:=0;
 //  p.MultiplierDirectionY:=0;
 // end
 // else If p.Speed<0 then
 //  Begin
 //   p.MultiplierDirectionX:=p.MultiplierDirectionX*-1;
 //   p.MultiplierDirectionY:=p.MultiplierDirectionY*-1;
 //  end;


 For lk:=0 to MaxRockCount do
   If (collisionX(bot,obst[lk]) and collisionY(bot,obst[lk]))
    then collisionBool:=True; //если колизия по x и колизия по y нет то машина едет
 If  not (collisionBool)  then
  Begin
   IncSpeed(Sender, bot);
   bot.xCent:=bot.xCent+bot.MultiplierDirectionX;
   bot.yCent:=bot.yCent+bot.MultiplierDirectionY;
  end;




//координаты препятствий

 lk:=0;

  For i:=0 to MaxLvlSX do
   For j:=0 to MaxLvlSY do
    If g[i,j].GroundType=1 then
     Begin
      With obst[lk] do
       Begin
        xUpLeft:=g[i,j].xLeft;
        yUpLeft:=g[i,j].yUp;
        xDownRight:=xUpLeft+TileSize;
        yDownRight:=yUpLeft+TileSize;
        xCent:=TileSize div 2;
        yCent:=TileSize div 2;
        width:=TileSize-200;
        height:=TileSize-200;
       end;
      Inc(lk);
     end;

//

//отрисовка заднего фона
    //0 пустой тайл; 1 тайл с преградой; 2 тайл с перекрёстком;
    //3 дорога сверху вниз; 4 тайл с дорогой слева направо;

  For i:=0 to MaxLvlSX do
   For j:=0 to MaxLvlSY do
   begin
    If g[i,j].GroundType=1 then
     Begin
      BackgroundListImage.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,0);
      ImageList1.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,0);
     end
     else BackgroundListImage.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,g[i,j].GroundType);
    If (g[i,j].GroundType=0)and(mon[i,j]=1) then
      MoneyImageList.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,1);
    If (g[i,j].GroundType=0)and(mon[i,j]=2) then
      MoneyImageList.Draw(Image1.Canvas,g[i,j].xLeft,g[i,j].yUp,0);
   end;
//

//отрисовка машины игрока
 Image1.Canvas.Pen.Color:=clRed;

  //рисование колизии игрока
   //Image1.Canvas.Rectangle
    //(p.xCent-p.collisionSize,p.yCent-p.collisionSize,p.xCent+p.collisionSize,p.yCent+p.collisionSize);

 //рисование машины
 ListImage.Draw(Image1.Canvas,p.xCent-p.collisionSize,p.yCent-p.collisionSize,p.direction);

//
 ListImageBot.Draw(Image1.Canvas,bot.xCent-bot.collisionSize,bot.yCent-bot.collisionSize,bot.direction);


//отрисовка оюъектов
 Image1.Canvas.Pen.Color:=clRed;

   //рисование колизии препятствий
    //For lk:=0 to MaxRockCount do
    // Image1.Canvas.Rectangle(obst[lk].xUpLeft,obst[lk].yUpLeft,obst[lk].xDownRight,obst[lk].yDownRight);

//
  MoneyColLbl.Caption:='Money:'+IntToStr(MoneyCount);
end;

end.

