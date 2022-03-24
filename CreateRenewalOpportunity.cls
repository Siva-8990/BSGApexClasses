/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This class is used to create renewal opportunity record and invoked from the "Renewal Opportunity" process builder. 
*********************************************************************************************
Version     Date            Team        Comments
*********************************************************************************************
* 1         27 Mar 2020     Vignesh     Initial Development 
*********************************************************************************************/
public without sharing class CreateRenewalOpportunity 
{       
    @Invocablemethod
    //create renewal opportunity record for existing opportunity along with opportunity line item.
    public static void createRenewalOpportunity(List<Opportunity> opportunityListcreation)
    {
        try{
            
            
            Set<Id> oldOpportunityIds = new Set<Id>();
            
            Map<String,String> oldAndNewOpportunityIdMap = new Map<String,String>(); 
            
            for(Opportunity opportunityRecord : opportunityListcreation)
            {
                //Adding opportunity Id to Set.
                oldOpportunityIds.add(opportunityRecord.Id);
            }
            
            List<Opportunity> renewalOpportunityInsertList = new List<Opportunity>();
            
            List<OpportunityLineItem> renewalOpportunityLineItemList = new List<OpportunityLineItem>();
            
            //Existing Opportunity List which holds to BSG Contract List as well.
            List<Opportunity> oldOpportunityList = [SELECT Amount,AccountId,Contact__c,CloseDate,Estimated_Volume__c,Id,Name,OwnerId,Probability,RecordTypeId,RecordType.Name,Renewal__c,StageName,Product_Line__c,(SELECT Id,Effective_End_Date__c FROM Contracts__r limit 1) FROM Opportunity where Id =: oldOpportunityIds];
            
            //Opportunity Line Item List for Existing Opportunity
            List<OpportunityLineItem> OpportunityLineItemList = [SELECT CurrencyIsoCode,Description,Id,IsDeleted,ListPrice,Name,OpportunityId,PricebookEntryId,Product2Id,ProductCode,Quantity,ServiceDate,SortOrder,TotalPrice,UnitPrice FROM OpportunityLineItem where OpportunityId =: oldOpportunityIds];
            
            for(Opportunity opportunityRecord :oldOpportunityList)
            {
                //Only if existing opportunity having BSG Contract , we will create renewal opportunity.
                if(opportunityRecord.Contracts__r.size() > 0)
                {
                    BSG_Contracts__c BSGRecord = opportunityRecord.Contracts__r;
                    //Assinging values for the renewl opportunity.
                    Opportunity opportunityObject=new Opportunity();
                    opportunityObject.Name='Renewal '+opportunityRecord.Name; //Renwal Opportunity name should have prefix 'Renewal'
                    opportunityObject.Parent_Opportunity__c = opportunityRecord.Id; //Backend Parent Opportunity Id field for Reference.
                    opportunityObject.CloseDate = BSGRecord.Effective_End_Date__c; // (opportunityRecord.CloseDate).Addyears(1); //Close date should be 1 year after 
                     if(opportunityRecord.Product_Line__c == 'Rahr'){
                        opportunityObject.StageName='Qualified';
                    }
                    else
                    {
                        opportunityObject.StageName='Prospecting';
                    }
                    opportunityObject.AccountId=opportunityRecord.AccountId;
                    opportunityObject.Amount=opportunityRecord.Amount;
                    opportunityObject.Contact__c=opportunityRecord.Contact__c;
                    opportunityObject.Estimated_Volume__c=opportunityRecord.Estimated_Volume__c;
                    opportunityObject.OwnerId=opportunityRecord.OwnerId;
                    opportunityObject.Renewal__c=true; // Renewal checkbox will be true for renewal opportunity record.
                    opportunityObject.Type='Existing Business';
                    opportunityObject.RecordTypeId=opportunityRecord.RecordTypeId;
                    
                    //Adding renewal record to list.
                    renewalOpportunityInsertList.add(opportunityObject);
                }
                
            }
            
            if(!renewalOpportunityInsertList.isEmpty())
            {
                //inserting renewal opportunity list
                insert renewalOpportunityInsertList;
                
                for(Opportunity getOldAndNewOpportunityIds : renewalOpportunityInsertList)
                {
                    //Adding old opportunity Id and Renewal opportunity Id to Map. 
                    oldAndNewOpportunityIdMap.put(getOldAndNewOpportunityIds.Parent_Opportunity__c,getOldAndNewOpportunityIds.Id);
                }
                createRenewalOpportunityLineItem(oldOpportunityIds,oldAndNewOpportunityIdMap,renewalOpportunityLineItemList,OpportunityLineItemList);
            }
        }
        catch(Exception error)
        {
            system.debug(error.getMessage());
        }
    }
            public static void createRenewalOpportunityLineItem(Set<Id> oldOpportunityIds,Map<String,String> oldAndNewOpportunityIdMap,List<OpportunityLineItem> renewalOpportunityLineItemList,List<OpportunityLineItem> OpportunityLineItemList ){
                
            
                
                for(OpportunityLineItem OpportunityLineItemRecord : OpportunityLineItemList)
                {
                    //cloning the opportunity line item.
                    OpportunityLineItem OpportunityLineItemObject = OpportunityLineItemRecord.clone(false,false,false,false);
                    //changing total price to null and changing old opportunity Id to renewal opportunity Id.
                    OpportunityLineItemObject.TotalPrice = null; 
                    OpportunityLineItemObject.OpportunityId = oldAndNewOpportunityIdMap.get(OpportunityLineItemRecord.OpportunityId); 
                    renewalOpportunityLineItemList.add(OpportunityLineItemObject);
                }
                
                if(!renewalOpportunityLineItemList.isEmpty())
                {
                    //inserting opportunity line item for renewal opportunity.
                    insert renewalOpportunityLineItemList;
                }
            }

    }
    
