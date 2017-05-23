unit CarsProjectUnit1;

{$mode objfpc}{$H+}

interface

uses
 Classes,SysUtils,FileUtil,Forms,Controls,Graphics,Dialogs,ExtCtrls,StdCtrls,
 Windows;

Const
 MaxLvlSX=20;
 MaxLvlSY=20;
 MaxRoadCount=7;
 MinCrossDistanceFromCenter=3;
 MaxCrossChance=8;

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

 //gameLevel=record
 // g:array[0..MaxLvlSX, 0..MaxLvlSY] of BackGround;
 //end;

 { TForm1 }

 TForm1 = class(TForm)
  Button1:TButton;
  Button2:TButton;
  Button3:TButton;
  Image1:TImage;
  BackgroundListImage:TImageList;
  Label10:TLabel;
  Label11:TLabel;
  Label12:TLabel;
  Label13:TLabel;
  Label14:TLabel;
  Label15:TLabel;
  Label16:TLabel;
  Label17:TLabel;
  Label18:TLabel;
  Label19:TLabel;
  Label20:TLabel;
  Label21:TLabel;
  Label22:TLabel;
  Label4:TLabel;
  Label5:TLabel;
  Label6:TLabel;
  Label7:TLabel;
  Label8:TLabel;
  Label9:TLabel;
  ListImageEntity:TImageList;
  Label1:TLabel;
  Label2:TLabel;
  Label3:TLabel;
  ListImage:TImageList;
  Memo1:TMemo;
  Timer1:TTimer;
  procedure Button1Click(Sender:TObject);
  procedure Button2Click(Sender:TObject);
  procedure Button3Click(Sender:TObject);
  procedure FormCreate(Sender:TObject);
  procedure Image1MouseMove(Sender:TObject; Shift:TShiftState; X,Y:Integer);
  procedure Timer1Timer(Sender:TObject);

  procedure InitLevel(Sender:TObject{; level:gameLevel});
  Procedure ProLevelGen(Sender:TObject; x,y:Integer; BeforeDirection:Integer);
  //procedure InitLevel();

 private
  { private declarations }
 public
  { public declarations }
 end;

var
 Form1: TForm1;

 p:car;  //игрок
 house:entity; //дом

 k:Integer;    //число шагов таймера

 xM,yM:Integer; //xMouse yMouse
 gip:real; //Гипотенуза при работе с xM и yM
 angle:real; //Угол при работе с xM и yM
 yMReal,xMReal:Real;
 //g:BackGround;
 g:array[0..MaxLvlSX, 0..MaxLvlSY] of BackGround;
 movingBck:Boolean;



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

procedure TForm1.InitLevel(Sender:TObject{; level:gameLevel});
Var
 lk,x,y:Integer;
 FromCenter:Integer;
 CrossChance:Integer;
 numberOfDirections,direction:Integer; // 1-up 2-right 3-down 4-left
Begin
 For x:=0 to MaxLvlSX do
  For y:=0 to MaxLvlSY do g[x,y].changed:=False;

 Randomize;

 //
 //For i:=0 to MaxLvlSX do
  //For j:=0 to MaxLvlSY do g[i,j].GroundType:=Random(5);

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

 ProLevelGen(Sender,x,y,0);

end;

Procedure TForm1.ProLevelGen(Sender:TObject; x,y:Integer; BeforeDirection:Integer);
Var
 lk:Integer;
 FromCenter:Integer;
 CrossChance:Integer;
 numberOfDirections,direction:Integer; // 1-up 2-right 3-down 4-left
Begin

 Randomize;
 Repeat
  direction:=Random(4)+1;
 until direction<>BeforeDirection;

 numberOfDirections:=Random(2)+2;

 FromCenter:=0;

 For lk:=1 to numberOfDirections do
  Begin
   Repeat
    Case direction of
     1: Dec(y);
     2: Inc(x);
     3: Inc(y);
     4: Dec(x);
    end;

    Inc(FromCenter);

    CrossChance:=Random(MaxCrossChance);
    If (CrossChance=3) and (FromCenter>=MinCrossDistanceFromCenter) and (checkBounds(x,y)) then
     Begin
      g[x,y].GroundType:=2;
      g[x,y].changed:=True;
      ProLevelGen(Sender,x,y,direction);
     end
     else  If (checkBounds(x,y)) then
      Begin
       If ((direction=1) or (direction=3)) and not(g[x,y].changed)
          then g[x,y].GroundType:=3;
       If ((direction=2) or (direction=2)) and not(g[x,y].changed)
          then g[x,y].GroundType:=4;

       g[x,y].changed:=True;
      end;

    direction:=Random(4)+1;
   Until (y<=0) or (y>=MaxLvlSY) or (x<=0) or (x>=MaxLvlSX);
  end;
end;



procedure TForm1.FormCreate(Sender:TObject);
Var
 i,j:Integer;
 s:string;
begin
  xMReal:=5;
  yMReal:=5;
  gip:=6;

 //
 k:=0;

 //скорость игрока
 p.Speed:=1;
 p.SpeedMax:=15;
 p.SpeedMin:=-7;

 //определение координат машины игрока
 p.xCent:=Image1.Width div 2;
 p.yCent:=Image1.Height div 2;
 p.direction:=0;
 p.collisionSize:=90;

 //определение координат дома
 Randomize;
 house.xCent:=223 {Random(Image1.Width-20)};
 house.yCent:=550 {Random(Image1.Height-20)};
 house.width:=110;
 house.height:=110;
 With house do
  Begin
   xUpLeft:=xCent-width;
   xDownRight:=xCent+width;
   yUpLeft:=yCent-height;
   yDownRight:=yCent+height;
   index:=0;
  end;


 //начальная обработка канваса
 Image1.Canvas.Clear;                       // отчиска канваса
 Image1.Canvas.Brush.Color:=clWhite;          // смена цвета кисти канваса
 Image1.Canvas.Pen.Color:=clWhite;              // смена цвета ручки канваса
 Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);// заливка канваса белым цветом

 //отрисовка машины игрока
 ListImage.Draw(Image1.Canvas,p.xCent,p.yCent,p.direction);

 //отрисовка оъектов
 ListImageEntity.Draw(Image1.Canvas,house.xCent,house.yCent,house.index);


 InitLevel(Sender);
 s:='';

 //Memo1.Lines.Add();
 For i:=0 to MaxLvlSX do
  Begin
   For j:=0 to MaxLvlSY do s:=s+IntToStr(g[i,j].GroundType)+'   ';
   Memo1.Lines.Add(s);
   s:='';
  end;
end;

procedure TForm1.Image1MouseMove(Sender:TObject; Shift:TShiftState; X,Y:Integer
 );
begin
 //xM:=x-Image1.Width div 2;
 //yM:=y-Image1.Height div 2;
 xM:=x-p.xCent;
 yM:=y-p.yCent;
end;

procedure TForm1.Button1Click(Sender:TObject);
begin
 Dec(p.direction);
 If p.direction<=-1 then p.direction:=35;
end;

procedure TForm1.Button2Click(Sender:TObject);
begin
 Inc(p.direction);
 If p.direction>=36 then p.direction:=0;
end;

procedure TForm1.Button3Click(Sender:TObject);
begin
 movingBck:=not movingBck;
end;

procedure TForm1.Timer1Timer(Sender:TObject);
Var
 i:Integer;
begin
 Inc(k);

 Image1.Canvas.Clear;                       // отчиска канваса
 Image1.Canvas.Brush.Color:=clWhite;          // смена цвета кисти канваса
 Image1.Canvas.Pen.Color:=clWhite;              // смена цвета ручки канваса
 Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);// заливка канваса белым цветом

 //Определяем направление машины
  p.NeedDirection:=WhatDirection(p,xM,yM);


 //меняем направление машины
 If (p.Direction<>p.NeedDirection) then
  p.direction:=p.direction+RealFastWay(p.direction,p.NeedDirection);
 If p.direction>=36 then p.direction:=0;
 If p.direction<=-1 then p.direction:=35;



 //поворот машины игрока
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

 //газ тормоз игрока
  //увеличение и пониженние происходит каждые 3 шага таймера
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




//высчитывание множителя направления
 //надо описать весь этот процесс
 Case p.direction of
  0:Begin
     p.MultiplierDirectionX:=0;
     p.MultiplierDirectionY:=-3-p.Speed;
    end;
  1..4:Begin
        p.MultiplierDirectionX:=p.direction+p.Speed;
        p.MultiplierDirectionY:=-p.direction-1-p.Speed;
       end;
  5..8:Begin
        p.MultiplierDirectionX:=5-1*(p.direction-5)+p.Speed;
        p.MultiplierDirectionY:=-4-1*(-p.direction+5)-p.Speed;
       end;
  9:Begin
        p.MultiplierDirectionX:=3+p.Speed;
        p.MultiplierDirectionY:=0;
    end;
  10..13:Begin
          p.MultiplierDirectionX:=2+1*(p.direction-10)+p.Speed;
          p.MultiplierDirectionY:=2+1*(p.direction-10)+p.Speed;
         end;
  14..17:Begin
          p.MultiplierDirectionX:=3-1*(p.direction-15)+p.Speed;
          p.MultiplierDirectionY:=3-1*(p.direction-15)+p.Speed;
         end;
  18:Begin
      p.MultiplierDirectionX:=0;
      p.MultiplierDirectionY:=3+p.Speed;
     end;
  19..22:Begin
          p.MultiplierDirectionX:=-(2+1*(p.direction-19))-p.Speed;
          p.MultiplierDirectionY:=(2+1*(p.direction-19))+p.Speed;
         end;
  23..26:Begin
          p.MultiplierDirectionX:=-(3-1*(p.direction-24))-p.Speed;
          p.MultiplierDirectionY:=(3-1*(p.direction-24))+p.Speed;
         end;
  27:Begin
      p.MultiplierDirectionX:=-3-p.Speed;
      p.MultiplierDirectionY:=0;
     end;
  28..31:Begin
          p.MultiplierDirectionX:=-(2+1*(p.direction-28))-p.Speed;
          p.MultiplierDirectionY:=-(2+1*(p.direction-28))-p.Speed;
         end;
  32..35:Begin
          p.MultiplierDirectionX:=-(3-1*(p.direction-33))-p.Speed;
          p.MultiplierDirectionY:=-(3-1*(p.direction-33))-p.Speed;
         end;
 end;


 Label1.Caption:=IntToStr(p.MultiplierDirectionX);  //вывод множителя х на экран
 Label2.Caption:=IntToStr(p.MultiplierDirectionY);  //вывод множителя y на экран
 Label3.Caption:=IntToStr(p.direction);             //вывод направления на экран
 Label4.Caption:=IntToStr(house.xUpLeft);
 label5.Caption:=IntToStr(house.yUpLeft);
 label6.Caption:=IntToStr(house.xDownRight);
 label7.Caption:=IntToStr(house.yDownRight);
 label8.Caption:=IntToStr(p.xCent);
 label9.Caption:=IntToStr(p.yCent);
 label10.Caption:=IntToStr(p.xCent-100);
 label11.Caption:=IntToStr(p.yCent-100);
 label12.Caption:=IntToStr(p.xCent+100);
 label13.Caption:=IntToStr(p.yCent+100);
 Label14.Caption:=BoolToStr(collisionX(p,house),'true','false');
 Label15.Caption:=BoolToStr(collisionY(p,house),'true','false');
 label17.Caption:=IntToStr(xM);
 label18.Caption:=IntToStr(yM);
 Label19.Caption:=IntToStr(p.NeedDirection);
 label20.Caption:=IntToStr(35-p.direction+p.NeedDirection+1)+'   '+IntToStr( Abs(p.direction-p.NeedDirection));



 {If not (collisionX(p,house) and collisionY(p,house))  then  //если колизия по x и колизия по y нет то машина едет
  Begin
   If movingBck then
    Begin
     //g.xCent:=g.xCent-p.MultiplierDirectionX;   //движение машины игрока по x
     //g.yCent:=g.yCent-p.MultiplierDirectionY;   //движение машины игрока по y
    end
   else
    Begin
     p.xCent:=p.xCent+p.MultiplierDirectionX;   //движение машины игрока по x
     p.yCent:=p.yCent+p.MultiplierDirectionY;   //движение машины игрока по y
    end;
  end;}



 Image1.Canvas.Pen.Color:=clRed;
 Image1.Canvas.Rectangle(0+Image1.Width-5,0+Image1.Height-5,0+Image1.Width+5,0+Image1.Height+5);

 //отрисовка заднего фона
  //BackgroundListImage.Draw(Image1.Canvas,g.xCent,g.yCent,0);
  //For i:=

 //отрисовка машины игрока
 Image1.Canvas.Pen.Color:=clRed;

 //рисование колизии
 Image1.Canvas.Rectangle
  (p.xCent-p.collisionSize,p.yCent-p.collisionSize,p.xCent+p.collisionSize,p.yCent+p.collisionSize);

 //рисование машины
 ListImage.Draw(Image1.Canvas,p.xCent-p.collisionSize,p.yCent-p.collisionSize,p.direction);


 //отрисовка оюъектов
 Image1.Canvas.Pen.Color:=clRed;

 //рисование колизии
 Image1.Canvas.Rectangle(house.xUpLeft,house.yUpLeft,house.xDownRight,house.yDownRight);

 //рисование дома
 ListImageEntity.Draw(Image1.Canvas,house.xCent-house.width,house.yCent-house.height,house.index);
end;

end.

