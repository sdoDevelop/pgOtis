
-- ##################################
-- ###### Create Otis Database ######
-- ##################################
-- ########### Post-Data  ###########


Set search_path = main_schema, pg_catalog;
-- --eol-- --
ALTER TABLE ONLY contracts_
    ADD CONSTRAINT contracts_pkid PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY contactdetails
    ADD CONSTRAINT "pkID_ContactDetails" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY contacts
    ADD CONSTRAINT "pkID_Contacts" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY discounts_
    ADD CONSTRAINT "pkID_Discounts" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY eipl
    ADD CONSTRAINT "pkID_EIPL" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY events_
    ADD CONSTRAINT "pkID_Events" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY "mGlobal"
    ADD CONSTRAINT "pkID_Global" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY inventory
    ADD CONSTRAINT "pkID_Inventory" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY lineitems
    ADD CONSTRAINT "pkID_LineItems" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY payments_
    ADD CONSTRAINT "pkID_Payments" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY venues
    ADD CONSTRAINT "pkID_Venues" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY contact_venue_data
    ADD CONSTRAINT "pkID_contact_venue_data" PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY contract_sections_
    ADD CONSTRAINT pk_contract_sections PRIMARY KEY (pkid);
-- --eol-- --
ALTER TABLE ONLY itemdescriptors
    ADD CONSTRAINT pkid_itemdescriptors PRIMARY KEY (pkid);



