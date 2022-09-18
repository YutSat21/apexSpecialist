@IsTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here
    @isTest
    static void WarehouseEquipmentSysnc() {
        createTestData();
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        System.enqueueJob(New WarehouseCalloutService());
        Test.stopTest();
        System.assertEquals(1,  [SELECT count() FROM Product2]);
    }

    static void createTestData() {
        Product2 p = new Product2();
        p.Replacement_Part__c = true;
        p.Warehouse_SKU__c = '100003';
        p.name = 'Generator 1000 kW';

        insert p;
    }
}