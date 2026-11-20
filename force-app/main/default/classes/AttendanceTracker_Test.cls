@isTest
public class AttendanceTracker_Test {
	/*@testSetup
    static void setup() {
        // Create test user
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'Test',
            Email = 'test@example.com',
            Username = 'testuser@example.com.test',
            CompanyName = 'Test Company',
            Title = 'Test User',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert testUser;
    }
    */
    @isTest
    static void testGetTodaysAttendance_NoRecord() {
        User testUser = [SELECT Id FROM User WHERE Username = 'amit.aseri@chakr.in'];
        
        System.runAs(testUser) {
            Test.startTest();
            Attendance__c result = AttendanceTrackerController.getTodaysAttendance();
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetTodaysAttendance_WithRecord() {
        User testUser = [SELECT Id FROM User WHERE Username = 'amit.aseri@chakr.in'];
        
        // Create attendance record for today
        Attendance__c attendance = new Attendance__c(
            User__c = testUser.Id,
            Attendance_In__c = Datetime.now()
        );
        insert attendance;
        
        System.runAs(testUser) {
            Test.startTest();
            Attendance__c result = AttendanceTrackerController.getTodaysAttendance();
            Test.stopTest();
        }
    }
    
    @isTest
    static void testMarkAttendanceIn_Success() {
        User testUser = [SELECT Id FROM User WHERE Username = 'amit.aseri@chakr.in'];
        
        System.runAs(testUser) {
            Test.startTest();
            Attendance__c result = AttendanceTrackerController.markAttendanceIn();
            Test.stopTest();
        }
    }
    
    @isTest
    static void testMarkAttendanceIn_AlreadyExists() {
        User testUser = [SELECT Id FROM User WHERE Username = 'amit.aseri@chakr.in'];
        
        // Create attendance record for today
        Attendance__c attendance = new Attendance__c(
            User__c = testUser.Id,
            Attendance_In__c = Datetime.now()
        );
        insert attendance;
        
        System.runAs(testUser) {
            Test.startTest();
            try {
                AttendanceTrackerController.markAttendanceIn();
            } catch (AuraHandledException e) {
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testMarkAttendanceOut_Success() {
        User testUser = [SELECT Id FROM User WHERE Username = 'amit.aseri@chakr.in'];
        
        // Create attendance record for today
        Attendance__c attendance = new Attendance__c(
            User__c = testUser.Id,
            Attendance_In__c = Datetime.now()
        );
        insert attendance;
        
        System.runAs(testUser) {
            Test.startTest();
            Attendance__c result = AttendanceTrackerController.markAttendanceOut();
            Test.stopTest();
        }
    }
    
    @isTest
    static void testMarkAttendanceOut_NoRecord() {
        User testUser = [SELECT Id FROM User WHERE Username = 'amit.aseri@chakr.in'];
        
        System.runAs(testUser) {
            Test.startTest();
            try {
                AttendanceTrackerController.markAttendanceOut();
            } catch (AuraHandledException e) {
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetAttendanceHistory() {
        User testUser = [SELECT Id FROM User WHERE Username = 'amit.aseri@chakr.in'];
        
        // Create multiple attendance records
        List<Attendance__c> attendanceList = new List<Attendance__c>();
        for (Integer i = 0; i < 5; i++) {
            attendanceList.add(new Attendance__c(
                User__c = testUser.Id,
                Attendance_In__c = Datetime.now().addDays(-i),
                Attendance_Out__c = Datetime.now().addDays(-i).addHours(8)
            ));
        }
        insert attendanceList;
        
        System.runAs(testUser) {
            Test.startTest();
            List<Attendance__c> result = AttendanceTrackerController.getAttendanceHistory(3);
            Test.stopTest();
        }
    }
}