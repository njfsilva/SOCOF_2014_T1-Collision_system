with Calendar, Ada.Text_IO,Ada.Integer_Text_IO, Ada.Float_Text_IO;
use Calendar, Ada.Text_IO,Ada.Integer_Text_IO;
use Ada.Float_Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Numerics.Discrete_Random;
procedure Socof is

   Interval  : constant Duration := Duration(0.2);--Duration (43_200);


   protected type Semaphore(Start_Count: Integer := 1) is
      entry Acquire;
      procedure Release;
   private
      Count: Integer := Start_Count;
   end Semaphore;
   protected body Semaphore is
      entry Acquire when Count > 0 is
      begin
         Count := Count - 1;
      end Acquire;
      procedure Release is
      begin
         Count := Count + 1;
      end Release;
   end Semaphore;


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
      CurrentSpeed : Float;
   end WheelVelocity;

   protected BreakPressure is
      procedure Write (Vi : in Float;Dist: in Float);
      procedure Read (Vi : out Float;Dist: out Float);
   private
      Vinicial,Distance : Float;
   end BreakPressure;

   protected AcelaratorState is
      procedure Write (newState : in Boolean);
      procedure Read (CurState : out Boolean);
   private
      Acelarator : Boolean;
   end AcelaratorState;

   protected DistanceValue is
      procedure Write (newDistance : in Float;Fric : in Float);
      procedure Read (CurDistance : out Float;Fric : out Float);
   private
      Distance : Float;
      Friction : Float;
   end DistanceValue;






   task VehicleDetectionSensor;

   task Brake  is
      --entry Request(Vi,Dist : out Float);
   end;

   task Wheel  is
      --entry Request(NewSpeed : out Float);
   end;

   task Accelerator  is
      --entry Request(newState : out Boolean);
   end;

   task CAS  is
      --entry Request(CurSpeed : out Float);
      --entry Request2(CurDistance,Fric : out Float);
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

   function CalcStoppingDistance (ms,CoefFriction,BrakeAct : Float) return Float is
      Kmh : Float;
   begin
      Kmh := ConverMsToKmh(ms);
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
      Put_Line("VehicleDetectionSensor");
      Reset (G);
      loop
         delay until Next_Time;
         DistanceValue.Write (Distance,Friction);
         Next_Time := Next_Time + Interval;
         if Distance = 0.0 then
            Distance := 200.0;
         end if;
         RandomValue := Random(G);
         Distance := Distance - 5.0;--float(RandomValue);
         if Distance < 0.0 then
            Distance := 0.01;
         end if;
      end loop;
   end VehicleDetectionSensor;

   task body Brake is
      Next_Time : Calendar.Time     := Calendar.Clock;
      ResAcelaration : Float;
      VelocityInital, Distance : Float;
   begin
      --delay 0.4;
      Put_Line("Brake");
      loop
         delay until Next_Time;
         BreakPressure.Read(VelocityInital,Distance);
         Next_Time := Next_Time + Interval;
         ResAcelaration := CalculateAcelaration(VelocityInital,Distance);
         WheelAcelaration.Write(ResAcelaration);
      end loop;
   end Brake;

   task body Wheel is
      CurrentSpeedMs : Float := 8.333333;
      NewCurrentSpeed : Float;
      NewAcelaration : Float;
      Next_Time : Calendar.Time     := Calendar.Clock;
   begin
      Put_Line("Wheel");
      loop
         delay until Next_Time;
         WheelAcelaration.Read(NewAcelaration);
         NewCurrentSpeed := CurrentSpeedMs + NewAcelaration * 0.2;     --REVER!!!!
         CurrentSpeedMs := NewCurrentSpeed;
         WheelVelocity.Write(CurrentSpeedMs);
         Next_Time := Next_Time + Interval;
      end loop;
   end Wheel;

   task body Accelerator is
      Next_Time : Calendar.Time     := Calendar.Clock;
      Acelarator : Boolean := True;
   begin
      Put_Line("Accelerator");
      loop
         delay until Next_Time;
         AcelaratorState.Read(Acelarator);
         if Acelarator = True Then
            WheelAcelaration.Write(0.0);
         end if;
         Next_Time := Next_Time + Interval;
      end loop;
   end Accelerator;

   task body CAS is
      Next_Time : Calendar.Time     := Calendar.Clock;
      Acelarator : Boolean := True;
      CurrentSpeed : Float := -2.0;
      DistanceNextObstacle : Float := -2.0;
      EstimatedSafeDistance : Float;
      Friction : Float;
      EstimatedSafeBrakeTime : Float := 0.0;
      I : Integer;
      S: Semaphore;
   begin
      Put_Line("cas");
      loop
         delay until Next_Time;

         WheelVelocity.Read(CurrentSpeed);
         DistanceValue.Read(DistanceNextObstacle,Friction);

         --put_line("new");
         --put(DistanceNextObstacle);
         --put(" - ");

         --new_line;
         if  DistanceNextObstacle >= 200.0 then
            AcelaratorState.Write(True);
         else
            put_line("DistanceNextObstacle");
            put(DistanceNextObstacle);
            I := 1;
            loop
               put_line("loop EstimatedSafeDistance");
               --S.Acquire;
               EstimatedSafeDistance := CalcStoppingDistance(CurrentSpeed,Friction,Float(I));
               put(EstimatedSafeDistance);
               new_line;
               put(Friction);
               new_line;
               put(I);
               put_line("CurSpeed");
               put(CurrentSpeed);
               new_line;
               I := I+1;
               exit when I < 8 or EstimatedSafeDistance < DistanceNextObstacle;
            end loop;
            EstimatedSafeBrakeTime :=CalculateTime(CurrentSpeed,EstimatedSafeDistance);
            if EstimatedSafeBrakeTime > 3.0 then
               Put_Line("ALERT Carro");
            else
               AcelaratorState.Write(False);
               BreakPressure.Write(CurrentSpeed,EstimatedSafeDistance);    -- REVER DistanceNextObstacle vs EstimatedSafeDistance
            end if;
         end if;
         Next_Time := Next_Time + Interval;
      end loop;
   end CAS;

begin
   Put_Line("hello");
end Socof;
