public class ProjectHandler {
    
    public static boolean FLAG = TRUE;
    
    public Static void commonMethod(Map<Id, Project__c> mapProjects, Boolean IsDelete) {
        
        List<Junction__c> lstJuncs = NEW List<Junction__c>();
        
        for(Project__c objProj : [
            SELECT Status__c, (SELECT Account__c, Project__c FROM Project__c.Junctions__r) FROM Project__c WHERE Id IN : mapProjects.keySet()
        ]) {
            
            lstJuncs.addAll(objProj.Junctions__r);
        }
        
        if (!lstJuncs.isEmpty()) {
            if (IsDelete) {
                delete lstJuncs;
            }
            else {
                JunctionHandler.commonMethod(lstJuncs);
            }
        }
    }
}