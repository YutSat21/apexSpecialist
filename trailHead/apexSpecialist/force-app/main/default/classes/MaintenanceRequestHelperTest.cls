@isTest
private class MaintenanceRequestHelperTest {
    // implement scheduled code here
    @isTest
    static void testMaintenanceRequest(){
        createTestData();
        Case req = getRequest();
        req.type = 'Repair';
        req.Status = 'Closed';

        Test.startTest();
        upsert req;
        Test.stopTest();

        Case newReq = getNewRequest();
        System.assertEquals(newReq.Vehicle__c, req.Vehicle__c);
        System.assertEquals(newReq.ProductId, req.ProductId);
    }

    static void createTestData() {
        // account
        Account acc = new Account();
        acc.Name = '株式会社テスト';
        insert acc;

        // contact
        Contact con = new Contact();
        con.LastName = 'テスト';
        con.FirstName = '太郎';
        insert con;

        // Product2(Equipment)
        List<Product2> proList = new List<Product2>();
        Product2 pro1 = new Product2();
        pro1.Name = 'テストEquipment1';
        pro1.Maintenance_Cycle__c = 20;
        pro1.Replacement_Part__c = true;
        proList.add(pro1);
        Product2 pro2 = new Product2();
        pro2.Name = 'テストEquipment2';
        pro2.Maintenance_Cycle__c = 10;
        pro2.Replacement_Part__c = true;
        proList.add(pro2);
        insert proList;

        // Veicle
        Vehicle__c v = new Vehicle__c();
        v.Name = 'テスト自動車';
        insert v;

        // case
        Case req = new Case();
        req.AccountId = acc.Id;
        req.ContactId = con.Id;
        req.Vehicle__c = v.Id;
        insert req;

        // Equipment_Maintenance_Item__c
        List<Equipment_Maintenance_Item__c> itemList = new List<Equipment_Maintenance_Item__c>();
        Equipment_Maintenance_Item__c item1 = new Equipment_Maintenance_Item__c();
        item1.Equipment__c = pro1.Id;
        item1.Maintenance_Request__c = req.Id;
        itemList.add(item1);
        Equipment_Maintenance_Item__c item2 = new Equipment_Maintenance_Item__c();
        item2.Equipment__c = pro2.Id;
        item2.Maintenance_Request__c = req.Id;
        itemList.add(item2);
        insert itemList;
    }

    private static Case getRequest() {
        return [SELECT Id, Vehicle__c, ProductId FROM Case LIMIT 1];
    }

    private static Case getNewRequest() {
        return [SELECT Id, Vehicle__c, ProductId FROM Case WHERE Type = 'Routine Maintenance' AND Status = 'New' LIMIT 1];
    }
 }