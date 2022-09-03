public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<case> requests) {
        // TODO: Complete the method to update workorders
        List<Case> newReqs = new List<Case>();
		Map<String, Equipment_Maintenance_Item__c> itemMap = getTargetItems(requests);
        for (Case request : requests) {
            Case newReq = new Case();
            System.debug(requests);
            if ((request.type.equals('Repair') || request.type.equals('Routine Maintenance')) &&
               		request.Status.equals('Closed')) {
                        System.debug(request);
                        newReq = request.clone();
                        newReq.Vehicle__c = request.Vehicle__c;
                        newReq.Product__c = request.Product__c;
                        newReq.ProductId = request.ProductId;
                        newReq.Type = 'Routine Maintenance';
                        newReq.Subject = 'new Routine Maintenace Request';
                        newReq.Date_Reported__c = system.today();
                        //newReq.Date_Due__c = system.today().addDays(minMaintCycle.intValue());
                        newReq.Status = 'New';
                        newReqs.add(newReq);
			}
            upsert newReqs;
        }
    }    
	
    private static Map<String, Equipment_Maintenance_Item__c> getTargetItems(List<Case> updateMaintList) {
        Map<String, Equipment_Maintenance_Item__c> res = new Map<String, Equipment_Maintenance_Item__c>();
        Set<String> maintIds = new Set<String>();
        for (Case maint : updateMaintList) {
           maintIds.add(maint.Id);
        }
        List<Equipment_Maintenance_Item__c> items = [
            SELECT Equipment__c, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c
            FROM Equipment_Maintenance_Item__c
			WHERE Maintenance_Request__c in :maintIds            
        ];
        for (Equipment_Maintenance_Item__c item : items) {
	           res.put(item.Maintenance_Request__c, item);
        }
        return res;
    }    
    
}