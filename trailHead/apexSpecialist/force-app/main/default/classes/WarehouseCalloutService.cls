public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public static List<Object> results = new List<Object>();

    @future(callout = true)
    public static void runWarehouseEquipmentSync() {
        List<String> res = new List<String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug(response.getStatusCode());

        if(response.getStatusCode() == 200) {
            results = (List<Object>)JSON.deserializeUntyped(response.getBody());
        }

        Set<String> queryIds = new Set<String>();
        for (Object result : results) {
            Map<String, Object> e = (Map<String, Object>)result;
            queryIds.add((String)e.get('sku'));
        }

        List<Product2> records = new List<Product2>();
        Map<String, Product2> recordMap = getEquipment(queryIds);
        for (Object result : results) {
            Map<String, Object> e = (Map<String, Object>)result;
            System.debug(e);

            Product2 record = recordMap.get((String)e.get('sku'));
            if (record == null) record = new Product2();
            record.Name = String.valueOf(e.get('name'));
            record.Replacement_Part__c = (boolean)e.get('replacement');
            record.Cost__c = toNumber(String.valueOf(e.get('cost')));
            record.Current_Inventory__c = toNumber(String.valueOf(e.get('quantity')));
            record.Lifespan_Months__c = toNumber(String.valueOf(e.get('lifespan')));
            record.Maintenance_Cycle__c = toNumber(String.valueOf(e.get('maintenanceperiod')));
            record.Warehouse_SKU__c = String.valueOf(e.get('sku'));
            record.ProductCode = String.valueOf(e.get('_id'));
            records.add(record);
        }
        upsert records;
    }

    public static Map<String, Product2> getEquipment(Set<String> ids) {
        Map<String, Product2> res = new Map<String, Product2>();
        List<Product2> records = [
            SELECT Name, Replacement_Part__c, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c, Warehouse_SKU__c, ProductCode
            FROM Product2
            WHERE Warehouse_SKU__c IN :ids
        ];
        for (Product2 record : records) {
            res.put(record.Warehouse_SKU__c, record);
        }
        return res;
    }

    public static Integer toNumber(String value) {
        return String.isBlank(value)? null : Integer.valueOf(value);
    }

    public static void execute(QueueableContext context){
        runWarehouseEquipmentSync();
    }
}