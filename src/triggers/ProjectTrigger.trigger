trigger ProjectTrigger on Project__c (after update, before delete) {
    
    ProQuest__c objCSetting = ProQuest__c.getInstance(UserInfo.getUserId());
    
    if (objCSetting.Project_Trigger_Is_Active__c) {
        
        if (Trigger.isAfter) {
        
            if (Trigger.isUpdate) {
                
                if (ProjectHandler.FLAG) {
                    ProjectHandler.commonMethod(Trigger.newMap, Trigger.isDelete);
                }
            }
        }
        if (Trigger.isBefore) {
        
            if (Trigger.isDelete) {
                
                if (ProjectHandler.FLAG) {
                    ProjectHandler.commonMethod(Trigger.oldMap, Trigger.isDelete);
                }
            }
        }
    }
}