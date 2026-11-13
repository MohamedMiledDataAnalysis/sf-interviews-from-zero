USE ashcombe;
SET NOCOUNT ON;
IF (SELECT COUNT(*) FROM dbo.loan) <> 1200 OR (SELECT COUNT(DISTINCT loan_id) FROM dbo.loan) <> 1200
   THROW 50000, 'Ch17 8.3: 1,200 unique loans', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.loan WHERE loan_id = 'ASH100888' AND origination_date = '2020-04-30')
   THROW 50000, 'Ch17 8.3: the 2020 loan is relabelled ASH100888', 1;
IF (SELECT COUNT(*) FROM dbo.loan_month) <> 1200
   THROW 50000, 'Ch17 8.3: every servicer balance finds its loan (1,200 rows)', 1;
IF OBJECT_ID('dbo.pk_loan_tape') IS NOT NULL
   THROW 50000, 'Ch17 8.1: the primary key must not have been created', 1;
IF EXISTS (SELECT 1 FROM dbo.loan_month WHERE loan_id = 'ASH999999')
   THROW 50000, 'Ch17 8.4: the foreign key must have refused ASH999999', 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_loan_tape_region' AND object_id = OBJECT_ID('dbo.loan_tape'))
   THROW 50000, 'Ch17 8.5: index ix_loan_tape_region', 1;
PRINT 'ALL CHECKS PASSED';
