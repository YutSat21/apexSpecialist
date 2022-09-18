@isTest
private class WarehouseSyncScheduleTest {
    // implement scheduled code here
    @isTest
    static void scheduleTest() {
        test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String CRON_EXP = '0 0 1 ? * 1,2,3,4,5,6,7';
        test.startTest();
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new WarehouseSyncSchedule());
        
        test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
    }
}