public class changeOwnerApexController {
    @AuraEnabled
    public static List<User> getActiveUsers() {
        try {
            return [
                SELECT Id, Name, Email, Profile.Name 
                FROM User 
                WHERE IsActive = true 
                ORDER BY Name 
                LIMIT 200
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving active users: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> updateOpportunityOwner(Id opportunityId, Id newOwnerId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Validate inputs
            if (opportunityId == null) {
                result.put('success', false);
                result.put('message', 'Account ID is required.');
                return result;
            }
            
            if (newOwnerId == null) {
                result.put('success', false);
                result.put('message', 'New owner ID is required.');
                return result;
            }
            
            // Verify the opportunity exists
            List<Account> opportunities = [
                SELECT Id, Name, OwnerId 
                FROM Account 
                WHERE Id = :opportunityId 
                LIMIT 1
            ];
            
            if (opportunities.isEmpty()) {
                result.put('success', false);
                result.put('message', 'Account not found.');
                return result;
            }
            
            // Verify the new owner exists and is active
            List<User> users = [
                SELECT Id, Name, IsActive 
                FROM User 
                WHERE Id = :newOwnerId 
                LIMIT 1
            ];
            
            if (users.isEmpty()) {
                result.put('success', false);
                result.put('message', 'Selected user not found.');
                return result;
            }
            
            if (!users[0].IsActive) {
                result.put('success', false);
                result.put('message', 'Selected user is not active.');
                return result;
            }
            
            // Update the opportunity owner
            Account opp = opportunities[0];
            opp.OwnerId = newOwnerId;
            
            update opp;
            
            result.put('success', true);
            result.put('message', 'Account owner updated successfully to ' + users[0].Name);
            
        } catch (DmlException e) {
            result.put('success', false);
            result.put('message', 'Database error: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Unexpected error: ' + e.getMessage());
        }
        
        return result;
    }
}