public class QueueableAccountHandler implements System.Queueable, Database.AllowsCallouts {
    
    public static boolean FLAG = TRUE;
    private Set<Id> accIds;
    private String url;
    private String key;
    
    public static void splitRecords(List<Account> lstAccs, ProQuest__c objCSetting) {
        
        List<Id> accIds = NEW List<Id>();
                    
        for (Account acc : lstAccs) {
            
            if (acc.BillingStreet != NULL && acc.BillingCity != NULL && acc.BillingCountry != NULL) {
            
                accIds.add(acc.Id);
            }
        }
        
        if (!accIds.isEmpty()) { 
        
            Integer count = accIds.size();
            Integer firstCount = 0;
            Integer secondCount = 0;
            Integer thirdCount = 0;
            Integer fourthCount = 0;
            Integer fifthCount = 0;
            
            Set<Id> locONEIds = NEW Set<Id>();
            Set<Id> locTWOIds = NEW Set<Id>();
            Set<Id> locTHREEIds = NEW Set<Id>();
            Set<Id> locFOURIds = NEW Set<Id>();
            Set<Id> locFIVEIds = NEW Set<Id>();
            
            if (count > 0 && count <= 40) {
                firstCount = count;
                secondCount = 0;
            }
            else if (count > 40 && count <= 80) {
                firstCount = 40;
                secondCount = count - 40;
            }
            else if (count > 80 && count <= 120) {
                firstCount = 40;
                secondCount = 40;
                thirdCount = count - 80;
            }
            else if (count > 120 && count <= 160) {
                firstCount = 40;
                secondCount = 40;
                thirdCount = 40;
                fourthCount = count - 120;
            }
            else if (count > 160 && count <= 200) {
                firstCount = 40;
                secondCount = 40;
                thirdCount = 40;
                fourthCount = 40;
                fifthCount = count - 160;
            }
            
            if (firstCount > 0) {
                Integer numCount = firstCount;
                System.debug('numCountnumCount'+numCount);
                for(Integer i=0; i<numCount; i++) {
                    locONEIds.add(accIds[i]);
                }
            }
            if (secondCount > 0) {
                
                Integer numCount = secondCount+firstCount;
                System.debug('numCountnumCount'+numCount);
                for(Integer i=40; i<numCount; i++) {
                    locTWOIds.add(accIds[i]);
                }
            }
            if (thirdCount > 0) {
                Integer numCount = thirdCount+secondCount+firstCount;
                System.debug('numCountnumCount'+numCount);
                for(Integer i=80; i<numCount; i++) {
                    locThreeIds.add(accIds[i]);
                }
            }
            if (fourthCount > 0) {
                Integer numCount = fourthCount+thirdCount+secondCount+firstCount;
                System.debug('numCountnumCount'+numCount);
                for(Integer i=120; i<numCount; i++) {
                    locFOURIds.add(accIds[i]);
                }
            }
            if (fifthCount > 0) {
                Integer numCount = fifthCount+fourthCount+thirdCount+secondCount+firstCount;
                System.debug('numCountnumCount'+numCount);
                for(Integer i=160; i<numCount; i++) {
                    locFIVEIds.add(accIds[i]);
                }
            }
            
             if (locONEIds.size() > 0) {
                System.enqueueJob(NEW QueueableAccountHandler(locONEIds, objCSetting.Endpoint__c, objCSetting.Key__c));
            }
            
            if (locTWOIds.size() > 0) {
                System.enqueueJob(NEW QueueableAccountHandler(locTWOIds, objCSetting.Endpoint__c, objCSetting.Key__c));
            }
            
            if (locTHREEIds.size() > 0) {
                System.enqueueJob(NEW QueueableAccountHandler(locTHREEIds, objCSetting.Endpoint__c, objCSetting.Key__c));
            }
            
            if (locFOURIds.size() > 0) {
                System.enqueueJob(NEW QueueableAccountHandler(locFOURIds, objCSetting.Endpoint__c, objCSetting.Key__c));
            }
            
            if (locFIVEIds.size() > 0) {
                System.enqueueJob(NEW QueueableAccountHandler(locFIVEIds, objCSetting.Endpoint__c, objCSetting.Key__c));
            }
        }
    }
    
    public Static void commonMethod(Map<Id, Account> mapAccounts, Boolean IsDelete) {
        
        List<Junction__c> lstJuncs = NEW List<Junction__c>();
        
        for(Account objAcc : [
            SELECT SLA_hours__c, (SELECT Account__c, Project__c FROM Account.Junctions__r) FROM Account WHERE Id IN : mapAccounts.keySet()
        ]) {
            
            lstJuncs.addAll(objAcc.Junctions__r);
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
    
    public QueueableAccountHandler(Set<Id> accIds, String url, String key) {
        
        this.accIds = accIds;
        this.url = url;
        this.key = key;
    }
    
    public void execute(System.QueueableContext objContext) {
        
        List<Account> lstAccToUpdate = NEW List<Account>();
        Map<Id, Account> mapAccToUpdate = NEW Map<Id, Account>();
        
        for(Account acc : [
            SELECT
                BillingStreet, BillingCity, BillingCountry, BillingLatitude, BillingLongitude,
                BillingState, BillingPostalCode, Address_Validation__c
            FROM Account
            WHERE Id IN : accIds
        ]) {
            
            String address = '';
            
            address += acc.BillingStreet+', '+acc.BillingCity+', '+acc.BillingCountry;
            
            Http http = NEW Http();
                
            HttpRequest req = NEW HttpRequest();
            req.setEndPoint(url+EncodingUtil.urlEncode(address, 'UTF-8')+'&key='+key);
            req.setMethod('POST');
            req.setHeader('Content-length', '0');
            HTTPResponse res = NEW HTTPResponse();
            res = http.send(req);
            System.debug(res.getBody());
                    
            if (res.getStatusCode() == 200) {

                if (GoogleResponse.parse(res.getBody()).status == 'OK') {
                        
                    for(GoogleResponse.cls_results s : GoogleResponse.parse(res.getBody()).results) {

                        if (s.formatted_address != '') {
                            //110 SW Washington St, Peoria, IL 61602, USA
                            String resp_address = s.formatted_address;
                            List<String> lstBilling = NEW List<String>();
                            if (resp_address.contains(',')) {
                                lstBilling = resp_address.split(', ');

                                if (lstBilling.size() == 4) {
                                    acc.BillingStreet = lstBilling[0];
                                    acc.BillingCity = lstBilling[1];
                                    if (lstBilling[2].contains(' ')) {
                                        acc.BillingState = lstBilling[2].split(' ')[0];
                                        acc.BillingPostalCode = lstBilling[2].split(' ')[1];
                                        
                                    }
                                    acc.BillingCountry = lstBilling[3];
                                }
                            }
                        }
                        acc.BillingLatitude = s.geometry.location.lat;
                        acc.BillingLongitude = s.geometry.location.lng;
                        acc.Address_Validation__c = System.Label.Valid;
                        mapAccToUpdate.put(acc.Id, acc);
                    }
                }
                else {
                    acc.BillingLatitude = NULL;
                    acc.BillingLongitude = NULL;
                    acc.Address_Validation__c = System.Label.Invalid;
                    mapAccToUpdate.put(acc.Id, acc);
                }
            }
            else {
                acc.BillingLatitude = NULL;
                acc.BillingLongitude = NULL;
                acc.Address_Validation__c = System.Label.Invalid;
                mapAccToUpdate.put(acc.Id, acc);
            }
        }
        if (!mapAccToUpdate.isEmpty()) {
            QueueableAccountHandler.FLAG = FALSE;
            update mapAccToUpdate.values();
        }
    }
}