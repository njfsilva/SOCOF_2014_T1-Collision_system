with Calendar, Ada.Text_IO,Ada.Integer_Text_IO; use Calendar, Ada.Text_IO,Ada.Integer_Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;
procedure Socof is

   protected WheelRotation is
      procedure Write (NewSpeed : in Float);
      procedure Read (CurSpeed : out Float);
   private
      CurrentSpeed : Float := 0.0;
   end WheelRotation;

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







   protected body WheelRotation is
      procedure Write (NewSpeed : Float) is
      begin
         CurrentSpeed := NewSpeed;
      end Write;

      procedure Read (CurSpeed : out Float) is
      begin
         CurSpeed:= CurrentSpeed;
      end Read;
   end WheelRotation;

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

   function CalcStoppingDistance (Kmh,CoefFriction,BrakeAct : Float) return Float is
   begin
      return 8.0*( ((Kmh/3.6)**2) / (2.0*9.81*BrakeAct*CoefFriction));
   end CalcStoppingDistance;

   function CalculateTime (Vinicial,Dist : Float) return Float is
   begin
      return (2.0*Dist)/Vinicial;
   end CalculateTime;








   task body VehicleDetectionSensor is

      Interval  : constant Duration := Duration(0.2);--Duration (43_200);
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
            WheelRotation.Write(ResAcelaration);
         end Request;
      end loop;
   end Brake;

   task body Wheel is
      CurrentSpeed : Float := 30.0;
   begin
      loop
         accept Request(NewSpeed : out Float) do
            CurrentSpeed := NewSpeed;
         end Request;
      end loop;
   end Wheel;



begin
   delay 3.0;
end Socof;