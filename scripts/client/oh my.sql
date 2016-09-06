-- #################################################
-- ############        Funtions        #############
-- #################################################




Set search_path = info_schema, pg_catalog;
-- --eol-- --

	-- Create the Trigger Function
		CREATE FUNCTION calc_dept_totals_triggfunc() RETURNS trigger
	 	   LANGUAGE plpgsql
	    	AS $$
	    Declare
			v_field_name 		Text;
			v_executesql		Text;
			v_new_value			Text;
			v_old_value			Text;
			v_field_string		Text;
			v_value_string		Text;
			v_sql_string		Text;
			v_counter			Integer;
		Begin
		
			v_counter = 0

			For v_field_name In 
				-- grab all of the field names
				Select column_name 
				From information_schema.columns
				Where table_name = tg_table_name
			Loop

				-- grab the new value for current field
				v_executesql = 
					$$
					Select || v_field_name || From New Into v_new_value;
					$$;
				Execute v_executesql;

				-- grab the old value for current field
				v_executesql = 
					$$
					Select || v_field_name || From New Into v_old_value;
					$$;
				Execute v_executesql;



				-- compare the two values
				If v_new_value <> v_old_value Then
					If v_counter <> 0 Then
						v_field_string = v_field_string || ", ";
						v_value_string = v_value_string || ", ";
					End if;

					v_field_string = v_field_string || v_field_name;
					v_value_string = v_value_string || v_new_value;
				End If;


			End Loop;

			If TG_OP = "INSERT"
				v_sql_string = 
					"Insert Into " || TG_Schema_Name || "." || TG_Table_Name 
					|| " " ||
					v_field_string 
					|| " Values ( " || v_value_string || " ) ; "
				;


			Elseif TG_OP = "UPDATE"
				v_sql_string = 
					"Update " || TG_Schema_Name || "." || TG_Table_Name 
					|| " Set ( " || v_field_string 
					|| " ) = ( " || v_value_string || " ) Where pkid = '" 


			Elseif TG_UPDATE = "DELETE"

			End If;

			
				
			Insert Into info_schema.sql_log 
				( creation_ts, username_, sql_statement )
				Values( now(), "nouser", v_sql_string );

			Return New;

		End;$$;
