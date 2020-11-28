@isTest

private class ProQuest_Test {
    
    public static ProQuest__c commonMethod() {
        
        ProQuest__c objCSetting = NEW ProQuest__c();
        objCSetting.Account_Trigger_Is_Active__c = TRUE;
        objCSetting.Endpoint__c = 'https://www.test.com';
        objCSetting.Junction_Trigger_Is_Active__c = TRUE;
        objCSetting.Key__c = 'test';
        objCSetting.Project_Trigger_Is_Active__c = TRUE;
        objCSetting.Stakeholder_Trigger_Is_Active__c = TRUE;
        insert objCSetting;
        
        return objCSetting;
    }
    
    public static List<Account> createAccounts(Integer count) {
        
        List<Account> lstAccsToInsert = NEW List<Account>();
        
        
        for(Integer i=0; i<200; i++) {
        
            Account objAcc = NEW Account();
            objAcc.Name = 'Test Account'+i;
            objAcc.BillingStreet = '110 SW Washington St';
            objAcc.BillingCity = 'Peoria';
            objAcc.BillingCountry = 'USA';
            objAcc.SLA_hours__c = 5.0;
            lstAccsToInsert.add(objAcc);
        }
        
        insert lstAccsToInsert;
            
        return lstAccsToInsert;
    }
    static testMethod void coverAll() {
        
        Test.startTest();
            
            ProQuest__c objCSetting = commonMethod();
            
            Test.setMock(HttpCalloutMock.class, new GoogleCalloutMock());
            
            List<Account> lstAccsToInsert = createAccounts(200);
            List<Account> lstAccsToUpdate = NEW List<Account>();
            
            List<Account> lstResults = coverRestResource();
            System.assertEquals(200, lstResults.size());
            
            for(Account objAcc : lstAccsToInsert) {
            
                objAcc.BillingStreet = '12122132';
                objAcc.BillingCity = '2312312';
                objAcc.BillingCountry = '12312312';
                lstAccsToUpdate.add(objAcc);
            }
            
            update lstAccsToUpdate;
            
            List<Project__c> lstProjsToInsert = NEW List<Project__c>();
            List<Project__c> lstProjsToUpdate = NEW List<Project__c>();
            
            for(Integer i=0; i<200; i++) {
            
                Project__c objProj = NEW Project__c();
                objProj.Name = 'Test Project'+i;
                                
                if (i>=0 && i<40) {
                    
                    objProj.Start_Date__c = Date.TODAY().addYears(-2);
                    if (i<=20) {
                        objProj.End_Date__c = Date.TODAY();
                    }
                    else {
                        objProj.End_Date__c = Date.TODAY().addYears(-1);
                    }
                    objProj.Status__c = System.Label.Completed;
                }
                else if (i>=40 && i<100) {
                    
                    objProj.Start_Date__c = Date.TODAY().addMonths(-1);
                    objProj.End_Date__c = Date.TODAY();
                    objProj.Status__c = System.Label.Active;
                }
                else {
                    objProj.Start_Date__c = Date.TODAY().addDays(-1);
                    objProj.End_Date__c = Date.TODAY();
                    objProj.Status__c = 'Draft';
                }
                
                lstProjsToInsert.add(objProj);
            }
            insert lstProjsToInsert;
            
            for(Project__c objProj : lstProjsToInsert) {
                
                objProj.Start_Date__c = Date.TODAY();
                objProj.End_Date__c = Date.TODAY().addDays(1);
                objProj.Status__c = System.Label.Completed;
                
                lstProjsToUpdate.add(objProj);
            }
                
            update lstProjsToUpdate;
            
            List<Junction__c> lstJuncs = NEW List<Junction__c>();
            
            for(Integer i=0; i<200; i++) {
                Junction__c objjunc = NEW Junction__c();
                objJunc.Account__c = lstAccsToInsert[i].Id;
                objJunc.Project__c = lstProjsToInsert[i].Id;
                lstJuncs.add(objJunc);
            }
            
            insert lstJuncs;
            
            List<Stakeholder__c> lstStks = NEW List<Stakeholder__c>();
            
            for(Integer i=0; i<200; i++) {
                
                Stakeholder__c objStk = NEW Stakeholder__c();
                objStk.Name = 'Test Stake'+i;
                objStk.Project__c = lstProjsToInsert[i].Id;
                lstStks.add(objStk);
            }
            
            insert lstStks;
            
            delete lstJuncs;
            
            ProjectHandler.FLAG = TRUE;
            delete lstProjsToInsert;
            
        Test.stopTest();
    }
    
    static testMethod void coverAll2() {
        
        Test.startTest();
            
            ProQuest__c objCSetting = commonMethod();
            
            Test.setMock(HttpCalloutMock.class, new GoogleCalloutMock());
            
            Account objAcc = NEW Account();
            objAcc.Name = 'Test Account';
            objAcc.BillingStreet = '110 SW Washington St';
            objAcc.BillingCity = 'Peoria';
            objAcc.BillingCountry = 'USA';
            objAcc.SLA_hours__c = 5.0;
            insert objAcc;
            
            Project__c objProj = NEW Project__c();
            objProj.Name = 'Test Project';
            objProj.Status__c = System.Label.Active;
            insert objProj;
            
            Junction__c objjunc = NEW Junction__c();
            objJunc.Account__c = objAcc.Id;
            objJunc.Project__c = objProj.Id;
            insert objJunc;
            
            ProjectHandler.FLAG = TRUE;
            delete objProj;
            
            QueueableAccountHandler.FLAG = TRUE;
            delete objAcc;
            
        Test.stopTest();
    }
    
    
    static List<Account> coverRestResource() {

        RestRequest req = NEW RestRequest(); 
        RestResponse res = NEW RestResponse();
        
        req.requestURI = 'https://proquest-developer-edition.ap5.force.com/services/apexrest/Account';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        return MyRestResource.doGet();
    }
}