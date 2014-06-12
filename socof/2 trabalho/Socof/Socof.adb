with Calendar, Ada.Text_IO,Ada.Integer_Text_IO; use Calendar, Ada.Text_IO,Ada.Integer_Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Numerics.Discrete_Random;
procedure Socof is

   Interval  : constant Duration := Duration(0.2);--Duration (43_200);

   protected WheelAcelaration is
      procedure Write (NewSpeed : in Float);
      procedure Read (CurSpeed : out Float);
   private
      CurrentSpeed : Float := 0.0;
   end WheelAcelaration;

   protected WheelVelocity is
      procedure Write (NewSpeed : in Float);
      procedure Read (CurSpeed : out Float);
   private
      CurrentSpeed : Float := 0.0;
   end WheelVelocity;

   protected BreakPressure is
      procedure Write (Vi : in Float;Dist: in Float);
      procedure Read (Vi : out Float;Dist: out Float);
   private
      Vinicial,Distance : Float := 0.0;
   end BreakPressure;

   protected AcelaratorState is
      procedure Write (newState : in Boolean);
      procedure Read (CurState : out Boolean);
   private
      Acelarator : Boolean := False;
   end AcelaratorState;

   protected DistanceValue is
      procedure Write (newDistance : in Float;Fric : in Float);
      procedure Read (CurDistance : out Float;Fric : out Float);
   private
      Distance : Float := 200.0;
      Friction : Float;
   end DistanceValue;






   task VehicleDetectionSensor;

   task Brake  is
      entry Request(Vi,Dist : out Float);
   end;

   task Wheel  is
      entry Request(NewSpeed : out Float);
   end;

   task Accelerator  is
      entry Request(newState : out Boolean);
   end;

   task CAS  is
      entry Request(CurSpeed : out Float);
      entry Request2(CurDistance,Fric : out Float);
   end;




   protected body WheelAcelaration is
      procedure Write (NewSpeed : Float) is
      begin
         CurrentSpeed := NewSpeed;
      end Write;

      procedure Read (CurSpeed : out Float) is
      begin
         CurSpeed:= CurrentSpeed;
      end Read;
   end WheelAcelaration;

   protected body WheelVelocity is
      procedure Write (NewSpeed : Float) is
      begin
         CurrentSpeed := NewSpeed;
      end Write;

      procedure Read (CurSpeed : out Float) is
      begin
         CurSpeed:= CurrentSpeed;
      end Read;
   end WheelVelocity;

   protected body BreakPressure is
      procedure Write (Vi,Dist : Float) is
      begin
         Vinicial := Vi;
         Distance := Dist;
      end Write;

      procedure Read (Vi,Dist : out Float) is
      begin
         Vi:= Vinicial;
         Dist := Distance;
      end Read;
   end BreakPressure;

   protected body AcelaratorState is
      procedure Write (newState : in Boolean) is
      begin
         Acelarator := newState;
      end Write;

      procedure Read (CurState : out Boolean) is
      begin
         CurState := Acelarator;
      end Read;
   end AcelaratorState;

   protected body DistanceValue is
      procedure Write (newDistance,Fric : Float) is
      begin
         Distance := newDistance;
         Friction := Fric;
      end Write;

      procedure Read (CurDistance,Fric : out Float) is
      begin
         CurDistance := Distance;
         Fric := Friction;
      end Read;
   end DistanceValue;







   function CalculateAcelaration (Vinicial,Dist : Float) return Float is
   begin
      return -(Vinicial**2)/(2.0*Dist);
   end CalculateAcelaration;

   function ConverKmhToMs (Kmh : Float) return Float is
   begin
      return (5.0 * Kmh)/18.0;
   end ConverKmhToMs;

   function ConverMsToKmh (Kmh : Float) return Float is
   begin
      return (18.0 * Kmh)/5.0;
   end ConverMsToKmh;

   function CalcStoppingDistance (Kmh,CoefFriction,BrakeAct : Float) return Float is
   begin
      return 8.0*( ((Kmh/3.6)**2) / (2.0*9.81*BrakeAct*CoefFriction));
   end CalcStoppingDistance;

   function CalculateTime (Vinicial,Dist : Float) return Float is
   begin
      return (2.0*Dist)/Vinicial;
   end CalculateTime;








   task body VehicleDetectionSensor is
      Next_Time : Calendar.Time     := Calendar.Clock;
      Distance : Float := 200.0;
      subtype RangeDistance is Integer range 1 .. 50;
      package Random_Distance is new Ada.Numerics.Discrete_Random (RangeDistance);
      use Random_Distance;
      G : Generator;
      RandomValue : Integer;
      Friction : Float := 0.7;
   begin
      Reset (G);
      loop
         delay until Next_Time;
         DistanceValue.Write (Distance,Friction);
         Next_Time := Next_Time + Interval;
         if Distance = 0.0 then
            Distance := 200.0;
         end if;
         RandomValue := Random(G);
         Distance := Distance - float(RandomValue);
         if Distance < 0.0 then
            Distance := 0.0;
         end if;
      end loop;
   end VehicleDetectionSensor;

   task body Brake is
      Next_Time : Calendar.Time     := Calendar.Clock;
      ResAcelaration : Float;
      VelocityInital, Distance : Float;
   begin
      loop
         delay until Next_Time;
         accept Request(Vi,Dist : out Float) do
            BreakPressure.Read(Vi,Dist);
            VelocityInital := Vi;
            Distance := Dist;
         end Request;
         Next_Time := Next_Time + Interval;
         ResAcelaration := CalculateAcelaration(VelocityInital,Distance);
         WheelAcelaration.Write(ResAcelaration);
      end loop;
   end Brake;

   task body Wheel is
      CurrentSpeedMs : Float;
      NewCurrentSpeed : Float;
      CurrentSpeedKmh : Float := 30.0;
      NewAcelaration : Float;
      Next_Time : Calendar.Time     := Calendar.Clock;
   begin
      loop
         delay until Next_Time;
         accept Request(NewSpeed : out Float) do
            WheelAcelaration.Read(NewSpeed);
            NewAcelaration := NewSpeed;
         end Request;
         CurrentSpeedMs := ConverKmhToMs(CurrentSpeedKmh);
         NewCurrentSpeed := CurrentSpeedMs + NewAcelaration * 0.2;     --REVER!!!!
         CurrentSpeedKmh := ConverMsToKmh(NewCurrentSpeed);
         WheelVelocity.Write(CurrentSpeedKmh);
         Next_Time := Next_Time + Interval;
      end loop;
   end Wheel;

   task body Accelerator is
      Next_Time : Calendar.Time     := Calendar.Clock;
      Acelarator : Boolean := True;
   begin
      loop
         delay until Next_Time;
         accept Request(newState : out Boolean) do
            AcelaratorState.Read(newState);
            Acelarator := newState;
         end Request;
         if Acelarator = True Then
            WheelAcelaration.Write(0.0);
         end if;
         Next_Time := Next_Time + Interval;
      end loop;
   end Accelerator;

   task body CAS is
      Next_Time : Calendar.Time     := Calendar.Clock;
      Acelarator : Boolean := True;
      CurrentSpeed : Float;
      DistanceNextObstacle : Float;
      EstimatedSafeDistance : Float;
      Friction : Float;
      EstimatedSafeBrakeTime : Float := 0.0;
      I : Integer := 1;
   begin
      loop
         delay until Next_Time;
         select
            accept Request(CurSpeed : out Float) do
               WheelVelocity.Read(CurSpeed);
               CurrentSpeed := CurSpeed;
            end Request;
         or
            accept Request2(CurDistance,Fric : out Float) do
               DistanceValue.Read(CurDistance,Fric);
               Friction := Fric;
               DistanceNextObstacle := CurDistance;
            end Request2;
         end select;
         if  DistanceNextObstacle >= 200.0 then
            AcelaratorState.Write(True);
         else
            loop
               EstimatedSafeDistance := CalcStoppingDistance(CurrentSpeed,Friction,Float(I));
               I := I+1;
               exit when I = 9 or EstimatedSafeDistance < DistanceNextObstacle;
            end loop;
            EstimatedSafeBrakeTime :=CalculateTime(CurrentSpeed,EstimatedSafeDistance);
            if EstimatedSafeBrakeTime > 3.0 then
               put("ALERT Carro");
            else
               AcelaratorState.Write(False);
               BreakPressure.Write(CurrentSpeed,DistanceNextObstacle);    -- REVER DistanceNextObstacle vs EstimatedSafeDistance
            end if;
         end if;
         Next_Time := Next_Time + Interval;
      end loop;
   end CAS;

begin
   delay 3.0;
end Socof;
