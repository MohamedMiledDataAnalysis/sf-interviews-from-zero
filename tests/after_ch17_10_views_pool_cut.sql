USE ashcombe;
SET NOCOUNT ON;
DECLARE @t TABLE (month_end DATE, loans INT, distinct_ids INT, balance DECIMAL(18,2), arrears_3plus DECIMAL(18,2));
INSERT INTO @t EXEC dbo.usp_control_totals @month_end = '2026-06-30';
INSERT INTO @t EXEC dbo.usp_control_totals @month_end = '2026-05-31';
IF NOT EXISTS (SELECT 1 FROM @t WHERE month_end = '2026-06-30' AND loans = 1200 AND distinct_ids = 1200
                 AND balance = 240000000 AND arrears_3plus = 4648983)
OR NOT EXISTS (SELECT 1 FROM @t WHERE month_end = '2026-05-31' AND loans = 1211 AND balance = 242582325)
   THROW 50000, 'Ch17 10.5: procedure control totals (June and May)', 1;
IF (SELECT loans FROM dbo.v_pool_summary) <> 1200 OR (SELECT balance FROM dbo.v_pool_summary) <> 240000000
OR (SELECT ROUND(wa_rate, 5) FROM dbo.v_pool_summary) <> 0.05444
OR (SELECT ROUND(wa_iltv, 5) FROM dbo.v_pool_summary) <> 0.60333
   THROW 50000, 'Ch17 10.1: view v_pool_summary', 1;
PRINT 'ALL CHECKS PASSED';
