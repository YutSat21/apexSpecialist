trigger MaintenanceRequest on Case (before update) {
    // ToDo: Call MaintenanceRequestHelper.updateWorkOrders
    MaintenanceRequestHelper.updateWorkOrders(Trigger.new);
}