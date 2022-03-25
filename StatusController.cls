/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This class is used to validate status of Inventory Reserve. 
*********************************************************************************************
Version    	Date        	Team    	Comments
*********************************************************************************************
* 1    		20 Mar 2021    	Pradeep    	Initial Development 
*********************************************************************************************/
public class StatusController {
    public static Boolean recursion = true;
    
    
    public static void stageValidation(Map<Id,Inventory_Reserve__c> InventoryNewMap,Map<Id,Inventory_Reserve__c> InventoryOldMap)
    {
        
        recursion = false;
        //Get dependentvalues from the Status Dependent field
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>(InventoryReserveController.getDependentPicklistValues(Inventory_Reserve__c.Status_dependent__c));
        
        for(Inventory_Reserve__c Inventoryreserveobject : InventoryNewMap.values())
        {
            if(dependentPicklistValues.containsKey(InventoryOldMap.get(Inventoryreserveobject.Id).Status__c))
            {
                if(!dependentPicklistValues.get(InventoryOldMap.get(Inventoryreserveobject.Id).Status__c).contains(Inventoryreserveobject.Status__c) && Inventoryreserveobject.Status__c !=  InventoryOldMap.get(Inventoryreserveobject.Id).Status__c)
                {
                    // Dynamic Error message which has to be shown during error conditions
                    Inventoryreserveobject.addError('You cannot go to "'+Inventoryreserveobject.Status__c+'" status."');
                }
            }
        }
        
    }
    
    //Method to get dependent values
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
    
    
}
