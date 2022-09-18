public with sharing class MaintenanceRequestHelper {

    public static void updateWorkOrders(List<case> requests) {
        Map<String, Case> targetRequestMap = new Map<String, Case>(); // key:caseId
        for (Case c : requests) {
            if ((c.type.equals('Repair') || c.type.equals('Routine Maintenance')) &&
               		c.Status.equals('Closed')) {
                        targetRequestMap.put(c.Id, c);
            }
        }

        // 対象requestごとの最小のCycleを取得
        Map<String, Integer> minCycleMap = getMinCycleMap(targetRequestMap.keySet()); // key: requestId

        // 新規requestの作成
        Map<String, Case> oldNewCaseMap = insertNewReq(targetRequestMap.values(), minCycleMap);

        // 新規Itemの作成
        insertNewItem(oldNewCaseMap);
    }    

    /**
     * 新規Requestの作成
     */
    private static Map<String, Case> insertNewReq(
        List<Case> requests, 
        Map<String, Integer> minCycleMap
    ) {
        Map<String, Case> res = new  Map<String, Case>(); // key: oldRequestId, value: newRequest
        List<Case> newReqs = new List<Case>();
        for (Case request : requests) {
            Case newReq = new Case();
            System.debug(request);
            newReq = request.clone();
            newReq.Type = 'Routine Maintenance';
            newReq.Subject = 'new Routine Maintenace Request';
            newReq.Date_Reported__c = system.today();
            newReq.Date_Due__c = system.today().addDays(minCycleMap.get(request.Id));
            newReq.Status = 'New';
            newReqs.add(newReq);
            res.put(request.Id, newReq);
        }
        insert newReqs;
        return res;
    }

    /**
     * 新規Requestに紐づくitemの作成
     */
    private static void insertNewItem(Map<String, Case> oldNewCaseMap) {
        Map<String, Equipment_Maintenance_Item__c> res = new Map<String, Equipment_Maintenance_Item__c>();
        List<Equipment_Maintenance_Item__c> items = [
            SELECT Equipment__c, Maintenance_Request__r.Id
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :oldNewCaseMap.keySet()
        ];
        List<Equipment_Maintenance_Item__c> newItemList = new List<Equipment_Maintenance_Item__c>();
        for (Equipment_Maintenance_Item__c e : items) {
            Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();
            newItem.Equipment__c = e.Equipment__c;
            newItem.Maintenance_Request__c = oldNewCaseMap.get(e.Maintenance_Request__r.Id)?.Id;
            newItemList.add(newItem);
        }
        insert newItemList;
    }

    // 関連データの取得(Equipment)
    private static Map<String, Integer> getMinCycleMap(Set<String> targetRequestIds) {
        Map<String, Integer> res = new Map<String, Integer>(); // key:requestId

        List<Equipment_Maintenance_Item__c> itemList = [
            SELECT Id, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :targetRequestIds
        ];

        Map<String, List<Equipment_Maintenance_Item__c>> emiMap = new Map<String, List<Equipment_Maintenance_Item__c>>(); // key: requestId, value: List<emi>
        for (Equipment_Maintenance_Item__c emi : itemList) {
            List<Equipment_Maintenance_Item__c> l = emiMap.get(emi.Maintenance_Request__c);
            if (l == null) {
                l = new List<Equipment_Maintenance_Item__c>();
                l.add(emi);
            } else {
                l.add(emi);
            }
            emiMap.put(emi.Maintenance_Request__c, l);
        }
        // 関連するemiのなかでEquipment__r.Maintenance_Cycle__cが最小のものを探す
        for (String requestId : targetRequestIds) {
            for (Equipment_Maintenance_Item__c emi : emiMap.get(requestId)) {
                Integer minCycle = res.get(requestId);
                if (minCycle == null) {
                    res.put(requestId, emi.Equipment__r.Maintenance_Cycle__c.intValue());
                } else if (minCycle >= emi.Equipment__r.Maintenance_Cycle__c.intValue()){
                    res.remove(requestId);
                    res.put(requestId, emi.Equipment__r.Maintenance_Cycle__c.intValue());
                }
            }
        }

        return res;
    }
}