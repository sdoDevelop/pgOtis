
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
-- --eol-- --


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


