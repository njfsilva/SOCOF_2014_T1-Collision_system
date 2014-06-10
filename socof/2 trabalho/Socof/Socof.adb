with Calendar, Ada.Text_IO,Ada.Integer_Text_IO; use Calendar, Ada.Text_IO,Ada.Integer_Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;
procedure Socof is

   protected WheelRotation is
      procedure Write (NewSpeed : in Integer);
      procedure Read (CurSpeed : out Integer);
   private
      CurrentSpeed : Integer := 0;
   end WheelRotation;

   protected BreakPressure is
      procedure Write (NewPressure : in Float);
      procedure Read (NewPressure : out Float);
   private
      Pressure : Float := 0.0;
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
      entry Request(NewPressure : out Float);
   end;



   protected body WheelRotation is
      procedure Write (NewSpeed : Integer) is
      begin
         CurrentSpeed := NewSpeed;
      end Write;

      procedure Read (CurSpeed : out Integer) is
      begin
         CurSpeed := CurrentSpeed;
      end Read;
   end WheelRotation;

   protected body BreakPressure is
      procedure Write (NewPressure : Float) is
      begin
         Pressure := NewPressure;
      end Write;
      procedure Read (NewPressure : out Float) is
      begin
         NewPressure := Pressure;
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
   begin
      loop
         accept Request(NewPressure : out Float) do
            BreakPressure.Read(NewPressure);

         end Request;
      end loop;
   end Brake;

   function ConverKmhToMs (Kmh : Float) return Float is
   begin
      return (5.0 * Kmh)/18.0;
   end ConverKmhToMs;

   function CalcStoppingDistance (Kmh,CoefFriction,BrakeAct : Float) return Float is
   begin
      return 8.0*( ((Kmh/3.6)**2) / (2.0*9.81*BrakeAct*CoefFriction));
   end CalcStoppingDistance;

   function CalculateAcelaration (Vinicial,Dist : Float) return Float is
   begin
      return -(Vinicial**2)/(2.0*Dist);
   end CalculateAcelaration;

   function CalculateTime (Vinicial,Dist : Float) return Float is
   begin
      return (2.0*Dist)/Vinicial;
   end CalculateTime;

begin
   delay 3.0;
end Socof;
