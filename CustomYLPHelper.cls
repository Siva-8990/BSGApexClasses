public with sharing class CustomYLPHelper {
    //used to avoid Recursive Trigger
    public static Boolean isFirstTime = true;
    public static void checkYearExists(List<Custom_Yearly_List_Price__c> customYLPList, Boolean isInsert){
        Try{
            Id contRecordTypeId = Schema.SObjectType.Custom_Yearly_List_Price__c.getRecordTypeInfosByName().get('Rahr').getRecordTypeId();
           
            List<Id> productIds = new List<Id>();
            for(Custom_Yearly_List_Price__c customYLPRec: customYLPList){
        
                productIds.add(customYLPRec.Product__c);
            }
            system.debug('productIds' + productIds);
			if(Custom_Yearly_List_Price__c.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.id.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Name.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Product__c.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Active__c.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Fiscal_Year__c.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Crop_Year__c.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.CurrencyIsoCode.isAccessible()){
				Map<ID,Custom_Yearly_List_Price__c> customYLPMap = new Map<ID,Custom_Yearly_List_Price__c>([SELECT id, Name, Product__c, Active__c,Fiscal_Year__c,Crop_Year__c,CurrencyIsoCode FROM Custom_Yearly_List_Price__c WHERE Product__c IN :productIds]);
				system.debug('customYLPMap' + customYLPMap);
				for(Custom_Yearly_List_Price__c newYLPRecord: customYLPList){
					for(Custom_Yearly_List_Price__c oldYLPRecord : customYLPMap.values()) {
						 if(newYLPRecord.RecordTypeId == contRecordTypeId && newYLPRecord.Product__c == oldYLPRecord.Product__c && newYLPRecord.Fiscal_Year__c == oldYLPRecord.Fiscal_Year__c && newYLPRecord.CurrencyIsoCode == oldYLPRecord.CurrencyIsoCode){ 
						
							if(isInsert)
								newYLPRecord.addError('The Fiscal Year ' + newYLPRecord.Fiscal_Year__c +' for this product already exists and inactive.');
							else {
								if(newYLPRecord.Id != oldYLPRecord.id)
									newYLPRecord.addError('The Fiscal Year ' + newYLPRecord.Fiscal_Year__c +' for this product already exists and inactive.');
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
    public static void checkcylpYearExists(List<Custom_Yearly_List_Price__c> CYLPList, Boolean isInsert){
         Try{
            
            List<Id> getproductIds = new List<Id>();
			
			if(Custom_Yearly_List_Price__c.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.id.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Name.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Product__c.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Active__c.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Fiscal_Year__c.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.Crop_Year__c.isAccessible() && Schema.SObjectType.Custom_Yearly_List_Price__c.fields.CurrencyIsoCode.isAccessible()){
				Map<ID,Custom_Yearly_List_Price__c> CYLPMap = new Map<ID,Custom_Yearly_List_Price__c>([SELECT id, Name, Product__c, Active__c,Fiscal_Year__c,Crop_Year__c,CurrencyIsoCode FROM Custom_Yearly_List_Price__c WHERE Product__c IN :getproductIds]);
				system.debug('customYLPMap' + CYLPMap);
				checkcustomcylpYearExists(CYLPList,isInsert,CYLPMap);
				
			}
         }
	
		
		 
		 
		 
    
             
         catch (Exception objectException) {
            System.debug('An unexpected error has occurred::: ' + objectException.getMessage());            
        }    
    }
	 public static void checkcustomcylpYearExists(List<Custom_Yearly_List_Price__c> CYLPList, Boolean isInsert,Map<ID,Custom_Yearly_List_Price__c> CYLPMap){
		  Try{
              Id hopRecordTypeId = Schema.SObjectType.Custom_Yearly_List_Price__c.getRecordTypeInfosByName().get('US Hops').getRecordTypeId();
            Id caHopsRecordTypeId = Schema.SObjectType.Custom_Yearly_List_Price__c.getRecordTypeInfosByName().get('CA Hops').getRecordTypeId();
              String cylpStatusDynamic;
		 
		 for(Custom_Yearly_List_Price__c newCYLPRecord: CYLPList){
					for(Custom_Yearly_List_Price__c oldCYLPRecord : CYLPMap.values()) {
						if(newCYLPRecord.RecordTypeId == hopRecordTypeId || newCYLPRecord.RecordTypeId == caHopsRecordTypeId){
						 
							 if(newCYLPRecord.Product__c == oldCYLPRecord.Product__c && newCYLPRecord.Crop_Year__c == oldCYLPRecord.Crop_Year__c && newCYLPRecord.CurrencyIsoCode == oldCYLPRecord.CurrencyIsoCode && oldCYLPRecord.Active__c == True || oldCYLPRecord.Active__c == False ){
								if(newCYLPRecord.Active__c == True){
                                    cylpStatusDynamic = 'active';
                                }else if(newCYLPRecord.Active__c == False){
                                    cylpStatusDynamic = 'inactive';} 
							if(isInsert)
								newCYLPRecord.addError('The Crop Year ' + newCYLPRecord.Crop_Year__c +' for this product already exists and '+cylpStatusDynamic+'.');
							else {
								if(newCYLPRecord.Id != oldCYLPRecord.id)
									newCYLPRecord.addError('The Crop Year ' + newCYLPRecord.Crop_Year__c +' for this product already exists and '+cylpStatusDynamic+'.');
							}
								
						} 
						  
						}
					}
				}
				}
	
             
         catch (Exception objectException) {
            System.debug('An unexpected error has occurred::: ' + objectException.getMessage());            
        }
		 }
		 
		 
    
    public static void CYLPDeleted(List<Custom_Yearly_List_Price__c> cylpList){
        for(Custom_Yearly_List_Price__c CYLP : cylpList){
        CYLP.adderror('CYLP Record Cannot be deleted');
    }
    }
}
