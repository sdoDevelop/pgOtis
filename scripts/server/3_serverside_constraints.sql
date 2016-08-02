
-- ##################################
-- ###### Create Otis Database ######
-- ##################################
-- ########### Post-Data  ###########


Set search_path = main_schema, pg_catalog;

ALTER TABLE ONLY contracts_
    ADD CONSTRAINT contracts_pkid PRIMARY KEY (pkid);

ALTER TABLE ONLY contactdetails
    ADD CONSTRAINT "pkID_ContactDetails" PRIMARY KEY (pkid);

ALTER TABLE ONLY contacts
    ADD CONSTRAINT "pkID_Contacts" PRIMARY KEY (pkid);

ALTER TABLE ONLY discounts_
    ADD CONSTRAINT "pkID_Discounts" PRIMARY KEY (pkid);

ALTER TABLE ONLY eipl
    ADD CONSTRAINT "pkID_EIPL" PRIMARY KEY (pkid);

ALTER TABLE ONLY events_
    ADD CONSTRAINT "pkID_Events" PRIMARY KEY (pkid);

ALTER TABLE ONLY "mGlobal"
    ADD CONSTRAINT "pkID_Global" PRIMARY KEY (pkid);

ALTER TABLE ONLY inventory
    ADD CONSTRAINT "pkID_Inventory" PRIMARY KEY (pkid);

ALTER TABLE ONLY lineitems
    ADD CONSTRAINT "pkID_LineItems" PRIMARY KEY (pkid);

ALTER TABLE ONLY payments_
    ADD CONSTRAINT "pkID_Payments" PRIMARY KEY (pkid);

ALTER TABLE ONLY venues
    ADD CONSTRAINT "pkID_Venues" PRIMARY KEY (pkid);

ALTER TABLE ONLY contact_venue_data
    ADD CONSTRAINT "pkID_contact_venue_data" PRIMARY KEY (pkid);

ALTER TABLE ONLY contract_sections_
    ADD CONSTRAINT pk_contract_sections PRIMARY KEY (pkid);

ALTER TABLE ONLY itemdescriptors
    ADD CONSTRAINT pkid_itemdescriptors PRIMARY KEY (pkid);


Set search_path = client_server_schema, pg_catalog;

ALTER TABLE ONLY client_server_scripts
    ADD CONSTRAINT order_number_ PRIMARY KEY (pkid);



