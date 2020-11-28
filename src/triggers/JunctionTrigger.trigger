trigger JunctionTrigger on Junction__c (before insert, before update, after insert, after update, after delete) {

    ProQuest__c objCSetting = ProQuest__c.getInstance(UserInfo.getUserId());
    
    if (Trigger.isBefore) {
        
        if (Trigger.isInsert || Trigger.isUpdate) {
            JunctionHandler.beforeTrigger(Trigger.NEW);
        }
    }
    if (objCSetting.Junction_Trigger_Is_Active__c) {
        
        if (Trigger.isAfter) {
        
            if (Trigger.isInsert || Trigger.isUpdate) {
                
                JunctionHandler.commonMethod(Trigger.NEW);
                
                if (Trigger.isInsert) {
                    JunctionHandler.createStakeholders(Trigger.NEW);
                }
            }
            
            if (Trigger.isDelete) {
            
                JunctionHandler.commonMethod(Trigger.OLD);
                JunctionHandler.deleteAccountStakeholders(Trigger.OLD);
            }
        }
    }
}