trigger StakeholderTrigger on Stakeholder__c (after insert) {
    
    ProQuest__c objCSetting = ProQuest__c.getInstance(UserInfo.getUserId());
    
    if (objCSetting.Stakeholder_Trigger_Is_Active__c) {
        
        if (Trigger.isAfter) {
            
            if (Trigger.isInsert) {
                
                StakeholderHandler.commonMethod(Trigger.NEW);
            }
        }
    }
}