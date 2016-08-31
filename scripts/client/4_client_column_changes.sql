

-- ##################################
-- ###### Create Otis Database ######
-- ##################################
-- ########### Post-Data  ###########
--			Column Changes


Set search_path = main_schema, pg_catalog;
-- --eol-- --
ALTER TABLE ONLY contracts_ 
	ALTER COLUMN contract_number 
	SET DEFAULT main_schema.create_contract_number();
-- --eol-- --

-- Work on Triggers
CREATE TRIGGER calc_amountpaid_trigg AFTER INSERT OR DELETE OR UPDATE OF amount_ ON payments_ FOR EACH ROW EXECUTE PROCEDURE calc_amountpaid_triggfunc();
-- --eol-- --
CREATE TRIGGER calc_dept_grandtotal_trigg AFTER INSERT OR UPDATE OF subtotal_, discountperc_, discountamount_ ON discounts_ FOR EACH ROW EXECUTE PROCEDURE calc_dept_grandtotal_triggfunc();
-- --eol-- --
CREATE TRIGGER calc_dept_totals_trigg AFTER INSERT OR DELETE OR UPDATE OF total_ ON lineitems FOR EACH ROW EXECUTE PROCEDURE calc_dept_totals_triggfunc();
-- --eol-- --
CREATE TRIGGER calc_eipl_subtotal_trigg AFTER INSERT OR DELETE OR UPDATE OF grandtotal_ ON discounts_ FOR EACH ROW EXECUTE PROCEDURE calc_eipl_subtotal_triggfunc();
-- --eol-- --
CREATE TRIGGER calc_eipl_totals_trigg AFTER INSERT OR UPDATE OF totalpaid_, tax_, discountperc_, discountamount_, subtotal_ ON eipl FOR EACH ROW EXECUTE PROCEDURE calc_eipl_totals_triggfunc();
-- --eol-- --
CREATE TRIGGER calc_lineitem_total_trigg AFTER INSERT OR UPDATE OF discountperc_, discountamount_, time_, price, quantity_, rate_ ON lineitems FOR EACH ROW EXECUTE PROCEDURE calc_lineitem_total_triggfunc();
-- --eol-- --
CREATE TRIGGER fkeipl_update_trigger AFTER UPDATE OF fkeipl ON contact_venue_data FOR EACH ROW EXECUTE PROCEDURE cvd_update_function();
-- --eol-- --
CREATE TRIGGER new_eipl_trigger AFTER INSERT ON eipl FOR EACH ROW EXECUTE PROCEDURE new_eipl_function();
-- --eol-- --
CREATE TRIGGER price_discrepency_checker_triggfunc AFTER INSERT OR UPDATE OF price ON lineitems FOR EACH ROW EXECUTE PROCEDURE price_discrepency_checker_triggfunc();
-- --eol-- --
CREATE TRIGGER primary_update_trigger AFTER UPDATE OF primary_ ON contact_venue_data FOR EACH ROW EXECUTE PROCEDURE primary_update_function();
-- --eol-- --
CREATE TRIGGER start_date_changed AFTER UPDATE OF startdate_ ON events_ FOR EACH ROW EXECUTE PROCEDURE "syncEventDatesToStart_triggFunc"();

