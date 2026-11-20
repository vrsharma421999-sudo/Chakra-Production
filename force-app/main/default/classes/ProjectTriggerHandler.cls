public class ProjectTriggerHandler {
    public static void changeStatus(List<Project__c> lstp){
        System.debug('lst of projects are ' + lstp);
        for(Project__c pro: lstp){
            if (pro.Mfg_Clearance_From_Finance__c == null) {continue;}
            if (pro.Pre_Dispatch_Clearance_Finance__c == null) {continue;}
            if (pro.After_Delivery_Installation_Go_Ahead__c == null) {continue;}
            
            if(pro.Mfg_Clearance_From_Finance__c == 'Yes'){
                pro.Project_Status__c = 'SM_team';
            }
            if(pro.Pre_Dispatch_Clearance_Finance__c == 'Yes'){
                pro.Project_Status__c = 'Project Management Team';
            }
            if(pro.After_Delivery_Installation_Go_Ahead__c == 'Yes'){
                pro.Project_Status__c = 'Installation Team';
            }
        }
    }
    
    public static void changeStatusUpdate(List<Project__c> lstp, Map<Id,Project__c> oldmap){
        System.debug('lst of projects are ' + lstp);
         // Getting the Recordtype Chakra Marjak --By Vanshika 26-aug-2026
        Id chakrMarjakRTId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Chakr_Marjak').getRecordTypeId();

        for(Project__c pro: lstp){
  // Bypassing For Recordtype Chakra Marjak --By Vanshika 26-aug-2026
            if(pro.RecordTypeId != chakrMarjakRTId) {
                System.debug('pro.RecordType.developername ' + pro.RecordType.developername);
            /**************************************Arjit on 11-June 2026*************************/
            
            if(pro.Manufacturing_Location__c == 'Vendor' && oldmap.get(pro.Id).Manufacturing_Location__c != 'Vendor'){
                pro.Design_Release_Stage__c = 'Not Applicable';
                System.debug('pro.Design_Release_Stage__c >>> ' + pro.Design_Release_Stage__c);
            }
            
            if(pro.Project_Execution_Status__c == 'CANCELLED' && oldmap.get(pro.Id).Project_Execution_Status__c != 'CANCELLED'){
                pro.Execution_Cancel_Date__c = Date.Today();
                System.debug('pro.Project_Execution_Status__c >>> ' + pro.Project_Execution_Status__c);
            }
            /***********************************************************************************/
            
            if (pro.Mfg_Clearance_From_Finance__c == null) {continue;}
            //if (pro.Pre_Dispatch_Clearance_Finance__c == null) {continue;}
            if (pro.After_Delivery_Installation_Go_Ahead__c == null) {continue;}
            //if (pro.Final_Payment_Status__c == null) {continue;}
            Project__c oldpro = oldmap.get(pro.Id);
            if (oldpro == null) {continue;}
            
            if(pro.Mfg_Clearance_From_Finance__c == 'Yes' && oldmap.get(pro.Id).Mfg_Clearance_From_Finance__c != 'Yes'){
                pro.Project_Status__c = 'SM_team';
                System.debug('pro.Project_Status__c ' + pro.Project_Status__c);
            }
            
            
            
            /*if(pro.Pre_Dispatch_Clearance_Finance__c == 'Yes' && oldmap.get(Pro.Id).Pre_Dispatch_Clearance_Finance__c != 'Yes'){
System.debug('pro.Pre_Dispatch_Clearance_Finance__c ' + pro.Pre_Dispatch_Clearance_Finance__c);
pro.Project_Status__c = 'Project Management Team';
}*/
            if(pro.After_Delivery_Installation_Go_Ahead__c == 'Yes' && oldmap.get(pro.Id).After_Delivery_Installation_Go_Ahead__c != 'Yes'){
                System.debug('pro.After_Delivery_Installation_Go_Ahead__c ' + pro.After_Delivery_Installation_Go_Ahead__c);
                pro.Project_Status__c = 'Installation Team';
            }
            
            List<String> statusOrder = new List<String>{'Finance Team', 'SM_team', 'Design_Team', 'PPC Team', 'SCM', 'Production Team', 'Quality Team', 'Finance Team - Pre Dispatch', 'Project Management Team', 'Dispatch Team', 'Finance Team - Post Delivery', 'Installation Team', 'Final Payment', 'Project Completed'};
                if(pro.Final_Payment_Status__c != 'Pending' && pro.Final_Payment_Status__c != null){
                    Integer currentIndex = statusOrder.indexOf(pro.Project_Status__c);
                    System.debug('currentIndex is  ' + currentIndex);
                    // Move to the next status if possible
                    if (currentIndex != -1 && currentIndex < statusOrder.size() - 1) {
                        pro.Project_Status__c = statusOrder[currentIndex + 1];
                    }
                }
        }
        }
    }
    
    public static void handleCRSignOf(List<Project__c> newList, Map<Id, Project__c> oldMap) {
        Set<Id> povIds = new Set<Id>();
        List<Project__c> projectsToUpdate = new List<Project__c>();
        
        List<Project__c> newlySignedProjects = new List<Project__c>();
        
        User serviceHeadUser = [SELECT Id FROM User WHERE Profile.Name = 'Service Head' AND IsActive = true LIMIT 1
                               ];
        
        // Detect newly CR-signed projects
        for (Project__c proj : newList) {
            Project__c oldProj = oldMap.get(proj.Id);
            if (proj.CR_Signed__c == 'Yes' && oldProj.CR_Signed__c != 'Yes' && proj.PO_Verification__c != null) {
                povIds.add(proj.PO_Verification__c);
                newlySignedProjects.add(proj);
                projectsToUpdate.add(new Project__c(Id = proj.Id, CR_Signed_Date__c = Date.today()));
            }
        }
        
        if (povIds.isEmpty()) return;
        if (!projectsToUpdate.isEmpty()) {
            update projectsToUpdate;
        }
        
        // Query Project details including PO Line Item info and Installation Date
        Map<Id, Project__c> projDetails = new Map<Id, Project__c>([
            SELECT Id, PO_Verification__c, PO_Line_Item__c,RECD_Sr_No__c ,Warranty_Start_Date__c,Warranty_End_Date__c, Installation_Complete_Date__c,
            PO_Line_Item__r.Product__c,PO_Line_Item__r.DG_KVA_Rating__c,PO_Line_Item__r.Shipping_Address__c, PO_Line_Item__r.DG_Make__c,PO_Line_Item__r.Quantity__c,PO_Line_Item__r.DG_Type__c,PO_Line_Item__r.Turbo__c
            FROM Project__c 
            WHERE Id IN :newlySignedProjects
        ]);
        
        // Query PO Verifications to get Original Deal, existing AMC Deal, and Warranty info
        Map<Id, PO_Verification__c> povMap = new Map<Id, PO_Verification__c>([
            SELECT Id, Deal__c, AMC_Deal__c, Warranty_in_Months__c 
            FROM PO_Verification__c 
            WHERE Id IN :povIds
        ]);
        
        Set<Id> originalDealIds = new Set<Id>();
        for (PO_Verification__c pov : povMap.values()) {
            if (pov.Deal__c != null) {
                originalDealIds.add(pov.Deal__c);
            }
        }
        
        if (originalDealIds.isEmpty()) return;
        
        // Dynamically query all fields for cloning
        String query = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().keySet()), ',') + 
            ' FROM Opportunity WHERE Id IN :originalDealIds';
        Map<Id, Opportunity> originalDeals = new Map<Id, Opportunity>((List<Opportunity>)Database.query(query));
        
        // Get AMC Record Type Id
        Id amcRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'AMC' LIMIT 1].Id;
        
        // Map to track which NEW AMC Deals need to be created
        Map<Id, Opportunity> povIdToNewAmcDeal = new Map<Id, Opportunity>();
        
        for (Project__c proj : projDetails.values()) {
            PO_Verification__c pov = povMap.get(proj.PO_Verification__c);
            if (pov == null || pov.Deal__c == null) continue;
            
            Opportunity originalDeal = originalDeals.get(pov.Deal__c);
            if (originalDeal == null) continue;
            
            // Only create if we don't already have an AMC Deal
            if (pov.AMC_Deal__c == null && !povIdToNewAmcDeal.containsKey(pov.Id)) {
                Opportunity amcDeal = originalDeal.clone(false, true, false, false);
                amcDeal.RecordTypeId = amcRecordTypeId;
                amcDeal.Name = (originalDeal.Name != null && originalDeal.Name.startsWith('AMC - ')) ? originalDeal.Name : 'AMC - ' + originalDeal.Name;
                amcDeal.OwnerId = serviceHeadUser.Id;
                
                // Set CloseDate: (Installation_Complete_Date__c + 1) + Warranty_in_Months__c
                Date baseDate = (proj.Installation_Complete_Date__c != null) ? proj.Installation_Complete_Date__c.addDays(-1) : Date.today();
                Integer warrantyMonths = (pov.Warranty_in_Months__c != null) ? (Integer)pov.Warranty_in_Months__c : 0;
                amcDeal.Warranty_Expiry_Date__c = baseDate.addMonths(warrantyMonths);
                
                povIdToNewAmcDeal.put(pov.Id, amcDeal);
            }
        }
        
        List<PO_Verification__c> povsToUpdate = new List<PO_Verification__c>();
        
        if (!povIdToNewAmcDeal.isEmpty()) {
            insert povIdToNewAmcDeal.values();
            
            for (Id povId : povIdToNewAmcDeal.keySet()) {
                Opportunity insertedDeal = povIdToNewAmcDeal.get(povId);
                PO_Verification__c pov = povMap.get(povId);
                
                // Link back the newly created AMC Deal to PO Verification
                pov.AMC_Deal__c = insertedDeal.Id; // Update in-memory so Asset loop works correctly
                povsToUpdate.add(new PO_Verification__c(Id = povId, AMC_Deal__c = insertedDeal.Id));
            }
            
            if (!povsToUpdate.isEmpty()) {
                update povsToUpdate;
            }
        }
        
        List<Asset__c> childAssetToInsert = new List<Asset__c>();
        
        // Get all Project Ids
        Set<Id> projectIds = new Set<Id>();
        for(Project__c proj : newlySignedProjects){
            projectIds.add(proj.Id);
        }
        
        // Find Projects that already have Assets
        Set<Id> projectsWithAssets = new Set<Id>();
        
        for(Asset__c ast : [
            SELECT Id, Project__c
            FROM Asset__c
            WHERE Project__c IN :projectIds
        ]){
            projectsWithAssets.add(ast.Project__c);
        }
        
        // Create Asset__c for each newly signed project's line item
        for (Project__c proj : projDetails.values()) {
            if(projectsWithAssets.contains(proj.Id)){
                continue;
            }
            PO_Verification__c pov = povMap.get(proj.PO_Verification__c);
            if (pov == null || pov.AMC_Deal__c == null || proj.PO_Line_Item__c == null) continue;
            
            Opportunity originalDeal = originalDeals.get(pov.Deal__c);
            if (originalDeal == null) continue;
            
            Asset__c asset = new Asset__c();
            asset.Deal__c = pov.AMC_Deal__c; // Attaches to existing OR newly created AMC Deal seamlessly
            asset.Account__c = originalDeal.AccountId; // Parent account ID available without extra SOQL
            asset.Project__c = proj.Id;
            asset.RECD_Serial_No__c = proj.RECD_Sr_No__c;
            asset.Warranty_Start_Date__c = proj.Warranty_Start_Date__c;
            asset.Warranty_End_Date__c = proj.Warranty_End_Date__c;
            asset.Shipping_Address__c = proj.PO_Line_Item__r.Shipping_Address__c;
            asset.KVA_Rating__c = proj.PO_Line_Item__r.DG_KVA_Rating__c;
            // asset.Product__c = proj.PO_Line_Item__r.Product__c;
            
            childAssetToInsert.add(asset);
        }
        
        if (!childAssetToInsert.isEmpty()) {
            insert childAssetToInsert;
        }
    }
    
    
    public static void createProjectStageHistory(
        List<Project__c> newProjects,
        Map<Id, Project__c> oldMap,
        Boolean isInsert,
        Boolean isUpdate
    ){
        List<Project_Stage__c> stagesToInsert = new List<Project_Stage__c>();
        List<Project_Stage__c> stagesToUpdate = new List<Project_Stage__c>();
        
        Set<Id> projectIds = new Set<Id>();
        for(Project__c proj : newProjects){
            projectIds.add(proj.Id);
        }
        
        // Get the LATEST stage record per project (this is Stage A)
        Map<Id, Project_Stage__c> latestStageMap = new Map<Id, Project_Stage__c>();
        for(Project_Stage__c ps : [
            SELECT Id,
            Project__c,
            Stage_Change_Date__c
            FROM Project_Stage__c
            WHERE Project__c IN :projectIds
            ORDER BY Stage_Change_Date__c DESC
        ]){
            if(!latestStageMap.containsKey(ps.Project__c)){
                latestStageMap.put(ps.Project__c, ps); // This is Stage A (previous)
            }
        }
        
        for(Project__c proj : newProjects){
            
            if(isInsert && String.isNotBlank(proj.Project_Status__c)){
                stagesToInsert.add(
                    new Project_Stage__c(
                        Name = proj.Project_Status__c,
                        Project__c = proj.Id,
                        Stage_Change_Date__c = System.now()
                    )
                );
            }
            
            if(isUpdate){
                Project__c oldProj = oldMap.get(proj.Id);
                
                if(proj.Project_Status__c != oldProj.Project_Status__c){
                    
                    // Calculate time spent from Stage A to Stage B
                    if(latestStageMap.containsKey(proj.Id)){
                        
                        Project_Stage__c previousStage = latestStageMap.get(proj.Id);
                        
                        Long timeSpentMs =
                            System.now().getTime() -
                            previousStage.Stage_Change_Date__c.getTime();
                        
                        // Store time on PREVIOUS stage
                        previousStage.Time_Spent__c =
                            formatDuration(timeSpentMs);
                        
                        stagesToUpdate.add(previousStage);
                    }
                    
                    // Create new stage record with blank Time_Spent__c
                    stagesToInsert.add(
                        new Project_Stage__c(
                            Name = proj.Project_Status__c,
                            Project__c = proj.Id,
                            Stage_Change_Date__c = System.now()
                        )
                    );
                }
            }
        }
        
        if(!stagesToUpdate.isEmpty()){
            update stagesToUpdate;
        }
        if(!stagesToInsert.isEmpty()){
            insert stagesToInsert;
        }
    }
    private static String formatDuration(Long milliseconds){
        
        Long totalMinutes = milliseconds / (1000 * 60);
        
        Long days = totalMinutes / (24 * 60);
        totalMinutes = Math.mod(totalMinutes, 24 * 60);
        
        Long hours = totalMinutes / 60;
        Long minutes = Math.mod(totalMinutes, 60);
        
        String result = '';
        
        if(days > 0){
            result += days + ' Day' + (days > 1 ? 's ' : ' ');
        }
        
        if(hours > 0){
            result += hours + ' Hour' + (hours > 1 ? 's ' : ' ');
        }
        
        if(minutes > 0){
            result += minutes + ' Minute' + (minutes > 1 ? 's' : '');
        }
        
        return result.trim();
        
    }
    
    
    
    public static void validateProjectDates(List<Project__c> projectList, Map<Id, Project__c> oldMap) {
        
        
        String profileName = [
            SELECT Name
            FROM Profile
            WHERE Id = :UserInfo.getProfileId()
        ].Name;
        
        // Skip validation for Admin and PM Head
        if(profileName == 'System Administrator' ||
            profileName == 'PM Head'){
                return;
            }
        Date minAllowedDate1 = Date.today().addDays(-20);
        Date minAllowedDate = Date.today().addDays(-4);
        Date maxAllowedDate = Date.today();
        
        // Date Fields
        List<String> dateFields = new List<String>{
            
            'Actual_P_S_Readiness_Date__c',
                'C2_Release_Date__c',
                'Design_Release_Planned_Date__c',
                'FEA_End_Date__c',
                'FEA_Start_Date__c',
                'Field_Quality_Approved_Date__c',
                'Quality_Request_Date__c',
                
                'Installation_Complete_Date__c',
                'Installation_End_Date__c',
                'Installation_Plan_End_Date__c',
                'Installation_Plan_Start_Plan_Date__c',
                'Installation_Start_Date__c',
                'Quality_Approval_Date__c',
                'Internal_Quality_P_Approval_Date__c',
                
                'NABL_Date__c',
                'Plan_RECD_mfg_completion_date__c',
                
                'Warranty_End_Date__c',
                'Warranty_Start_Date__c',
                'Actual_Material_Ready_date__c',
                
                'Cladding__c',
                'Client_Dispatch_Date__c',
                'Client_P_S_Received_Date__c',
                'Outsourced_Client_Dispatch_Date__c',
                'Client_RECD_Received_Date__c',
                'Client_Received_Date__c',
                'CR_Signed_Date__c',
                'Design_End_Date__c',
                'Design_Release__c',
                'Design_Start_Date__c',
                'Device_Dispatch_Date__c',
                'Device_Readiness_Date__c',
                'DOFF_Release__c',
                'Installation_Dispatch_Actual__c',
                'Installation_Dispatch_Plan__c',
                'P_S_Order_Date__c',
                'Plan_P_S_Readiness_Date__c',
                'PO_Date__c',
                'RECD_Dispatch_Actual__c',
                'Dispatch_Plan_Date__c',
                'RECD_Handover__c',
                'RECD_Mfg_Complete__c',
                'RECD_Mfg_Start__c',
                'Planned_Mfg_Start__c',
              //  'Site_Mapping_Advance_Received_Date__c',
               // 'Site_Mapping_Advance_request_Date__c',
              //  'Site_Mapping_Date__c',
                //'Site_Mapping_End_Date__c',
                'SR_Pack__c',
                'P_S_Dispatch_Actual__c',
                'Vendor_Project_Acceptance_Date__c'
                };
                    
                    // last 20 days validation
                    List<String> dateFields1 = new List<String>{
                        'Advance_Receipt_Date__c',
                            'Final_Payment_Date__c',
                            'Post_Dispatch_Payment_Date__c',
                            'Invoicing_Date__c'
                    };
                    
                    
                    Map<String, Schema.SObjectField> fieldMap =
                    Schema.SObjectType.Project__c.fields.getMap();
        
        for(Project__c proj : projectList){
            
            for(String fieldName : dateFields){
                
                Date fieldDate = (Date)proj.get(fieldName);
                Date oldDate = oldMap != null ? (Date)oldMap.get(proj.Id)?.get(fieldName) : null;
                
                if(fieldDate != null && fieldDate != oldDate){
                    
                    if(fieldDate < minAllowedDate ){//||fieldDate > maxAllowedDate
                        
                        String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                        
                        proj.addError(fieldName, fieldLabel + ' should be within the last 4 days.');
                        
                        break;
                    }
                }
            }
            for(String fieldName : dateFields1){
                Date fieldDate = (Date)proj.get(fieldName);
                Date oldDate = oldMap != null ? (Date)oldMap.get(proj.Id)?.get(fieldName) : null;
                
                if(fieldDate != null && fieldDate != oldDate){
                    
                    if(fieldDate < minAllowedDate1 ){//||fieldDate > maxAllowedDate
                        
                        String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                        proj.addError(fieldName, fieldLabel + ' should be within the last 20 days.');
                        break;
                    }
                }
            }
            
        }
    }
}