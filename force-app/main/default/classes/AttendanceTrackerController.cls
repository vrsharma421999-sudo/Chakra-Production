public class AttendanceTrackerController {
	@AuraEnabled
    public static Attendance__c getTodaysAttendance() {
        try {
            Id currentUserId = UserInfo.getUserId();
            Date today = Date.today();
            
            List<Attendance__c> attendanceList = [
                SELECT Id, User__c, Attendance_In__c, Attendance_Out__c 
                FROM Attendance__c 
                WHERE User__c = :currentUserId 
                AND DAY_ONLY(Attendance_In__c) = :today
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (attendanceList.size() > 0) {
                return attendanceList[0];
            } else {
                return new Attendance__c();
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving attendance: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Attendance__c markAttendanceIn() {
        try {
            Id currentUserId = UserInfo.getUserId();
            Date today = Date.today();
            
            // Check if attendance already exists for today
            List<Attendance__c> existingAttendance = [
                SELECT Id, User__c, Attendance_In__c, Attendance_Out__c 
                FROM Attendance__c 
                WHERE User__c = :currentUserId 
                AND DAY_ONLY(Attendance_In__c) = :today
                LIMIT 1
            ];
            
            if (existingAttendance.size() > 0) {
                throw new AuraHandledException('Attendance In already marked for today');
            }
            
            // Create new attendance record
            Attendance__c newAttendance = new Attendance__c();
            newAttendance.User__c = currentUserId;
            newAttendance.Attendance_In__c = Datetime.now();
            
            insert newAttendance;
            
            // Return the newly created record
            return [
                SELECT Id, User__c, Attendance_In__c, Attendance_Out__c 
                FROM Attendance__c 
                WHERE Id = :newAttendance.Id
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error marking attendance in: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Attendance__c markAttendanceOut() {
        try {
            Id currentUserId = UserInfo.getUserId();
            Date today = Date.today();
            
            // Find today's attendance record
            List<Attendance__c> attendanceList = [
                SELECT Id, User__c, Attendance_In__c, Attendance_Out__c 
                FROM Attendance__c 
                WHERE User__c = :currentUserId 
                AND DAY_ONLY(Attendance_In__c) = :today
                AND Attendance_Out__c = null
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (attendanceList.size() == 0) {
                throw new AuraHandledException('No attendance in record found for today or attendance out already marked');
            }
            
            // Update attendance record with out time
            Attendance__c attendanceRecord = attendanceList[0];
            attendanceRecord.Attendance_Out__c = Datetime.now();
            
            update attendanceRecord;
            
            // Return the updated record
            return [
                SELECT Id, User__c, Attendance_In__c, Attendance_Out__c 
                FROM Attendance__c 
                WHERE Id = :attendanceRecord.Id
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error marking attendance out: ' + e.getMessage());
        }
    }
    
    // Method to get attendance history (optional - for future enhancement)
    @AuraEnabled
    public static List<Attendance__c> getAttendanceHistory(Integer limitRecords) {
        try {
            Id currentUserId = UserInfo.getUserId();
            
            if (limitRecords == null || limitRecords <= 0) {
                limitRecords = 10;
            }
            
            return [
                SELECT Id, User__c, Attendance_In__c, Attendance_Out__c, CreatedDate
                FROM Attendance__c 
                WHERE User__c = :currentUserId 
                ORDER BY Attendance_In__c DESC
                LIMIT :limitRecords
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving attendance history: ' + e.getMessage());
        }
    }
}