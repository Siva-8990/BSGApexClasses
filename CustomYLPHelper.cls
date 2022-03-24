public with sharing class CustomYLPHelper {
    //used to avoid Recursive Trigger
    public static Boolean isFirstTime = true;
    public static void checkYearExists(List<Custom_Yearly_List_Price__c> customYLPList, Boolean isInsert){
        Try{
            Id contRecordTypeId = Schema.SObjectType.Custom_Yearly_List_Price__c.getRecordTypeInfosByName().get('Rahr').getRecordTypeId();
            Id hopRecordTypeId = Schema.SObjectType.Custom_Yearly_List_Price__c.getRecordTypeInfosByName().get('US Hops').getRecordTypeId();
            Id caHopsRecordTypeId = Schema.SObjectType.Custom_Yearly_List_Price__c.getRecordTypeInfosByName().get('CA Hops').getRecordTypeId();
            List<Id> productIds = new List<Id>();
            for(Custom_Yearly_List_Price__c customYLPRec: customYLPList){
               // if(customYLPRec.RecordTypeId == contRecordTypeId ){          
                productIds.add(customYLPRec.Product__c);
                //}
            }
            system.debug('productIds' + productIds);
            //Map<ID,Custom_Yearly_List_Price__c> customYLPMap = new Map<ID,Custom_Yearly_List_Price__c>([SELECT id, Name, Product__c, Active__c,Fiscal_Year__c,Crop_Year__c,CurrencyIsoCode FROM Custom_Yearly_List_Price__c WHERE Product__c IN :productIds AND Active__c = true]);
            Map<ID,Custom_Yearly_List_Price__c> customYLPMap = new Map<ID,Custom_Yearly_List_Price__c>([SELECT id, Name, Product__c, Active__c,Fiscal_Year__c,Crop_Year__c,CurrencyIsoCode FROM Custom_Yearly_List_Price__c WHERE Product__c IN :productIds]);
            system.debug('customYLPMap' + customYLPMap);
            for(Custom_Yearly_List_Price__c newYLPRecord: customYLPList){
                for(Custom_Yearly_List_Price__c oldYLPRecord : customYLPMap.values()) {
                     if(newYLPRecord.RecordTypeId == contRecordTypeId ){ 
                    if(newYLPRecord.Product__c == oldYLPRecord.Product__c && newYLPRecord.Fiscal_Year__c == oldYLPRecord.Fiscal_Year__c && newYLPRecord.CurrencyIsoCode == oldYLPRecord.CurrencyIsoCode){
                        if(isInsert)
                        	newYLPRecord.addError('The Fiscal Year ' + newYLPRecord.Fiscal_Year__c +' for this product already exists and inactive.');
                    	else {
                            if(newYLPRecord.Id != oldYLPRecord.id)
                                newYLPRecord.addError('The Fiscal Year ' + newYLPRecord.Fiscal_Year__c +' for this product already exists and inactive.');
                        }
                            
                    } 
                     }
                   
                    if(newYLPRecord.RecordTypeId == hopRecordTypeId || newYLPRecord.RecordTypeId == caHopsRecordTypeId){
                     
                         if(newYLPRecord.Product__c == oldYLPRecord.Product__c && newYLPRecord.Crop_Year__c == oldYLPRecord.Crop_Year__c && newYLPRecord.CurrencyIsoCode == oldYLPRecord.CurrencyIsoCode && oldYLPRecord.Active__c == True ){
                        if(isInsert)
                        	newYLPRecord.addError('The Crop Year ' + newYLPRecord.Crop_Year__c +' for this product already exists and active.');
                    	else {
                            if(newYLPRecord.Id != oldYLPRecord.id)
                                newYLPRecord.addError('The Crop Year ' + newYLPRecord.Crop_Year__c +' for this product already exists and active.');
                        }
                            
                    } 
                          if(newYLPRecord.Product__c == oldYLPRecord.Product__c && newYLPRecord.Crop_Year__c == oldYLPRecord.Crop_Year__c && newYLPRecord.CurrencyIsoCode == oldYLPRecord.CurrencyIsoCode && oldYLPRecord.Active__c == False ){
                        if(isInsert)
                        	newYLPRecord.addError('The Crop Year ' + newYLPRecord.Crop_Year__c +' for this product already exists and is inactive.');
                    	else {
                            if(newYLPRecord.Id != oldYLPRecord.id)
                                newYLPRecord.addError('The Crop Year ' + newYLPRecord.Crop_Year__c +' for this product already exists and is inactive.');
                        }
                            
                    } 
                             
                        

                    }
                   
                            
                    
                }
            }  
        } 
        catch (Exception objException) {
            System.debug('An unexpected error has occurred::: ' + objException.getMessage());            
        }        
    }
    public static void CYLPDeleted(List<Custom_Yearly_List_Price__c> cylpList){
        for(Custom_Yearly_List_Price__c CYLP : cylpList){
        CYLP.adderror('CYLP Record Cannot be deleted');
    }
    }
}
