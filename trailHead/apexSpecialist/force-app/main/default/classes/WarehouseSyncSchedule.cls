global class WarehouseSyncSchedule implements Schedulable{
    // implement scheduled code here
    global void execute(SchedulableContext SC) {
        System.enqueueJob(New WarehouseCalloutService());
    }
}