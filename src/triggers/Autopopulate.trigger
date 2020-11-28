trigger Autopopulate on Junction2__c (before insert, before update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isUpdate || Trigger.isInsert) {
            for(Junction2__c s : Trigger.NEW) {
                s.External_Id__c = s.Account__c+''+s.Stakeholder__C;
            }
        }
    }
}