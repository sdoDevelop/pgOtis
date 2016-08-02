
-- ##################################
-- ###### Create Otis Database ######
-- ##################################




-- Create our schemas
	
	-- Main Schema
	Create Schema main_schema;
	Alter Schema main_schema 
		Owner To serveradmin
		;

	-- Notification Schema
	Create Schema notification_schema;
	Alter Schema notification_schema
		Owner To serveradmin
		;

	-- Client Server Creation Schema
	Create Schema client_server_schema;
	Alter Schema client_server_schema
		Owner To serveradmin
		;

-- Change some environment variables for users
	Alter Role general_user SET search_path to main_schema;




-- Set up our Extensions

	-- plpsql
	CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
	COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

	-- uuid-ossp
	CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA main_schema;
	COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


-- #################################################
-- ############         Tables         #############
-- #################################################

Set search_path = main_schema, pg_catalog;

-- Now we move on to creating our tables in the table Schema

-- mGlobal
	-- this table contains the definition for the main identification fields that all tables use
	CREATE TABLE "mGlobal" (
	    pkid text ,
	    row_created timestamp with time zone ,
	    row_modified timestamp with time zone ,
	    row_username text  
	);


	ALTER TABLE "mGlobal" OWNER TO serveradmin;


-- Item Descriptors
	-- this tables contains the colums for main parts of an inventory item
	CREATE TABLE itemdescriptors (
	    name_ text,
	    manufacturer text,
	    model text,
	    department text,
	    category text,
	    subcategory text,
	    description text,
	    price integer DEFAULT 0 ,
	    quantity_ integer DEFAULT 0
	)
	INHERITS ("mGlobal");

	ALTER TABLE itemdescriptors OWNER TO serveradmin;

	COMMENT ON COLUMN itemdescriptors.price IS 'stored as cents';


-- Events Table
	CREATE TABLE events_ (
	    name text DEFAULT '...'::text ,
	    start_ts timestamp with time zone  ,
	    end_ts timestamp with time zone ,
	    loadin_ts timestamp with time zone ,
	    loadout_ts timestamp with time zone ,
	    details text,
	    acountmanager_ text,
	    startdate_ date ,
	    enddate_ date ,
	    loadindate_ date ,
	    loadoutdate_ date ,
	    starttime_ time without time zone ,
	    endtime_ time without time zone ,
	    loadintime_ time without time zone ,
	    loadouttime_ time without time zone 
	)
	INHERITS ("mGlobal");


	ALTER TABLE events_ OWNER TO serveradmin;


-- Line Item Table
	CREATE TABLE lineitems (
	    name_ text,
	    manufacturer text,
	    model text,
	    department text,
	    category text,
	    subcategory text,
	    description text,
	    fkeipl text,
	    fkinventory text,
	    type_ text,
	    note_ text,
	    rate_ text ,
	    discounttype_ text ,
	    total_ integer ,
	    time_ double precision ,
	    discount_ integer ,
	    discountperc_ integer,
	    discountamount_ integer,
	    taxable_ boolean,
	    taxtotal_ integer ,
	    quantity double precision,
	    ignore_price_discrepency boolean 
	)
	INHERITS ("mGlobal", itemdescriptors);

	ALTER TABLE lineitems OWNER TO serveradmin;

	COMMENT ON COLUMN lineitems.taxtotal_ IS 'stored as cents';


-- Create the EIPL Table
	CREATE TABLE eipl (
	    fkevents_ text,
	    eipl_nmbr integer ,
	    fkdiscounts text,
	    duedate date  ,
	    type_ text ,
	    balance_ integer,
	    grandtotal_ integer,
	    subtotal_ integer,
	    discount_ integer,
	    lidiscountsum_ integer,
	    tax_ integer ,
	    totalpaid_ integer ,
	    discounttype_ text ,
	    discountperc_ integer,
	    discountamount_ integer,
	    shippingmethod_ text,
	    taxtotal_ integer ,
	    discounttotal_ integer 
	)
	INHERITS ("mGlobal");


	ALTER TABLE eipl OWNER TO serveradmin;

	COMMENT ON COLUMN eipl.balance_ IS 'stored as cents';
	COMMENT ON COLUMN eipl.grandtotal_ IS 'stored as cents';
	COMMENT ON COLUMN eipl.subtotal_ IS 'stored in cents';
	COMMENT ON COLUMN eipl.discount_ IS 'stored as cents';
	COMMENT ON COLUMN eipl.lidiscountsum_ IS 'stored as cents';
	COMMENT ON COLUMN eipl.totalpaid_ IS 'stored as cents';
	COMMENT ON COLUMN eipl.discountamount_ IS 'stored as cents';
	COMMENT ON COLUMN eipl.taxtotal_ IS 'stored as cents';
	COMMENT ON COLUMN eipl.discounttotal_ IS 'stored as cents';

	CREATE SEQUENCE "EIPL_EIPL_nmbr_seq"
	    START WITH 1
	    INCREMENT BY 1
	    NO MINVALUE
	    NO MAXVALUE
	    CACHE 1;

	ALTER TABLE "EIPL_EIPL_nmbr_seq" OWNER TO serveradmin;
	ALTER SEQUENCE "EIPL_EIPL_nmbr_seq" OWNED BY eipl.eipl_nmbr;


-- Create the Table Contact Venue Data
	CREATE TABLE contact_venue_data (
	    fkcontacts text,
	    fkvenues text,
	    fkevents_ text,
	    fkeipl text,
	    primary_ boolean 
	)
	INHERITS ("mGlobal");


	ALTER TABLE contact_venue_data OWNER TO serveradmin;


-- Create the table contact Details
	-- contains columns that all contacts tables need
	CREATE TABLE contactdetails (
	    email text,
	    phonecountry text,
	    phoneareacode text,
	    phonemain text,
	    addressline1 text,
	    addressline2 text,
	    addresscity text,
	    addressstate text,
	    addresszip text,
	    addresscountry text,
	    fkconven text,
	    company text,
	    "primary" text
	)
	INHERITS ("mGlobal");


	ALTER TABLE contactdetails OWNER TO serveradmin;


-- Create the Table Contacts
	CREATE TABLE contacts (
	    namefirst text,
	    namelast text,
	    jobtitle text
	)
	INHERITS ("mGlobal", contactdetails);


	ALTER TABLE contacts OWNER TO serveradmin;


-- Create Contracts Table
	CREATE TABLE contracts_ (
    	contract_number text 
	)
	INHERITS ("mGlobal");


	ALTER TABLE contracts_ OWNER TO serveradmin;


	CREATE SEQUENCE contract_number_sequence
	    START WITH 1
	    INCREMENT BY 1
	    NO MINVALUE
	    NO MAXVALUE
	    CACHE 1;


	ALTER TABLE contract_number_sequence OWNER TO serveradmin;


-- Create the Contract Sections Table
	CREATE TABLE contract_sections_ (
	    content_ text,
	    section_number_ integer
	)
	INHERITS ("mGlobal");


	ALTER TABLE contract_sections_ OWNER TO serveradmin;


-- Create the Discounts Table
	CREATE TABLE discounts_ (
	    fkeipl text,
	    department_ text,
	    type_ text ,
	    amount_ integer ,
	    grandtotal_ integer,
	    subtotal_ integer,
	    discountperc_ integer,
	    discountamount_ integer
	)
	INHERITS ("mGlobal");


	ALTER TABLE discounts_ OWNER TO serveradmin;

	COMMENT ON COLUMN discounts_.amount_ IS 'stored as cents';
	COMMENT ON COLUMN discounts_.grandtotal_ IS 'stored in cents';
	COMMENT ON COLUMN discounts_.subtotal_ IS 'stored in cents';


-- Create our Inventory Table
	CREATE TABLE inventory (
	    name_ text,
	    manufacturer text,
	    model text,
	    department text,
	    category text,
	    subcategory text,
	    description text,
	    price integer ,
	    "fkItemTypes" text,
	    owner text,
	    taxable_ text 
	)
	INHERITS ("mGlobal", itemdescriptors);


	ALTER TABLE inventory OWNER TO serveradmin;

	COMMENT ON COLUMN inventory.price IS 'stored as cents';


-- Create our Payments Table
	CREATE TABLE payments_ (
	    date_ date  ,
	    memo_ text,
	    amount_ integer ,
	    paymenttype_ text,
	    fkeipl text
	)
	INHERITS ("mGlobal");


	ALTER TABLE payments_ OWNER TO serveradmin;

	COMMENT ON COLUMN payments_.amount_ IS 'stored in cents';


-- Create Venues Table
	CREATE TABLE venues (
	    name text,
	    type text
	)
	INHERITS ("mGlobal", contactdetails);


	ALTER TABLE venues OWNER TO serveradmin;


--



SET search_path = notification_schema, pg_catalog;


-- Template Table for notifications
	CREATE TABLE template_ (
	    row_created timestamp with time zone DEFAULT now(),
	    pkid text DEFAULT main_schema.uuid_generate_v4() NOT NULL,
	    row_modified text,
	    lineitem_pkids text,
	    lineitem_name text,
	    checked_ boolean DEFAULT false,
	    notification_type text,
	    event_pkid_ text
	);


	ALTER TABLE template_ OWNER TO serveradmin;



SET search_path = client_server_schema, pg_catalog;


-- Create the table to store our server scripts
	Create client_server_scripts (
		order_number_ 	integer,
		contents_
		)
		;
	Alter Table client_server_scripts To serveradmin;






-- #################################################
-- ############        Funtions        #############
-- #################################################



Set search_path = main_schema, pg_catalog;


-- Create our Functions for the functions schema

-- Creating Login_tasks
	CREATE FUNCTION login_tasks() RETURNS text
	    LANGUAGE plpgsql
	    AS $$
	    -- This will take care of any login tasks that need to happen

		Declare
			tablename_			text;
			sql_string			text;
			n1					integer;
			s1					text;


		Begin

			-- Concoct our table name
			tablename_ = 'notification.' || current_user || '_rap' ;

			-- Check if we have a table for this user already
			Select Count(*) Into n1 From information_schema.tables Where table_name = tablename_;

			If n1 = 0 Then
				sql_string = 'Create Table If Not Exists ' || tablename_ || ' ( test text, CONSTRAINT ' || current_user || '_pkid PRIMARY KEY(pkid) ) Inherits( notification.template_ )';
				Execute sql_string;
				sql_string = 'Delete From ' || tablename_ ;
				Execute sql_string;
				n1 = n1 + 1;
			Else
				n1 = 11;
			End If;

			s1 = to_char( n1, '999' );

		Return s1;
		End
		$$;


	ALTER FUNCTION main_schema.login_tasks() OWNER TO serveradmin;





-- Create Contract Number Function
-- Currently Unused **
	CREATE FUNCTION create_contract_number() RETURNS text
	    LANGUAGE plpgsql
	    AS $$
	-- create_contract_id
		-- Triggerd From 
		-- Triggered on Insert into contracts_
		-- Purpose is to 
			-- create a new id for a contract

	Declare
		n1		integer;
		n2		integer;
		s1		text;
		year_currval	int;
		final_id 	text;
		next_seq_value 	int;


	Begin

		-- set the current year
		s1 = 'year';
		year_currval = date_part( s1, current_timestamp );
		
		-- store the full year for later use
		n1 = year_currval;
		
		-- grab just the last 2 numbers of the year
		s1 = cast( year_currval as text );
		s1 = right( s1, 2 );
		year_currval = cast( s1 as int );

		-- check if any eipls exist from this year
		Select count(*) Into n2 From contracts_ Where date_part( 'year', contracts_.row_created ) = n1;

		-- if no eipls from this year exit we reset the sequence to 1000
		If n2 = 0 Then
			n1 = 1000;
			Perform setval( 'contract_number_sequence', n1 );
		End If;


		-- Pull the next value from contract_number_sequence
		next_seq_value = nextval( 'contract_number_sequence' );

		--Combine into final id
		final_id = cast( year_currval as text ) || '-' || cast( next_seq_value as text );

	Return final_id;
	End
	$$;

	ALTER FUNCTION main_schema.create_contract_number() OWNER TO serveradmin;



-- Line Item to Inventory Funciton
	CREATE FUNCTION lineitem_to_inventory(lineitem_id text) RETURNS text
	    LANGUAGE plpgsql
	    AS $$DECLARE
	    result TEXT;
	BEGIN
	    INSERT INTO inventory ( name_, manufacturer, model, department, category, subcategory, description, price )
	    SELECT name_, manufacturer, model, department, category, subcategory, description, price
	    FROM lineitems
	    WHERE pkid = lineitem_id
	    RETURNING pkid INTO result;
	  RETURN result;
	END;$$;


	ALTER FUNCTION main_schema.lineitem_to_inventory(lineitem_id text) OWNER TO serveradmin;



-- Make Next Eipl Function
	CREATE FUNCTION mknexteipl(p_pkid text DEFAULT 'none'::text, p_mode integer DEFAULT '-1'::integer) RETURNS text
	    LANGUAGE plpgsql
	    AS $_$-- Modes
	    -- 0	Duplicate
	    -- 1	Duplicate and advance eipl type


	Declare

	v_testvar Text;

	    v_ogpkid 		Text;
	    v_newpkid		Text;
	    v_childpkid		Text;
	    v_newchildpkid      Text;

	    v_tablename 	Text;
	    v_tablenamearray 	Text;
	    v_executesql  	Text;
	    v_columnnamearray  	Text;
	    v_eipltype		Text;
	    
	Begin

	    -- Exiting Script if no pkid was specified
	    If p_pkid = 'none' Then
		Return 'nopkid';
	    End if;


	    -- Variables
	    v_ogpkid = p_pkid;


	    -- Duplicating EIPL
	    Select 	string_agg( column_name, ', ' ) 
	    Into 	v_columnnamearray 
	    From 	information_schema.columns 
	    Where 	table_name = 'eipl'
	    And		column_name <> 'pkid'
	    And 	column_name <> 'row_created'
	    And 	column_name <> 'row_modified'
	    And 	column_name <> 'row_username'
	    And 	column_name <> 'eipl_nmbr'
	    And		column_name <> 'row_in_use';

	    v_executesql = $$ Insert Into eipl ( $$ || v_columnnamearray || $$ ) ( ( Select $$ || v_columnnamearray || $$ From eipl Where pkid = '$$ || v_ogpkid || $$' ) ) Returning pkid $$ ;
	    Execute v_executesql Into v_newpkid;

	    Select type_ Into v_eipltype From eipl Where pkid = v_newpkid;
	    If p_mode = 1 then
		-- Determining the type of the new EIPL
		If v_eipltype = 'Estimate' Then
		    v_eipltype = 'Invoice'; 
		Elsif v_eipltype = 'Invoice' Then
		    v_eipltype = 'Pack List';
		Elsif v_eipltype = 'Pack List' Then
		    Return 'Nowhere to go from Pack List';
		Else 
		    Return 'No EIPL type Specified';
		End if;
	    End if;

	    Update eipl set type_ = v_eipltype Where pkid = v_newpkid;

	    -- Loop through all tables in public SCHEMA that have a fkeipl column
	    For v_tablename In
		Select table_name
		From   information_schema.columns
		Where  column_name = 'fkeipl'
		And    table_schema = 'public'
	    Loop
		
		-- Find all the columns in the table except pkid and fkeipl
		v_executesql = $$
				Select	 string_agg( column_name, ', ' ) 
				From 	information_schema.columns 
				Where 	table_name = $1
				And 	column_name <> 'pkid' 
				And 	column_name <> 'fkeipl' 
				And	column_name <> 'pkid'
				And 	column_name <> 'row_created'
				And 	column_name <> 'row_modified'
				And 	column_name <> 'row_username'
			       $$;
		Execute v_executesql Into v_columnnamearray Using v_tablename ;

		-- prepare our sql string for execute
		v_executesql = 'Select pkid From main_schema.' || v_tablename || ' Where fkeipl = $1 ';

		-- Loop through all of the records in current table that have 
		For v_childpkid In
		    Execute  v_executesql Using v_ogpkid
		Loop

		    -- Duplicate Record and change fkeipl to v_newpkid
		    v_executesql = $$Insert Into $$ || v_tablename || $$ ( $$ || v_columnnamearray || $$ ) ( ( Select $$ || v_columnnamearray || $$ From $$ || v_tablename || $$ Where pkid = '$$ || v_childpkid || $$' ) ) Returning pkid $$;

		    Execute v_executesql Into v_newchildpkid ;

		    v_executesql = $$Update $$ || v_tablename || $$ Set fkeipl = '$$ || v_newpkid || $$' Where pkid = '$$ || v_newchildpkid || $$' $$;
		    Execute v_executesql;

		End loop;

	    End Loop;



	Return v_newpkid ;
	End;
	$_$;


	ALTER FUNCTION main_schema.mknexteipl(p_pkid text, p_mode integer) OWNER TO serveradmin;


-- New EIPL function
	CREATE FUNCTION new_eipl_function() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $_$
	DECLARE
	    v_eipl_pkid TEXT;
	    v_event_pkid TEXT;
	    v_return_record contact_venue_data;
	BEGIN
	    v_eipl_pkid = NEW.pkid;
	    v_event_pkid = NEW.fkevents_;

	    FOR v_return_record IN
		SELECT *
		FROM main_schema.contact_venue_data cvd
		WHERE cvd.fkevents_ = v_event_pkid
		AND cvd.primary_ = True
	    LOOP
		EXECUTE(FORMAT($f$
		    INSERT INTO contact_venue_data ( fkeipl, fkcontacts, fkvenues, primary_ )
			VALUES ( %L, %L, %L, True );
			$f$, v_eipl_pkid, v_return_record.fkcontacts, v_return_record.fkvenues ));
	    END LOOP;
	RETURN NEW;
	END;
	$_$;


	ALTER FUNCTION main_schema.new_eipl_function() OWNER TO serveradmin;


-- Create New Payment Function
	CREATE FUNCTION newpayment(p_pkid text DEFAULT 'none'::text) RETURNS text
	    LANGUAGE plpgsql
	    AS $$Declare
	    v_return 		Text;

	Begin

	    Insert Into payments_ (fkeipl) Values(p_pkid) Returning pkid Into v_return;

	    Return v_return;

	End;$$;


	ALTER FUNCTION main_schema.newpayment(p_pkid text) OWNER TO serveradmin;











































































