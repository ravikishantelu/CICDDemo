trigger AccountTrigger on Account (after insert, after update, before delete) {
    
    ProQuest__c objCSetting = ProQuest__c.getInstance(UserInfo.getUserId());
    
    if (objCSetting.Account_Trigger_Is_Active__c) {
        
        if (Trigger.isBefore) {
        
            if (Trigger.isDelete) {
                
                if (QueueableAccountHandler.FLAG) {
                    QueueableAccountHandler.commonMethod(Trigger.oldMap, Trigger.isDelete);
                }
            }
        }
        
        if (Trigger.isAfter) {
            
            if (Trigger.isInsert || Trigger.isUpdate) {
                
                if (QueueableAccountHandler.FLAG) {
                    
                    if (Trigger.isUpdate) {
                        QueueableAccountHandler.commonMethod(Trigger.newMap, Trigger.isDelete);
                    }
                    
                    QueueableAccountHandler.splitRecords(Trigger.NEW, objCSetting);
                }
            }
        }
    }
}