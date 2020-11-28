@RestResource(urlMapping='/Account/*')

global with sharing class MyRestResource {

    @HttpGet @RemoteAction @ReadOnly
    global static List<Account> doGet() {
    
        //String accId = RestContext.request.params.get('id');
        
        return [
            SELECT
                OwnerId, Name, Website, Active__c, BillingState, Address_Validation__c,
                (
                SELECT
                    Project__r.Name, Project__r.Budget__c, Project__r.Business_Controller__c, Project__r.Status__c,
                    Project__r.Start_Date__c, Project__r.End_Date__c, Project__r.Minimum_SLA_hours__c
                FROM Account.Junctions__r
                )
            FROM Account
        ];
    }
    
    
    @HttpPost
    global static String doPost(String stripeToken) {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('requestStringrequestString'+requestString+'stripeTokenstripeToken'+stripeToken);
        return stripeToken;
    }
}