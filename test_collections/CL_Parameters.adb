with Ada.Command_Line;

package body CL_Parameters is
   package ACL  renames Ada.Command_Line;

   MAX_CAPACITY_DEFAULT : constant := 50;

   function Max_Items return Natural is
   begin
      if ACL.Argument_Count /= 1 then
         return MAX_CAPACITY_DEFAULT;
      end if;

      return Natural'Value(ACL.Argument(1));

   exception
      when Constraint_Error => return MAX_CAPACITY_DEFAULT;
   end Max_Items;

end CL_Parameters;
