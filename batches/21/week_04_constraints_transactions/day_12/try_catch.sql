DO $$
BEGIN
    -- risky code
EXCEPTION
    WHEN some_error THEN
        -- graceful handling
END $$;


Handle Division by Zero


DO $$
BEGIN
    SELECT 'Average: %',100/0;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Cannot divide by Zero - math just broke!';
END $$;

DO $$
BEGIN
    INSERT INTO sales.orders VALUES(160000,51000,1,CURRENT_DATE,'Delivered',30000);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'You cant have same order_id for two different orders';
END $$;


set search_path to day_11;

DO $$
BEGIN

    BEGIN
        insert into retail_orders VALUES (5,'Ali',900.00);
        SAVEPOINT after_order;
        INSERT INTO retail_payments VALUES (101,5,'UPI',900.00);
        COMMIT;
EXCEPTION
    WHEN others THEN
        ROLLBACK;
        RAISE NOTICE 'UPI Payment Failed ! Order Roll Back Automatically';
    END;
END $$;
