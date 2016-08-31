
-- ##################################
-- ###### Create Otis Database ######
-- ##################################




-- Create our schemas
	
	-- Main Schema
	Create Schema main_schema;
-- --eol-- --
	Alter Schema main_schema 
		Owner To serveradmin
		;
-- --eol-- --
	-- Notification Schema
	Create Schema notification_schema;
-- --eol-- --
	Alter Schema notification_schema
		Owner To serveradmin
		;
-- --eol-- --
	-- info_schema Schema
	Create Schema info_schema;
	-- --eol-- --
	Alter schema info_schema
		Owner To serveradmin
		;
-- --eol-- --
-- Change some environment variables for users
	Alter Role general_user SET search_path to main_schema;
-- --eol-- --



-- Set up our Extensions

	-- plpsql
	CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
-- --eol-- --
	COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
-- --eol-- --

	-- uuid-ossp
	CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA main_schema;
	-- --eol-- --
	COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
-- --eol-- --


Set search_path = info_schema, pg_catalog;
-- --eol-- --

-- Database information table
	Create Table "dbinfo" (
		pkid text DEFAULT main_schema.uuid_generate_v4() Not Null,
		major_version Integer, 
		minor_version Integer, 
		build_version Integer 
		);
-- --eol-- --
	Alter Table dbinfo Owner to serveradmin;
-- --eol-- --

	-- This is where all of our sql queries get stored for server upload
	Create Table "sql_log" (
		pkid text Default main_schema.uuid_generate_v4() Not Null,
		creation_ts timestamp with time zone, 
		username_ text, 
		sql_statement text
		);


-- #################################################
-- ############         Tables         #############
-- #################################################

Set search_path = main_schema, pg_catalog;
-- --eol-- --

-- Now we move on to creating our tables in the table Schema

-- mGlobal
	-- this table contains the definition for the main identification fields that all tables use
	CREATE TABLE "mGlobal" (
	    pkid text DEFAULT main_schema.uuid_generate_v4() NOT NULL,
	    row_created timestamp with time zone DEFAULT now() NOT NULL,
	    row_modified timestamp with time zone DEFAULT now() NOT NULL,
	    row_username text DEFAULT "current_user"() NOT NULL 
	);
-- --eol-- --

	ALTER TABLE "mGlobal" OWNER TO serveradmin;
-- --eol-- --

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
-- --eol-- --
	ALTER TABLE itemdescriptors OWNER TO serveradmin;
-- --eol-- --
	COMMENT ON COLUMN itemdescriptors.price IS 'stored as cents';
-- --eol-- --

-- Events Table
	CREATE TABLE events_ (
	    name text DEFAULT '...'::text ,
	    start_ts timestamp with time zone DEFAULT now() ,
	    end_ts timestamp with time zone DEFAULT now() ,
	    loadin_ts timestamp with time zone DEFAULT now() ,
	    loadout_ts timestamp with time zone DEFAULT now() ,
	    details text,
	    acountmanager_ text,
	    startdate_ date DEFAULT ('now'::text)::date,
	    enddate_ date DEFAULT ('now'::text)::date,
	    loadindate_ date DEFAULT ('now'::text)::date,
	    loadoutdate_ date DEFAULT ('now'::text)::date,
	    starttime_ time without time zone DEFAULT ('now'::text)::time with time zone,
	    endtime_ time without time zone DEFAULT ('now'::text)::time with time zone,
	    loadintime_ time without time zone DEFAULT ('now'::text)::time with time zone,
	    loadouttime_ time without time zone DEFAULT ('now'::text)::time with time zone
	)
	INHERITS ("mGlobal");
-- --eol-- --

	ALTER TABLE events_ OWNER TO serveradmin;
-- --eol-- --

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
	    rate_ text DEFAULT 'Daily'::text,
	    discounttype_ text DEFAULT 'amount'::text,
	    total_ integer DEFAULT 0,
	    time_ double precision DEFAULT 1,
	    discount_ integer DEFAULT 0,
	    discountperc_ integer,
	    discountamount_ integer,
	    taxable_ boolean,
	    taxtotal_ integer DEFAULT 0,
	    quantity double precision,
	    ignore_price_discrepency boolean DEFAULT false
	)
	INHERITS ("mGlobal", itemdescriptors);
-- --eol-- --
	ALTER TABLE lineitems OWNER TO serveradmin;
-- --eol-- --
	COMMENT ON COLUMN lineitems.taxtotal_ IS 'stored as cents';
-- --eol-- --

-- Create the EIPL Table
	CREATE TABLE eipl (
	    fkevents_ text,
	    eipl_nmbr integer ,
	    fkdiscounts text,
	    duedate date DEFAULT now() ,
	    type_ text DEFAULT 'Estimate'::text,
	    balance_ integer,
	    grandtotal_ integer,
	    subtotal_ integer,
	    discount_ integer,
	    lidiscountsum_ integer,
	    tax_ integer DEFAULT 0,
	    totalpaid_ integer DEFAULT 0,
	    discounttype_ text DEFAULT 'amount'::text,
	    discountperc_ integer,
	    discountamount_ integer,
	    shippingmethod_ text,
	    taxtotal_ integer DEFAULT 0,
	    discounttotal_ integer DEFAULT 0
	)
	INHERITS ("mGlobal");
-- --eol-- --

	ALTER TABLE eipl OWNER TO serveradmin;
-- --eol-- --
	COMMENT ON COLUMN eipl.balance_ IS 'stored as cents';
-- --eol-- --
	COMMENT ON COLUMN eipl.grandtotal_ IS 'stored as cents';
-- --eol-- --
	COMMENT ON COLUMN eipl.subtotal_ IS 'stored in cents';
-- --eol-- --
	COMMENT ON COLUMN eipl.discount_ IS 'stored as cents';
-- --eol-- --
	COMMENT ON COLUMN eipl.lidiscountsum_ IS 'stored as cents';
-- --eol-- --
	COMMENT ON COLUMN eipl.totalpaid_ IS 'stored as cents';
-- --eol-- --
	COMMENT ON COLUMN eipl.discountamount_ IS 'stored as cents';
-- --eol-- --
	COMMENT ON COLUMN eipl.taxtotal_ IS 'stored as cents';
-- --eol-- --
	COMMENT ON COLUMN eipl.discounttotal_ IS 'stored as cents';
-- --eol-- --
	CREATE SEQUENCE "EIPL_EIPL_nmbr_seq"
	    START WITH 1
	    INCREMENT BY 1
	    NO MINVALUE
	    NO MAXVALUE
	    CACHE 1;
-- --eol-- --
	ALTER TABLE "EIPL_EIPL_nmbr_seq" OWNER TO serveradmin;
-- --eol-- --
	ALTER SEQUENCE "EIPL_EIPL_nmbr_seq" OWNED BY eipl.eipl_nmbr;
-- --eol-- --

-- Create the Table Contact Venue Data
	CREATE TABLE contact_venue_data (
	    fkcontacts text,
	    fkvenues text,
	    fkevents_ text,
	    fkeipl text,
	    primary_ boolean DEFAULT false
	)
	INHERITS ("mGlobal");
-- --eol-- --

	ALTER TABLE contact_venue_data OWNER TO serveradmin;
-- --eol-- --

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
-- --eol-- --

	ALTER TABLE contactdetails OWNER TO serveradmin;
-- --eol-- --

-- Create the Table Contacts
	CREATE TABLE contacts (
	    namefirst text,
	    namelast text,
	    jobtitle text
	)
	INHERITS ("mGlobal", contactdetails);
-- --eol-- --

	ALTER TABLE contacts OWNER TO serveradmin;
-- --eol-- --

-- Create Contracts Table
	CREATE TABLE contracts_ (
    	contract_number text 
	)
	INHERITS ("mGlobal");
-- --eol-- --

	ALTER TABLE contracts_ OWNER TO serveradmin;
-- --eol-- --

	CREATE SEQUENCE contract_number_sequence
	    START WITH 1
	    INCREMENT BY 1
	    NO MINVALUE
	    NO MAXVALUE
	    CACHE 1;
-- --eol-- --

	ALTER TABLE contract_number_sequence OWNER TO serveradmin;
-- --eol-- --

-- Create the Contract Sections Table
	CREATE TABLE contract_sections_ (
	    content_ text,
	    section_number_ integer
	)
	INHERITS ("mGlobal");
-- --eol-- --

	ALTER TABLE contract_sections_ OWNER TO serveradmin;
-- --eol-- --

-- Create the Discounts Table
	CREATE TABLE discounts_ (
	    fkeipl text,
	    department_ text,
	    type_ text DEFAULT 'amount'::text,
	    amount_ integer DEFAULT 0,
	    grandtotal_ integer,
	    subtotal_ integer,
	    discountperc_ integer,
	    discountamount_ integer
	)
	INHERITS ("mGlobal");
-- --eol-- --

	ALTER TABLE discounts_ OWNER TO serveradmin;
-- --eol-- --
	COMMENT ON COLUMN discounts_.amount_ IS 'stored as cents';
-- --eol-- --
	COMMENT ON COLUMN discounts_.grandtotal_ IS 'stored in cents';
-- --eol-- --
	COMMENT ON COLUMN discounts_.subtotal_ IS 'stored in cents';
-- --eol-- --

-- Create our Inventory Table
	CREATE TABLE inventory (
	    name_ text,
	    manufacturer text,
	    model text,
	    department text,
	    category text,
	    subcategory text,
	    description text,
	    price integer DEFAULT 0,
	    "fkItemTypes" text,
	    owner text,
	    taxable_ text DEFAULT 'False'::text
	)
	INHERITS ("mGlobal", itemdescriptors);
-- --eol-- --

	ALTER TABLE inventory OWNER TO serveradmin;
-- --eol-- --
	COMMENT ON COLUMN inventory.price IS 'stored as cents';
-- --eol-- --

-- Create our Payments Table
	CREATE TABLE payments_ (
	    date_ date DEFAULT now() ,
	    memo_ text,
	    amount_ integer DEFAULT 0,
	    paymenttype_ text,
	    fkeipl text
	)
	INHERITS ("mGlobal");
-- --eol-- --

	ALTER TABLE payments_ OWNER TO serveradmin;
-- --eol-- --
	COMMENT ON COLUMN payments_.amount_ IS 'stored in cents';
-- --eol-- --

-- Create Venues Table
	CREATE TABLE venues (
	    name text,
	    type text
	)
	INHERITS ("mGlobal", contactdetails);
-- --eol-- --

	ALTER TABLE venues OWNER TO serveradmin;
-- --eol-- --

--



SET search_path = notification_schema, pg_catalog;
-- --eol-- --

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
-- --eol-- --

	ALTER TABLE template_ OWNER TO serveradmin;
-- --eol-- --


-- #################################################
-- ############        Funtions        #############
-- #################################################



Set search_path = main_schema, pg_catalog;
-- --eol-- --

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
-- --eol-- --

	ALTER FUNCTION main_schema.login_tasks() OWNER TO serveradmin;
-- --eol-- --

-- Calculate Amount Paid
	CREATE FUNCTION calc_amountpaid(param1 text) RETURNS text
	    LANGUAGE plpgsql
	    AS $$-- calculate_amount_paid
		-- Triggerd From calculate_amount_paid_trigger in payments_
		-- Triggered on Insert, Update, and Delete of amount_
		-- Purpose is to 
			-- update the amount paid for eipl

	Declare
	    v_eiplpkid			Text;
	    v_total			Integer;

	    v_percent			Float;
	    v_numvalue			Float;
	    v_x				Float;
	    v_100			Float;

	Begin
	    -- Grab the line item pkid
		v_eiplpkid = param1;

	    -- Grab field values from payments
		Select 	Sum( amount_ ) 
		Into 	v_total 
		From	payments_
		Where	fkeipl = v_eiplpkid;

	    -- Update amountpaid field in eipl
		Update 	eipl
		Set 	totalpaid_ = v_total
		Where	pkid = v_eiplpkid;

	Return '';
	End
	$$;
	-- --eol-- --


	ALTER FUNCTION main_schema.calc_amountpaid(param1 text) OWNER TO serveradmin;
-- --eol-- --

-- Create the Trigger Function
	CREATE FUNCTION calc_amountpaid_triggfunc() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$Declare
		v_pkid 		Text;
	Begin
		
		If TG_OP = 'INSERT' Then
			v_pkid = New.fkeipl;
		ElsIf TG_OP = 'UPDATE' Then
			v_pkid = New.fkeipl;
		ElsIf TG_OP = 'DELETE' Then
			v_pkid = Old.fkeipl;
		End If;

		Perform * From calc_amountpaid( v_pkid );

		Return New;

	End;$$;
-- --eol-- --

	ALTER FUNCTION main_schema.calc_amountpaid_triggfunc() OWNER TO serveradmin;
-- --eol-- --

-- Calculate Depaartment Grand Total Function
	CREATE FUNCTION calc_dept_grandtotal(param1 text) RETURNS text
	    LANGUAGE plpgsql
	    AS $$-- calculate_department_grandtotal
		-- Triggerd From calculate_department_grandtotal_trigger in discounts_
		-- Triggered on Insert, Update of amount_, type_, subtotal_
		-- Purpose is to 
			-- update the specified department total

	Declare
	    v_deptpkid			Text;
	    v_discounttype		Text;
	    v_discount			Integer;
	    v_discountamount		Integer;
	    v_discountperc		Integer;
	    v_subtotal			Integer;
	    v_amount 			Integer;
	    v_total			Integer;

	    v_percent			Float;
	    v_numvalue			Float;
	    v_x				Float;
	    v_100			Float;
	    n1				Float;
	    n2				Float;
	    n3				Float;
	    n4				Float;

	Begin
	    -- Grab the line item pkid
	    v_deptpkid = param1;

	    -- Grab field values from discounts_
		Select 	amount_, type_, discountamount_, discountperc_, subtotal_
		Into 	v_discount, v_discounttype, v_discountamount, v_discountperc, v_subtotal 
		From	discounts_
		Where	pkid = v_deptpkid;

	    -- Calculating
	    v_100 = 100;
	    If v_discountamount > 0 Then
	    Else
		v_discountamount = 0;
	    End If;
	    If v_discountperc > 0 Then
		n1 = v_discountperc / 1000.000;
		v_percent = n1 / v_100;
		v_numvalue = v_percent * v_subtotal;
		v_discountperc = floor(v_numvalue);
	    Else
		v_discountperc = 0;
	    End If;

		v_amount = v_discountamount + v_discountperc;
		v_total = v_subtotal - v_discountamount - v_discountperc;

	    -- Updating discounts_ grandtotal
		Update 	discounts_
		Set	grandtotal_ = v_total, amount_ = v_amount
		Where	pkid = v_deptpkid;


	Return '';
	End
	$$;
-- --eol-- --

	ALTER FUNCTION main_schema.calc_dept_grandtotal(param1 text) OWNER TO serveradmin;
-- --eol-- --

-- Create the Trigger Function
	CREATE FUNCTION calc_dept_grandtotal_triggfunc() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$Declare
		v_pkid 		Text;
	Begin
		
		v_pkid = New.pkid;

		Perform * From calc_dept_grandtotal( v_pkid );

		Return New;

	End;$$;
-- --eol-- --

	ALTER FUNCTION main_schema.calc_dept_grandtotal_triggfunc() OWNER TO serveradmin;
-- --eol-- --

-- Calculate Department Totals Function
	CREATE FUNCTION calc_dept_totals(param1 text) RETURNS text
	    LANGUAGE plpgsql
	    AS $$-- calculate_department_totals
		-- Triggerd From calculate_department_totals_trigger in lineitems
		-- Triggered on Insert, Update, and Delete of total_
		-- Purpose is to 
			-- ensure that all departments are represented in the discounts_ table
			-- delete any departments no longer on eipl
			-- calculate the totals for all departments

	Declare
	    v_eiplpkid			Text;
	    v_lidepartment		Text;
	    v_rowcount			Integer;
	    v_discdepartment		Text;
	    v_departmenttotal		Integer;

	Begin
	    -- Grab the eipl pkid
	    v_eiplpkid = param1;

	    -- Loop through all line items in eipl to add unknown departments
	    For v_lidepartment In
		Select 	department
		From 	lineitems
		Where	fkeipl = v_eiplpkid
	    Loop
		-- Count the number of rows in discounts_ that have the same department name as our line item
		Select Count(*) Into v_rowcount From discounts_ Where fkeipl = v_eiplpkid And department_ = v_lidepartment;

		-- If no rows were found we will add a row for the department
		If v_rowcount = 0 And v_lidepartment <> '' Then
		    Insert Into discounts_ ( fkeipl, department_ ) Values ( v_eiplpkid, v_lidepartment );
		End If;
	    End Loop;


	    -- Loop through all the records in discounts_ to find ones that don't belong and delete them
	    For v_discdepartment In
		Select	department_
		From 	discounts_
		Where 	fkeipl = v_eiplpkid
		And 	department_ <> 'All'
	    Loop
		-- Count the number of rows in lineitems that have the same department name as our discount row
		Select Count(*) Into v_rowcount From lineitems Where fkeipl = v_eiplpkid And department = v_discdepartment;

		-- Delete the rows that don't have matches 
		If v_rowcount = 0 And v_discdepartment <> '' Then
		    Delete From discounts_ Where fkeipl = v_eiplpkid And department_ = v_discdepartment;
		End If;
	    End Loop;

	    -- Loop through the records in discounts_ to update subtotals
	    For v_discdepartment In
		Select	department_
		From 	discounts_
		Where 	fkeipl = v_eiplpkid
		And 	department_ <> 'All'
	    Loop
		-- Get Sum of all line items totals in the department
		Select 	Sum( total_ ) 
		Into 	v_departmenttotal 
		From 	lineitems 
		Where 	fkeipl = v_eiplpkid
		And 	department = v_discdepartment;

		-- Set the subtotal in discounts_ to v_departmenttotal
		Update 	discounts_
		Set	subtotal_   = v_departmenttotal
		Where	fkeipl     = v_eiplpkid
		And 	department_ = v_discdepartment;
	    End Loop;


	Return '';
	End
	$$;
	-- --eol-- --


	ALTER FUNCTION main_schema.calc_dept_totals(param1 text) OWNER TO serveradmin;
-- --eol-- --

-- Create the Trigger Function
	CREATE FUNCTION calc_dept_totals_triggfunc() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$Declare
		v_pkid 		Text;
	Begin
		
		If TG_OP = 'INSERT' Or TG_OP = 'UPDATE' Then
			v_pkid = New.fkeipl;
		Else
			v_pkid = Old.fkeipl;
		End If;

		Perform * From calc_dept_totals( v_pkid );

		Return New;

	End;$$;
	-- --eol-- --


	ALTER FUNCTION main_schema.calc_dept_totals_triggfunc() OWNER TO serveradmin;
-- --eol-- --

-- Calculate Eipl Subtotal Fuction
	CREATE FUNCTION calc_eipl_subtotal(param1 text) RETURNS text
    LANGUAGE plpgsql
    AS $$-- calculate_eipl_subtotal
	-- Triggerd From calculate_eipl_subtotal_trigg in discounts_
	-- Triggered on Insert, Update, and Delete of grandtotal_
	-- Purpose is to 
		-- update the subtotal for eipl

	Declare
	    v_eiplpkid			Text;
	    v_grandtotal		Integer;
	    v_taxtotal			Integer;

	Begin
	    -- Grab the line item pkid
		v_eiplpkid = param1;

	    -- Grab field values from eipl
		Select 	Sum( grandtotal_ )
		Into 	v_grandtotal
		From	discounts_
		Where	fkeipl = v_eiplpkid;

		Select 	Sum( taxtotal_ )
		Into 	v_taxtotal
		From	lineitems
		Where	fkeipl = v_eiplpkid;

	    -- Updating eipl fields
		Update	eipl
		Set	subtotal_ = v_grandtotal, taxtotal_ = v_taxtotal
		Where	pkid = v_eiplpkid;

	Return '';
	End
	$$;
	-- --eol-- --


	ALTER FUNCTION main_schema.calc_eipl_subtotal(param1 text) OWNER TO serveradmin;
-- --eol-- --

-- Create the Trigger Function
	CREATE FUNCTION calc_eipl_subtotal_triggfunc() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$Declare
		v_pkid 		Text;
	Begin
		
		If TG_OP = 'INSERT' Then
			v_pkid = New.fkeipl;
		ElsIf TG_OP = 'UPDATE' Then
			v_pkid = New.fkeipl;
		ElsIf TG_OP = 'DELETE' Then
			v_pkid = Old.fkeipl;
		End If;

		Perform * From calc_eipl_subtotal( v_pkid );

		Return New;

	End;$$;
-- --eol-- --

	ALTER FUNCTION main_schema.calc_eipl_subtotal_triggfunc() OWNER TO serveradmin;
-- --eol-- --

-- Calculate the EIPL Totals Function
	CREATE FUNCTION calc_eipl_totals(param1 text) RETURNS text
	    LANGUAGE plpgsql
	    AS $$-- calculate_eipl_totals
		-- Triggerd From calculate_eipl_totals in eipl
		-- Triggered on Insert, Update, and Delete of subtotal_, tax_, totalpaid_
		-- Purpose is to 
			-- update the grandtotal_ and balancedue_ for eipl

	-- double percent field status
		-- working ***
		-- trigger not updated

	Declare
	    v_eiplpkid			Text;
	    v_subtotal			Integer;
	    v_taxrate			Integer;
	    v_taxtotal			Integer;
	    v_totalpaid			Integer;
	    v_grandtotal		Integer;
	    v_balancedue		Integer;
	    v_discountperc		Integer;
	    v_discountamount		Integer;
	    v_discounttype		Text;
	    v_amount			Integer;

	    v_percent			Float;
	    v_numvalue			Float;
	    v_x				Float;
	    v_100			Float;
	    v_thistest			Float;
	    n1				Float;

	Begin
	    -- Grab the line item pkid
		v_eiplpkid = param1;

	    -- Grab field values from eipl
		Select 	subtotal_, tax_, totalpaid_, discountperc_, discountamount_, discounttype_
		Into 	v_subtotal, v_taxrate, v_totalpaid, v_discountperc, v_discountamount, v_discounttype
		From	eipl
		Where	pkid = v_eiplpkid;

	    -- discount type things
		v_100 = 100;
		If v_discountamount > 0 Then
		Else
			v_discountamount = 0;
		End If;
		If v_discountperc > 0 Then
			n1 = v_discountperc / 1000.000;
			v_percent = n1 / v_100;
			v_numvalue = v_percent * v_subtotal;
			v_discountperc = floor(v_numvalue);
		Else
			v_discountperc = 0;
		End If;


	    -- Calculating
	       v_amount = v_discountamount + v_discountperc ;
		v_x = v_subtotal - v_discountamount - v_discountperc;
	    
	    -- Calculating
		v_grandtotal = v_x;

	    -- Balance Due
		v_balancedue = v_grandtotal - v_totalpaid;

	    -- Updating eipl fields
		Update	eipl
		Set	grandtotal_ = v_grandtotal, balance_ = v_balancedue, discount_ = v_amount
		Where	pkid = v_eiplpkid;

	Return v_grandtotal;
	End
	$$;
	-- --eol-- --

-- Create the Trigger Function
	ALTER FUNCTION main_schema.calc_eipl_totals(param1 text) OWNER TO serveradmin;
-- --eol-- --

	CREATE FUNCTION calc_eipl_totals_triggfunc() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$Declare
		v_pkid 		Text;
	Begin
		
		v_pkid = New.pkid;

		Perform * From calc_eipl_totals( v_pkid );

		Return New;

	End;$$;
	-- --eol-- --


	ALTER FUNCTION main_schema.calc_eipl_totals_triggfunc() OWNER TO serveradmin;
-- --eol-- --

-- Calculate Line Itesm Total Function
	CREATE FUNCTION calc_lineitem_total(param1 text) RETURNS text
	    LANGUAGE plpgsql
	    AS $$-- calculate_lineitem_totals
		-- Triggerd From calculate_lineitems_totals_trigger in lineitems
		-- Triggered on Insert, Update, and Delete of price, quantity_, discounttype_, time_, discount_
		-- Purpose is to 
			-- update the specified line item total

	Declare
	    v_lipkid			Text;
	    v_price			Integer;
	    v_quantity			Integer;
	    v_discounttype		Text;
	    v_time			Double Precision;
	    v_discount			Integer;
	    v_discountamount		Integer;
	    v_discountperc		Integer;
	    v_total			Integer;
	    v_taxtotal			Integer;
	    v_taxable			Boolean;
	    v_taxrate			Integer;
	    v_eiplpkid			Text;

	    v_percent			Float;
	    v_numvalue			Float;
	    v_x				Float;
	    v_100			Float;
	    v_floattotal		Float;
	    n1				Float;

	Begin
	    -- Grab the line item pkid
	    v_lipkid = param1;

	    -- Grabbing all the info from field
	    Select	price, quantity_, discounttype_, time_, discountperc_, discountamount_, taxable_, fkeipl
	    Into 	v_price, v_quantity, v_discounttype, v_time, v_discountperc, v_discountamount, v_taxable, v_eiplpkid
	    From 	lineitems
	    Where	pkid = v_lipkid;

	    -- Get the Tax rate from the eipl
	    Select	tax_
	    Into	v_taxrate
	    From	eipl
	    Where	pkid = v_eiplpkid;

	    -- Calculating
	    v_x = v_price * v_quantity;
	    v_x = v_x * v_time;
	    
	    v_100 = 100;
	    v_total = v_x;
	    If v_discountamount > 0 Then
	    Else
		v_discountamount = 0;
	    End If;
	    If v_discountperc > 0 Then
		n1 = v_discountperc / 1000.000;
		v_percent = n1 / v_100;
		v_numvalue = v_percent * v_total;
		v_discountperc = floor(v_numvalue);
	    Else
		v_discountperc = 0;
	    End If;


	    v_x = v_x - v_discountamount - v_discountperc;
	    If v_taxable = True Then
		v_100 = 1000;
		v_percent = v_taxrate / v_100;
		v_taxtotal = v_x * v_percent;
		v_x = v_taxtotal + v_x;
	    End If;

	    v_total = v_x;

	    -- Update the record
	    Update 	lineitems 
	    Set 	total_ = v_total, taxtotal_ = v_taxtotal
	    Where	pkid = v_lipkid;



	Return '';
	End
	$$;
-- --eol-- --

	ALTER FUNCTION main_schema.calc_lineitem_total(param1 text) OWNER TO serveradmin;
-- --eol-- --

-- Calculate Line Item Total Trigger Function
	CREATE FUNCTION calc_lineitem_total_triggfunc() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$Declare
		v_pkid 		Text;
	Begin
		
		v_pkid = New.pkid;

		Perform * From calc_lineitem_total( v_pkid );

		Return New;

	End;$$;
-- --eol-- --

	ALTER FUNCTION main_schema.calc_lineitem_total_triggfunc() OWNER TO serveradmin;
-- --eol-- --

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
-- --eol-- --

	ALTER FUNCTION main_schema.create_contract_number() OWNER TO serveradmin;
-- --eol-- --


-- Contact Venue Data Update Trigger Funciton
	CREATE FUNCTION cvd_update_function() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$
	DECLARE
	    v_test TEXT;

	BEGIN

	    If New.fkeipl = Null Then
		Return new;
	    End If;

	    If New.fkcontacts NotNull Then  --Is linked to a contact
		Delete From contact_venue_data Where New.pkid <> pkid And fkcontacts NotNull And New.fkeipl = fkeipl;
		
	    ElsIf New.fkvenues NotNull Then  --Is linked to a venue
		Delete From contact_venue_data Where New.pkid <> pkid And fkvenues NotNull And New.fkeipl = fkeipl;

	    End If;

	    Return New;
	END;
	   $$;
-- --eol-- --


	ALTER FUNCTION main_schema.cvd_update_function() OWNER TO serveradmin;
-- --eol-- --


-- Delete Record Function
	CREATE FUNCTION deleterecord(p_options text, p_pkid text DEFAULT 'none'::text, p_table text DEFAULT 'none'::text) RETURNS text
	    LANGUAGE plpgsql
	    AS $_$
	Declare
	    -- Input Variables
	    v_options		Text;
	    v_pkid		Text;
	    v_table 		Text;

	    v_fkname   		Text;
	    v_sql		Text;
	    v_tablename 	Text;

	    v_return		Text;

	Begin
	    -- Saving parameters to input variables
	    v_options = p_options;
	    v_pkid    = p_pkid;
	    v_table   = p_table;

	    v_fkname  = 'fk' || v_table;


	    -- Generate our sql to delete the parent record
	    v_sql = $$Delete From $$ || v_table || $$ Where pkid = '$$ || v_pkid || $$'$$ ;

	    Execute v_sql;


	    -- Delete Recursively 
	    If v_options = '-r' Then

		-- Loop through all tables in public SCHEMA that have a fktable column
		For v_tablename In
		    Select table_name
		    From   information_schema.columns
		    Where  column_name = v_fkname
		    And    table_schema = 'public'
		Loop

		    -- Preparing sql to delete all the children of the parent from this table
		    v_sql = $$Delete From $$ || v_tablename || $$ Where $$ || v_fkname || $$ = '$$ || v_pkid || $$'$$;

		    -- Executing
		    Execute v_sql;

		    v_return = 'Deleted';

		End Loop;

	    End if;


	Return v_return;
	End;$_$;
-- --eol-- --

	ALTER FUNCTION main_schema.deleterecord(p_options text, p_pkid text, p_table text) OWNER TO serveradmin;
-- --eol-- --

-- Inventory to Line Item Function
	CREATE FUNCTION inventory_to_lineitem(inventoryid text DEFAULT 0, eiplid text DEFAULT 0) RETURNS text
	    LANGUAGE plpgsql
	    AS $$DECLARE
	    result TEXT;
	BEGIN
	    INSERT INTO lineitems ( name_, manufacturer, model, department, category, subcategory, description, price, fkeipl, fkinventory )
	    SELECT name_, manufacturer, model, department, category, subcategory, description, price, eiplid, pkid
	    FROM inventory
	    WHERE pkid = inventoryid
	    RETURNING pkid INTO result;
	  RETURN result;
	END;$$;
	-- --eol-- --


	ALTER FUNCTION main_schema.inventory_to_lineitem(inventoryid text, eiplid text) OWNER TO serveradmin;
-- --eol-- --

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
-- --eol-- --

	ALTER FUNCTION main_schema.lineitem_to_inventory(lineitem_id text) OWNER TO serveradmin;
-- --eol-- --

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
-- --eol-- --

	ALTER FUNCTION main_schema.mknexteipl(p_pkid text, p_mode integer) OWNER TO serveradmin;
-- --eol-- --

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
-- --eol-- --

	ALTER FUNCTION main_schema.new_eipl_function() OWNER TO serveradmin;
-- --eol-- --

-- Create New Payment Function
	CREATE FUNCTION newpayment(p_pkid text DEFAULT 'none'::text) RETURNS text
	    LANGUAGE plpgsql
	    AS $$Declare
	    v_return 		Text;

	Begin

	    Insert Into payments_ (fkeipl) Values(p_pkid) Returning pkid Into v_return;

	    Return v_return;

	End;$$;
-- --eol-- --

	ALTER FUNCTION main_schema.newpayment(p_pkid text) OWNER TO serveradmin;
-- --eol-- --

-- Create the Price Discrepency Checker Function
	CREATE FUNCTION price_discrepency_checker(param1 lineitems) RETURNS text
	    LANGUAGE plpgsql
	    AS $_$
	-- check_price_discrepencies

	-- This functions purpose is to:
		-- compare prices of the same line item in the same event in different eipls
		-- If there is a discrepency then we alert any users in that event

	Declare
		eipl_pkid				text;
		event_pkid				text;
		eipl_pkid_array				text[];
		hmmm_pkid				text;
		n1 					integer;
		s1					text;
		n2					integer;
		s2					text;
		n3					integer;
		s3					text;
		line_item_record			record;
		tablename_				text;
		sql_string				text;
		count_					integer;
		price_discrepency			boolean;	
		lineitem_pkids_				text;	
		thisfingpkid				text;

	Begin

		hmmm_pkid = param1.pkid ;
		lineitem_pkids_ = hmmm_pkid;

		Select fkeipl Into eipl_pkid From lineitems Where pkid = hmmm_pkid ;

		-- Begin by aquiring the event pkid
		Select fkevents_ Into event_pkid From eipl Where pkid = eipl_pkid;

		n1 = 0;
		n2 = 0;
		n3 = 0;

		For line_item_record In 
		     Select * 
		     From lineitems, eipl
		     Where
			event_pkid = eipl.fkevents_
			And
			eipl.pkid = lineitems.fkeipl
			And 
			(
				Case param1.fkinventory
					When '' Then
						lineitems.name_ = param1.name_
						And
						lineitems.department = param1.department
					Else
						lineitems.fkinventory = param1.fkinventory
				End
			)
		Loop
	              If param1.price = line_item_record.price Then
	              -- do nothing things are as they should be
			n1 = n1 + 1;
	              Else

			-- add the pkid to our variable
			lineitem_pkids_ = lineitem_pkids_ || ' ';
			lineitem_pkids_ = lineitem_pkids_ || line_item_record.pkid;
			
			price_discrepency = True;
			n2 = n2 + 1;
			
	              End If;

	              n3 = n3 + 1;
	              count_ = count_ + 1;

		End Loop;


		


		If price_discrepency = True Then

			-- notify user that the prices are different and need to be changed
			tablename_ = 'notification.' || current_user || '_rap';
			sql_string = $$Insert Into $$ || tablename_ || $$ ( lineitem_name, notification_type, lineitem_pkids ) Values ( '$$ || param1.name_ || $$', 'price_discrepency', '$$ || lineitem_pkids_ || $$' )$$;
			Execute( sql_string );
			Perform pg_notify( current_user, 'payload' );

		End If;

	s1 = to_char( n1, '999' );
	s2 = to_char( n2, '999' );
	s3 = to_char( n3, '999' );


	return 'sm' || s1 || ', df' || s2 || ', t' || s3;

	End$_$;
	-- --eol-- --

	ALTER FUNCTION main_schema.price_discrepency_checker(param1 lineitems) OWNER TO serveradmin;
-- --eol-- --


-- Create the Trigger function
	CREATE FUNCTION price_discrepency_checker_triggfunc() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$Declare
	Begin

	If New.ignore_price_discrepency = False Then
		Perform * from price_discrepency_checker(new);
	End If;

	return new;
	End$$;
-- --eol-- --

	ALTER FUNCTION main_schema.price_discrepency_checker_triggfunc() OWNER TO serveradmin;
-- --eol-- --


-- Create the Function to update the primary venues and contacts
	CREATE FUNCTION primary_update_function() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $_$DECLARE
	    v_pkid TEXT;
	    v_fk_eiplorevent TEXT;
	    v_eipleventvalue TEXT;
	    v_fk_contactorvenue TEXT;
	BEGIN
	    IF NEW.primary_ = false THEN
		RETURN old;
	    END IF;
	    -- Checking wether we are dealing with a contact or venue
	    IF NEW.fkcontacts NOTNULL THEN 
		v_fk_contactorvenue = 'fkcontacts';
	    ELSIf NEW.fkvenues NOTNULL THEN 
		v_fk_contactorvenue = 'fkvenues' ;
	    END IF;
	    -- Checking whether we ar dealing with an eipl or an event
	    IF NEW.fkeipl NOTNULL THEN
	        v_fk_eiplorevent = 'fkeipl';
	    ELSIF NEW.fkevents_ NOTNULL THEN
	        v_fk_eiplorevent = 'fkevents_';
	    END IF;

	    -- Some variables
	    --v_fk_contactorvenue = 'fkcontacts';
	    --v_fk_eiplorevent = 'fkevents_';
	    v_pkid = NEW.pkid;
	    IF v_fk_eiplorevent = 'fkevents_' THEN
		v_eipleventvalue = NEW.fkevents_;
	    ELSIF v_fk_eiplorevent = 'fkeipl' THEN
		v_eipleventvalue = NEW.fkeipl;
	    END IF;
	    
	    EXECUTE(FORMAT($f$
		UPDATE contact_venue_data
		SET primary_ = false
		WHERE contact_venue_data.pkid <> %L
		AND %s NOTNULL
		AND %s = %L; 
		$f$, v_pkid, v_fk_contactorvenue, v_fk_eiplorevent, v_eipleventvalue ));

	RETURN old;
	END;
	$_$;
-- --eol-- --

	ALTER FUNCTION main_schema.primary_update_function() OWNER TO serveradmin;
-- --eol-- --


-- Sync the Event Dates to the Start Date Function
	CREATE FUNCTION synceventdatestostart_func(param1 events_) RETURNS text
	    LANGUAGE plpgsql
	    AS $_$Declare
		event_pkid_			Text;
		tablename_			Text;
		sql_string			Text;

	Begin

		-- Grab the event pkid
		event_pkid_ = param1.pkid;

		-- Update the other dates
		Update events_ Set enddate_ = startdate_, loadindate_ = startdate_, loadoutdate_ = startdate_ Where pkid = event_pkid_;

		-- notify user that the prices are different and need to be changed
		tablename_ = 'notification.' || current_user || '_rap';
		sql_string = $$Insert Into $$ || tablename_ || $$ ( notification_type, event_pkid_ ) Values ( 'eventStartDateChange', '$$ || event_pkid_ || $$' )$$;
		Execute( sql_string );
		Perform pg_notify( current_user, 'payload' );

	return ' ';
	End;$_$;
-- --eol-- --

	ALTER FUNCTION main_schema.synceventdatestostart_func(param1 events_) OWNER TO serveradmin;
-- --eol-- --

-- Create the Trigger Function
	CREATE FUNCTION "syncEventDatesToStart_triggFunc"() RETURNS trigger
	    LANGUAGE plpgsql
	    AS $$Declare
	Begin
	Perform * from syncEventDatesToStart_func(new);
	Return new;
	End;$$;
-- --eol-- --

	ALTER FUNCTION main_schema."syncEventDatesToStart_triggFunc"() OWNER TO serveradmin;






































































