unit CarsProjectUnit1;

{$mode objfpc}{$H+}

interface

uses
 Classes,SysUtils,FileUtil,Forms,Controls,Graphics,Dialogs,ExtCtrls,StdCtrls,
 Windows;

type
  //тип данных машины
 car=record
   xCent,yCent:Integer; //центральные координаты машины
   direction:Integer;   //направление машины
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



 { TForm1 }

 TForm1 = class(TForm)
  Button1:TButton;
  Button2:TButton;
  Image1:TImage;
  Label10:TLabel;
  Label11:TLabel;
  Label12:TLabel;
  Label13:TLabel;
  Label14:TLabel;
  Label15:TLabel;
  Label16:TLabel;
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
  Timer1:TTimer;
  procedure Button1Click(Sender:TObject);
  procedure Button2Click(Sender:TObject);
  procedure FormCreate(Sender:TObject);
  procedure Timer1Timer(Sender:TObject);
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

implementation

{$R *.lfm}

{ TForm1 }

//function collision(o:car; e:entity):Boolean;      //проверка колизии
//Begin
//    //x левый  y верхний  XL:YU
// If ((o.xCent+100+o.MultiplierDirectionX<e.xUpLeft) or (o.xCent-100+o.MultiplierDirectionX>e.xDownRight))
//    and
//    ((o.yCent+100+o.MultiplierDirectionY<=e.yUpLeft-1) or (o.yCent-100+o.MultiplierDirectionY>e.yDownRight))
//    then  collision:=false
//     else collision:=true;
//end;

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

procedure TForm1.FormCreate(Sender:TObject);
begin
 //
 k:=0;

 //скорость игрока
 p.Speed:=1;
 p.SpeedMax:=15;
 p.SpeedMin:=-7;

 //определение координат машины игрока
 p.xCent:=Image1.Width div 2;
 p.yCent:=Image1.Height div 2;
 p.direction:=0;;
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

procedure TForm1.Timer1Timer(Sender:TObject);
Var
 i:Integer;
begin
 Inc(k);

 Image1.Canvas.Clear;                       // отчиска канваса
 Image1.Canvas.Brush.Color:=clWhite;          // смена цвета кисти канваса
 Image1.Canvas.Pen.Color:=clWhite;              // смена цвета ручки канваса
 Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);// заливка канваса белым цветом

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
 //описать весь этот процесс
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
 //Label16.Caption:=BoolToStr(collision(p,house),'true','false');

 {If not collision(p,house) then
  Begin
   p.xCent:=p.xCent+p.MultiplierDirectionX;   //движение машины игрока по x
   p.yCent:=p.yCent+p.MultiplierDirectionY;   //движение машины игрока по y
  end;}

 If not (collisionX(p,house) and collisionY(p,house))  then  //если колизия по x и колизия по y нет то машина едет
  Begin
   p.xCent:=p.xCent+p.MultiplierDirectionX;   //движение машины игрока по x
   p.yCent:=p.yCent+p.MultiplierDirectionY;   //движение машины игрока по y
  end;




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

