with Ada.Unchecked_Deallocation;
with Ada.Text_IO;

package body Hash_Maps_G is

	procedure Free is new Ada.Unchecked_Deallocation
								(Cell, Cell_A); 



    procedure Get(M: in out Map; Key: in Key_Type; Value: out Value_Type; Success: out Boolean) is
        P_Aux: Cell_A;
		Index: Hash_Range;  
    begin
		Index := Hash(Key);
        Success := False;
		P_Aux := M.P_Array(Index).P_First;
		while not Success and P_Aux /= null loop
			if P_Aux.Key = Key then
				Value := P_Aux.Value;
				Success := True;
			end if;
			P_Aux := P_Aux.Next;	
		end loop;
    end Get;

    procedure Put(M: in out Map; Key: Key_Type; Value: Value_Type) is
        P_Aux: Cell_A := null;
        P_Aux_2: Cell_A := null;
        Success: Boolean := False;
		Index: Hash_Range;
    begin
		Index := Hash(Key);
		P_Aux := M.P_Array(Index).P_First;
		P_Aux_2 := M.P_Array(Index).P_First;
		if M.P_Array(Index).P_First = null then
			P_Aux := new Cell;
			P_Aux.Key := Key;
			P_Aux.Value := Value;
			M.P_Array(Index).P_First := P_Aux;
			M.Length := M.Length + 1;
		end if;
		while not Success and P_Aux /= null loop
			if P_Aux.Key = Key then
				P_Aux.Value := Value;
				Success := True;
			end if;
			P_Aux_2 := P_Aux;
			P_Aux := P_Aux.Next;
		end loop;
		if not Success and P_Aux = null then
			P_Aux := new Cell;
			P_Aux.Key := Key;
			P_Aux.Value := Value;
			P_Aux_2.Next := P_Aux;
			M.Length := M.Length + 1;
		end if;		
    end Put;

    procedure Delete(M: in out Map; Key: in Key_Type; Success: out Boolean) is
        P_Aux: Cell_A := null;
        P_Aux_2: Cell_A := null;
		Index: Hash_Range;
    begin
		Index := Hash(Key);
		Success := False;
		P_Aux := M.P_Array(Index).P_First;
		P_Aux_2 := M.P_Array(Index).P_First;
		if M.P_Array(Index).P_First = null then
			Success := False;
		else
			if P_Aux.Key = Key then
				M.P_Array(Index).P_First := P_Aux.Next;
				Free(P_Aux);
				Success := True;
				M.Length := M.Length - 1;
			end if;
				while not Success and P_Aux /= null loop
					if P_Aux.Key = Key then
						P_Aux_2.Next := P_Aux.Next;
						Free(P_Aux);
						Success := True;
						M.Length := M.Length - 1;	
					end if;
					P_Aux_2 := P_Aux;
					P_Aux := P_Aux.Next;
				end loop;
		end if;
    end Delete;

    function Map_Length (M:Map) return Natural is
     
    begin

        return M.Length;

    end Map_Length; 

    

    function First (M:Map) return Cursor is
      	C: Cursor;
		Found: Boolean := False;
    begin
		C.M := M;
		C.Index := 0;
		while C.Index <= Hash_Range'Last and not Found loop
			if C.M.P_Array(C.Index).P_First /= null then
				C.Element_A := C.M.P_Array(C.Index).P_First;
				Found := True;
			end if;
			if C.M.P_Array(C.Index).P_First = null then
				C.Index := C.Index + 1;
				if C.Index = 0 then
					Found := True;
				end if;
			end if;
		end loop;
		return C;
    end First;

    procedure Next (C: in out Cursor) is
		Found: Boolean := False;
    begin
		while C.Index < Hash_Range'Last and not Found loop
			if C.Element_A /= null then
				C.Element_A := C.Element_A.Next;
				Found := True;
			end if;
			if C.Element_A = null then
				C.Index := C.Index + 1;
				if C.Index = 0 then --Cuando llega a 0 sale del bucle,esto lo pongo para que no entre en bucle porque al comparar C.Index con hash_range'Last al ser modular del útlimo vuelve a pasar a 0
					Found := True;
				end if;
				if C.M.P_Array(C.Index).P_First /= null then
					C.Element_A := C.M.P_Array(C.Index).P_First;
					Found := True;
				else
					C.Element_A := null;
					Found := False;
				end if;
			end if;
		end loop;
    end Next;

  

    function Has_Element (C:Cursor) return Boolean is
       Bool: Boolean;
    begin
        if C.Element_A /= null then
            Bool := True;
        else
            Bool := False;
        end if;
        return Bool;
    end Has_Element;

    function Element (C:Cursor) return Element_Type is
        Elem: Element_Type;
    begin
        if not Has_Element(C) then
            raise No_Element;
        end if;
        Elem.Key := C.Element_A.Key;
        Elem.Value := C.Element_A.Value;
        return Elem;
    end Element;
end Hash_Maps_G;
