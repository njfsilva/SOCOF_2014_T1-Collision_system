with Calendar, Ada.Text_IO,Ada.Integer_Text_IO, Ada.Float_Text_IO;
use Calendar, Ada.Text_IO,Ada.Integer_Text_IO;
use Ada.Float_Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Numerics.Discrete_Random;
procedure Socof is

   Interval  : constant Duration := Duration(0.05);--Duration (43_200);
   initialSpeed : constant Float := 8.3;

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
      CurrentSpeed : Float := initialSpeed;
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
      Acelarator : Boolean := true;
   end AcelaratorState;

   protected DistanceValue is
      procedure Write (newDistance : in Float;Fric : in Float);
      procedure Read (CurDistance : out Float;Fric : out Float);
   private
      Distance : Float;
      Friction : Float;
   end DistanceValue;

   protected Finish is
      procedure Write (state : in Boolean);
      procedure Read (state : out Boolean);
   private
      Finish : Boolean := false;
   end Finish;





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

   protected body Finish is
      procedure Write (state : in Boolean) is
      begin
         Finish := state;
      end Write;

      procedure Read (state : out Boolean) is
      begin
         state := Finish;
      end Read;
   end Finish;









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
      CurrentVelocity : Float;
      Distance : Float := 8.0;
      Fixo : Boolean :=  False; -- obstaculo tem movimento ou não
      Friction : Float := 0.7;
   begin
      loop
         delay until Next_Time;
         WheelVelocity.Read(CurrentVelocity);
         if Fixo = True then
            Distance := Distance - (CurrentVelocity *0.05);
            if Distance > 6.0 then
               DistanceValue.Write (-1.0,Friction);
            elsif Distance < 0.25 then
               DistanceValue.Write (0.0,Friction);
               Distance := 0.0;
            else
               DistanceValue.Write (Distance,Friction);
            end if;
         elsif Fixo = False then
            Distance := (Distance + (CurrentVelocity/1.5*0.05) - (CurrentVelocity *0.05)); --velocidade do obstaculo em movimento
            if Distance > 6.0 then
               DistanceValue.Write (-1.0,Friction);
            elsif Distance < 0.25 then
               DistanceValue.Write (0.0,Friction);
               Distance := 0.0;
            else
               DistanceValue.Write (Distance,Friction);
            end if;
         end if;
         Next_Time := Next_Time + Interval;
      end loop;
   end VehicleDetectionSensor;

   task body Brake is
      Next_Time : Calendar.Time     := Calendar.Clock + Duration(0.01);
      ResAcelaration : Float;
      VelocityInital, Distance : Float;
       Acelarator : Boolean := True;
   begin
      loop
         delay until Next_Time;
         AcelaratorState.Read(Acelarator);
         if Acelarator = False then
            BreakPressure.Read(VelocityInital,Distance);
            ResAcelaration := CalculateAcelaration(VelocityInital,Distance);
            if ResAcelaration > 0.0 then
               put_line("Errp aceleração possitiva");
               ResAcelaration := 0.0;
            end if;
            WheelAcelaration.Write(ResAcelaration);
         end if;
         Next_Time := Next_Time + Interval;
      end loop;
   end Brake;

   task body Wheel is
      CurrentSpeedMs : Float := initialSpeed;
      NewCurrentSpeed : Float;
      NewAcelaration : Float;
      Next_Time : Calendar.Time     := Calendar.Clock;
      S: Semaphore;
   begin
      loop
         delay until Next_Time;
         WheelAcelaration.Read(NewAcelaration);
         NewCurrentSpeed := CurrentSpeedMs + NewAcelaration * 0.05;     --REVER!!!!
         CurrentSpeedMs := NewCurrentSpeed;
         if CurrentSpeedMs < 0.1 then
            CurrentSpeedMs := 0.0;
         end if;
         WheelVelocity.Write(CurrentSpeedMs);
         Next_Time := Next_Time + Interval;
      end loop;
   end Wheel;

   task body Accelerator is
      Next_Time : Calendar.Time     := Calendar.Clock + Duration(0.01);
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
      Next_Time : Calendar.Time     := Calendar.Clock + Duration(0.01);
      CurrentSpeed : Float := -2.0;
      DistanceNextObstacle : Float := -2.0;
      EstimatedSafeDistance : Float;
      Friction : Float;
      DriverSafeBreakDistance : Float;
      EstimatedSafeBrakeTime : Float := 0.0;
      I : Integer;
      S: Semaphore;
   begin
      loop
         delay until Next_Time;

         WheelVelocity.Read(CurrentSpeed);
         DistanceValue.Read(DistanceNextObstacle,Friction);
         DriverSafeBreakDistance := CurrentSpeed * 3.0;
         --
         --s.Acquire;
         --
         --put(DistanceNextObstacle);
         if (DistanceNextObstacle < 0.0) then  -- retorna valor negativo quando o alcance do lazer (6m) não detecta obstaculos
            AcelaratorState.Write(True);
            put_line("too far away");
            new_line;
            --
            --s.Release;
            --
         else
            if (CurrentSpeed = 0.0) then
               Put_Line("Carro parado"); -- batota rever
               AcelaratorState.Write(True); -- acelaracao 0 + velocidade 0 =
            elsif (DriverSafeBreakDistance < DistanceNextObstacle) then
               AcelaratorState.Write(True);
               Put_Line("ALERT obstaculo");
               Put_Line("Distancia: ");
               put(DistanceNextObstacle);
               new_line;
               --
               --s.Release;
               --
            else
               I := 0;
               loop
                  I := I+1;
                  EstimatedSafeDistance := CalcStoppingDistance(CurrentSpeed,Friction,Float(I));
                  if EstimatedSafeDistance < DistanceNextObstacle then
                     exit;
                  end if;
                  exit when I >= 8;
               end loop;
               put_line("*******************************************************");
               put_line("travao automatico! forca: ");
               put(I);
               new_line;
               put_line("velocidade: ");
               put(CurrentSpeed);
               new_line;
               put_line("distancia: ");
               put(DistanceNextObstacle);
               new_line;
               put_line("EstimatedSafeDistance: ");
               put(EstimatedSafeDistance);
               new_line;
               AcelaratorState.Write(False);
               BreakPressure.Write(CurrentSpeed,EstimatedSafeDistance);    -- REVER DistanceNextObstacle vs EstimatedSafeDistance
               put_line("*******************************************************");
               --
               --s.Release;
               --
            end if;
         end if;
         Next_Time := Next_Time + Interval;
      end loop;
   end CAS;

begin
   null;
end Socof;
