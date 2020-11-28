public class StakeholderHandler {
    
    public static void commonMethod(List<Stakeholder__c> lstStks) {
        
        Map<Id, List<Stakeholder__c>> mapPrjStks = NEW Map<Id, List<Stakeholder__c>>();
        Map<Id, List<Junction__c>> mapPrjJuncs = NEW Map<Id, List<Junction__c>>();
        
        for (Stakeholder__c objstk : lstStks) {
            
            if (mapPrjStks.containskey(objstk.Project__c)) {
                mapPrjStks.get(objstk.Project__c).add(objstk);
            }
            else {
                mapPrjStks.put(objstk.Project__c, NEW List<Stakeholder__c>{objstk});
            }
        }
        
        for (Junction__c objJunc : [SELECT Account__c, Project__c FROM Junction__c WHERE Project__c IN : mapPrjStks.keySet()]) {
            
            if (mapPrjJuncs.containsKey(objJunc.Project__c)) {
                mapPrjJuncs.get(objJunc.Project__c).add(objJunc);
            }
            else {
                mapPrjJuncs.put(objJunc.Project__c, NEW List<Junction__c>{objJunc});
            }
        }
        
        Map<Id, Junction2__c> mapAccStks = NEW Map<Id, Junction2__c>();
        List<Junction2__c> lstJunc2s = NEW List<Junction2__c>();
        
        for (Id key : mapPrjStks.keySet()) {
            
            for (Stakeholder__c objStk : mapPrjStks.get(key)) {
                
                if (mapPrjJuncs.containsKey(key)) {
                
                    for(Junction__c objJunc : mapPrjJuncs.get(key)) {
                    
                        Junction2__c obj = NEW Junction2__c();
                        obj.Account__c = objJunc.Account__c;
                        obj.Stakeholder__c = objStk.Id;
                        //mapAccStks.put(obj.Account__c, obj);
                        lstJunc2s.add(obj);
                    }
                }
            }
        }
        
        if (!lstJunc2s.isEmpty()) {
            Database.insert(lstJunc2s, FALSE);
        }
    }
}