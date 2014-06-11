with Calendar, Ada.Text_IO,Ada.Integer_Text_IO; use Calendar, Ada.Text_IO,Ada.Integer_Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;
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
      procedure Write (newDistance : in Float);
      procedure Read (CurDistance : out Float);
   private
      Distance : Float := 100.0;
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
      entry Request2(CurDistance : out Float);
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
      procedure Write (newDistance : Float) is
      begin
         Distance := newDistance;
      end Write;

      procedure Read (CurDistance : out Float) is
      begin
         CurDistance := Distance;
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
      Distance : Float := 20.0;
   begin
      loop
         delay until Next_Time;
         DistanceValue.Write (Distance);
         Next_Time := Next_Time + Interval;
      end loop;
   end VehicleDetectionSensor;

   task body Brake is
      ResAcelaration : Float;
   begin
      loop
         accept Request(Vi,Dist : out Float) do
            BreakPressure.Read(Vi,Dist);
            ResAcelaration := CalculateAcelaration(Vi,Dist);
            WheelAcelaration.Write(ResAcelaration);
         end Request;
      end loop;
   end Brake;

   task body Wheel is
      CurrentSpeedMs : Float;
      NewCurrentSpeed : Float;
      CurrentSpeedKmh : Float := 30.0;
      Next_Time : Calendar.Time     := Calendar.Clock;
   begin
      loop
         delay until Next_Time;
         accept Request(NewSpeed : out Float) do
            WheelAcelaration.Read(NewSpeed);
            CurrentSpeedMs := ConverKmhToMs(CurrentSpeedKmh);
            NewCurrentSpeed := CurrentSpeedMs + NewSpeed * 0.2;     --REVER!!!!
            CurrentSpeedKmh := ConverMsToKmh(NewCurrentSpeed);
            WheelVelocity.Write(CurrentSpeedKmh);
            Next_Time := Next_Time + Interval;
        end Request;
      end loop;
   end Wheel;

   task body Accelerator is
      Acelarator : Boolean := True;
   begin
      loop
         accept Request(newState : out Boolean) do
            AcelaratorState.Read(newState);
            Acelarator := newState;
            if newState = True Then
               WheelAcelaration.Write(0.0);
            end if;
         end Request;
      end loop;
   end Accelerator;

   task body CAS is
      Acelarator : Boolean := True;
      CurrentSpeed : Float;
      DistanceNextObstacle : Float;
      EstimatedSafeDistance : Float;
      EstimatedSafeBrakeTime : Float := 0.0;
      I : Integer := 1;
   begin
      loop
         accept Request(CurSpeed : out Float) do
            WheelVelocity.Read(CurSpeed);
            CurrentSpeed := CurSpeed;
         end Request;
         accept Request2(CurDistance : out Float) do
            DistanceValue.Read(CurDistance);
            DistanceNextObstacle := CurDistance;
         end Request2;
         if  DistanceNextObstacle >= 200.0 then
            AcelaratorState.Write(True);
         else
            loop
               EstimatedSafeDistance := CalcStoppingDistance(CurrentSpeed,0.7,Float(I));
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
      end loop;
   end CAS;

begin
   delay 3.0;
end Socof;
