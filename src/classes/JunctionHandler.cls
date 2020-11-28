public class JunctionHandler {
    
    public static void beforeTrigger(List<Junction__c> lstJuncs) {
        
        for(Junction__c j : lstJuncs) {
            j.External_Id__c = j.Account__c+''+J.Project__c;
        }
    }
    
    public static void commonMethod(List<Junction__c> lstJuncs) {
        
        Set<Id> accIds = NEW Set<Id>();
        Set<Id> proIds = NEW Set<Id>();
        
        for(Junction__c objJunc : lstJuncs) {
            accIds.add(objJunc.Account__c);
            proIds.add(objJunc.Project__c);
        }
        updateAccounts(accIds);
        updateProjects(proIds);
    }
    
    public static void deleteAccountStakeholders(List<Junction__c> lstJuncs) {
        
        List<Junction2__c> lstAccStksToDelete = NEW List<Junction2__c>();
        Set<String> setAccStks = NEW Set<String>();
        
        for(Junction__c objJunc : lstJuncs) {
            String accstkId = objJunc.Account__c+''+objJunc.Project__c;
            setAccStks.add(accstkId);
        }
        lstAccStksToDelete = [SELECT Id FROM Junction2__c WHERE AccountProject__c IN : setAccStks];

        if (!lstAccStksToDelete.isEmpty()) {
            delete lstAccStksToDelete;
        }
    }
    
    public static void updateProjects(Set<Id> proIds) {
        
        List<Project__c> lstPrjsToUpdate = NEW List<Project__c>();
        
        for(Project__c objPrj : [
            SELECT
                Minimum_SLA_hours__c, (
                    SELECT
                        Account__r.SLA_hours__c FROM Project__c.Junctions__r ORDER BY Account__r.SLA_hours__c ASC
                )
            FROM Project__c WHERE Id IN : proIds
        ]) {
            
            if (!objPrj.Junctions__r.isEmpty()) {
                
                objPrj.Minimum_SLA_hours__c = objPrj.Junctions__r[0].Account__r.SLA_hours__c;
                lstPrjsToUpdate.add(objPrj);
            }
            else {
                objPrj.Minimum_SLA_hours__c = NULL;
                lstPrjsToUpdate.add(objPrj);
            }
        }
        
        if (!lstPrjsToUpdate.isEmpty()) {
            ProjectHandler.FLAG = FALSE;
            update lstPrjsToUpdate;
        }
    }
    
    public static void updateAccounts(Set<Id> accIds) {
        
        List<Account> lstAccsToUpdate = NEW List<Account>();
        
        Date minDate;
        Date maxDate;
        
        for(Account objAcc : [
            SELECT
                Active__c, (
                    SELECT
                        Project__r.Status__c, Project__r.Start_Date__c, Project__r.End_Date__c, Project__r.Budget__c
                    FROM Account.Junctions__r ORDER BY Project__r.Start_Date__c
                )
            FROM Account WHERE Id IN : accIds
        ]) {
            
            Set<Id> projectIds = NEW Set<Id>();
            
            Boolean IsActive = FALSE;
            
            Integer count = 0;
            Decimal totalrevenue = 0;
            Decimal currentrevenue = 0;
            
            if (!objAcc.Junctions__r.isEmpty()) {
                
                for(Junction__c objJunc : objAcc.Junctions__r) {
                    
                    projectIds.add(objJunc.Project__c);
                    
                    if (count == 0) {
                    
                        minDate = objJunc.Project__r.Start_Date__c;
                        maxDate = objJunc.Project__r.End_Date__c;
                    }
                    
                    if (maxDate < objJunc.Project__r.End_Date__c) {
                        maxDate = objJunc.Project__r.End_Date__c;
                    }
                    
                    if (objJunc.Project__r.Budget__c == NULL) {
                        objJunc.Project__r.Budget__c = 0;
                    }
                    
                    if (
                        objJunc.Project__r.Status__c.equalsIgnoreCase(System.Label.Active) || 
                        objJunc.Project__r.Status__c.equalsIgnoreCase(System.Label.Completed)
                    ) {
                    
                        totalrevenue += objJunc.Project__r.Budget__c;
                        
                        if (objJunc.Project__r.End_Date__c != NULL) {
                            
                            if (objJunc.Project__r.End_Date__c.year() == Date.TODAY().year()) {
                            
                                currentrevenue += objJunc.Project__r.Budget__c;
                            }
                        }
                        if (objJunc.Project__r.Status__c.equalsIgnoreCase(System.Label.Active)) {
                            IsActive = TRUE;
                        }
                    }
                    count++;
                }
            }
            
            objAcc.Active__c = IsActive;
            objAcc.First_Project_Start_Date__c = minDate;
            objAcc.Last_Project_End_Date__c = maxDate;
            objAcc.AnnualRevenue = totalrevenue;
            objAcc.Current_Annual_Revenue__c = currentrevenue;
            objAcc.No_of_Projects__c = projectIds.size();
            
            lstAccsToUpdate.add(objAcc);
        }
        
        if (!lstAccsToUpdate.isEmpty()) {
            QueueableAccountHandler.FLAG = FALSE;
            update lstAccsToUpdate;
        }
    }
    
    public static void createStakeholders(List<Junction__c> lstJuncs) {
        
        Set<Id> proIds = NEW Set<Id>();
        
        for(Junction__c objJunc : lstJuncs) {
            proIds.add(objJunc.Project__c);
        }
        
        List<Stakeholder__c> lstStks = NEW List<Stakeholder__c>();
        
        for(Project__c pro : [
            SELECT 
                (SELECT Name, Project__c, Email__c, Title__c, Type__c FROM Project__c.Stakeholders__r)
            FROM Project__c WHERE Id IN : proIds
        ]) {
            
            if (!pro.Stakeholders__r.isEmpty()) {
                lstStks.addAll(pro.Stakeholders__r);
            }
        }
        
        if (!lstStks.isEmpty()) {
            StakeholderHandler.commonMethod(lstStks);
        }
    }
}