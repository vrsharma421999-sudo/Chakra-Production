@isTest
public class ProjectTriggerHandler_Test {

    // ─────────────────────────────────────────
    // DATA SETUP
    // ─────────────────────────────────────────

    @testSetup
    static void setupData() {

        // ── 1. Create Service Head Profile User ──
        Profile serviceHeadProfile = [
            SELECT Id FROM Profile WHERE Name = 'Service Head' LIMIT 1
        ];
        User serviceHeadUser = new User(
            FirstName          = 'Service',
            LastName           = 'Head',
            Email              = 'servicehead_test@testorg.com',
            Username           = 'servicehead_test_' + DateTime.now().getTime() + '@testorg.com',
            Alias              = 'svchead',
            ProfileId          = serviceHeadProfile.Id,
            TimeZoneSidKey     = 'America/Los_Angeles',
            LocaleSidKey       = 'en_US',
            EmailEncodingKey   = 'UTF-8',
            LanguageLocaleKey  = 'en_US',
            IsActive           = true
        );
        insert serviceHeadUser;

        // ── 2. Create PM Head Profile User ──
        List<Profile> pmProfiles = [SELECT Id FROM Profile WHERE Name = 'PM Head' LIMIT 1];
        if (!pmProfiles.isEmpty()) {
            User pmHeadUser = new User(
                FirstName          = 'PM',
                LastName           = 'HeadUser',
                Email              = 'pmhead_test@testorg.com',
                Username           = 'pmhead_test_' + DateTime.now().getTime() + '@testorg.com',
                Alias              = 'pmhead',
                ProfileId          = pmProfiles[0].Id,
                TimeZoneSidKey     = 'America/Los_Angeles',
                LocaleSidKey       = 'en_US',
                EmailEncodingKey   = 'UTF-8',
                LanguageLocaleKey  = 'en_US',
                IsActive           = true
            );
            insert pmHeadUser;
        }

        // ── 3. Create Standard User ──
        Profile standardProfile = [
            SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1
        ];
        User standardUser = new User(
            FirstName          = 'Standard',
            LastName           = 'Tester',
            Email              = 'stduser_test@testorg.com',
            Username           = 'stduser_test_' + DateTime.now().getTime() + '@testorg.com',
            Alias              = 'stdtest',
            ProfileId          = standardProfile.Id,
            TimeZoneSidKey     = 'America/Los_Angeles',
            LocaleSidKey       = 'en_US',
            EmailEncodingKey   = 'UTF-8',
            LanguageLocaleKey  = 'en_US',
            IsActive           = true
        );
        insert standardUser;

        // ── 4. Core test data ──
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name      = 'Test Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert opp;

        PO_Verification__c pov = new PO_Verification__c(
            Deal__c               = opp.Id,
            BP_Code__c            = 'TESTBP01',
            Warranty_in_Months__c = 12
        );
        insert pov;

        Product2 prod = new Product2(Name = 'Generator', IsActive = true);
        insert prod;

        PO_Line_Item__c li = new PO_Line_Item__c(
            Product__c          = prod.Id,
            PO_Verification__c  = pov.Id,
            DG_KVA_Rating__c    = 100,
            Shipping_Address__c = 'Delhi',
            Quantity__c         = 1
        );
        insert li;
    }

    // ─────────────────────────────────────────
    // HELPERS
    // ─────────────────────────────────────────

    static Account getAccount()            { return [SELECT Id FROM Account LIMIT 1]; }
    static Opportunity getOpp()            { return [SELECT Id, AccountId FROM Opportunity LIMIT 1]; }
    static PO_Verification__c getPOV()     { return [SELECT Id, Deal__c, AMC_Deal__c, Warranty_in_Months__c FROM PO_Verification__c LIMIT 1]; }
    static PO_Line_Item__c getLI()         { return [SELECT Id FROM PO_Line_Item__c LIMIT 1]; }
    static User getStandardUser()          { return [SELECT Id FROM User WHERE LastName = 'Tester' AND IsActive = true LIMIT 1]; }
    static User getPMHeadUser()            { return [SELECT Id FROM User WHERE LastName = 'HeadUser' AND IsActive = true LIMIT 1]; }

    static Project__c makeProjectWithFormulas(Id idValue, String mfgClearance, String preDispatch, String afterDelivery, String status, String paymentStatus) {
        Map<String, Object> fieldMap = new Map<String, Object>{
            'sobjectType' => 'Project__c',
            'Mfg_Clearance_From_Finance__c' => mfgClearance,
            'Pre_Dispatch_Clearance_Finance__c' => preDispatch,
            'After_Delivery_Installation_Go_Ahead__c' => afterDelivery,
            'Project_Status__c' => status,
            'Final_Payment_Status__c' => paymentStatus
        };
        if (idValue != null) {
            fieldMap.put('Id', idValue);
        }
        return (Project__c)JSON.deserialize(JSON.serialize(fieldMap), Project__c.class);
    }

    // ─────────────────────────────────────────
    // TEST 1 — changeStatus: all branches & continues
    // ─────────────────────────────────────────
    @isTest
    static void testChangeStatus_AllBranches() {
        Project__c p1 = makeProjectWithFormulas(null, null, 'Yes', 'Yes', null, null);
        Project__c p2 = makeProjectWithFormulas(null, 'Yes', null, 'Yes', null, null);
        Project__c p3 = makeProjectWithFormulas(null, 'Yes', 'Yes', null, null, null);
        Project__c p4 = makeProjectWithFormulas(null, 'Yes', 'Yes', 'Yes', null, null);

        List<Project__c> lst = new List<Project__c>{ p1, p2, p3, p4 };

        Test.startTest();
        ProjectTriggerHandler.changeStatus(lst);
        Test.stopTest();

        System.assertEquals('Installation Team', p4.Project_Status__c);
    }

    // ─────────────────────────────────────────
    // TEST 2 — changeStatusUpdate: Direct Handler Execution (100% Branch Coverage)
    // ─────────────────────────────────────────
    @isTest
    static void testChangeStatusUpdate_Direct() {
        Id fakeId1 = 'a0CVG0000000001AAA';
        Id fakeId2 = 'a0CVG0000000002AAA';

        Project__c old1 = makeProjectWithFormulas(fakeId1, 'No', 'No', 'No', 'SM_team', null);
        old1.Manufacturing_Location__c = 'In-House';
        old1.Project_Execution_Status__c = 'LIVE';

        Project__c new1 = makeProjectWithFormulas(fakeId1, 'Yes', 'Yes', 'Yes', 'SM_team', 'Received');
        new1.Manufacturing_Location__c = 'Vendor';
        new1.Project_Execution_Status__c = 'CANCELLED';

        Project__c old2 = makeProjectWithFormulas(fakeId2, null, 'Yes', 'Yes', 'SM_team', null);
        Project__c new2 = makeProjectWithFormulas(fakeId2, null, 'Yes', 'Yes', 'SM_team', null);

        List<Project__c> newList = new List<Project__c>{ new1, new2 };
        Map<Id, Project__c> oldMap = new Map<Id, Project__c>{ fakeId1 => old1, fakeId2 => old2 };

        Test.startTest();
        ProjectTriggerHandler.changeStatusUpdate(newList, oldMap);
        Test.stopTest();

        System.assertEquals('Not Applicable', new1.Design_Release_Stage__c);
        System.assertEquals(Date.today(), new1.Execution_Cancel_Date__c);
        System.assertEquals('Final Payment', new1.Project_Status__c);
    }

    // ─────────────────────────────────────────
    // TEST 3 — handleCRSignOf: Full Happy Path (AMC Deal & Asset creation)
    // ─────────────────────────────────────────
    @isTest
    static void testHandleCRSignOf_FullPath() {
        PO_Verification__c pov = getPOV();
        PO_Line_Item__c li     = getLI();

        Project__c proj = new Project__c(
            Name                          = 'CR Sign Happy Path',
            CR_Signed__c                  = 'No',
            PO_Verification__c            = pov.Id,
            PO_Line_Item__c               = li.Id,
            Installation_Complete_Date__c = Date.today(),
            RECD_Sr_No__c                 = 'SER-HAPPY-001'
        );
        insert proj;

        Project__c oldProj = proj.clone(true, true, false, false);
        proj.CR_Signed__c  = 'Yes';

        Test.startTest();
        ProjectTriggerHandler.handleCRSignOf(
            new List<Project__c>{ proj },
            new Map<Id, Project__c>{ proj.Id => oldProj }
        );
        Test.stopTest();
    }

    // ─────────────────────────────────────────
    // TEST 4 — handleCRSignOf: Null Installation Date & Null Warranty Months
    // ─────────────────────────────────────────
    @isTest
    static void testHandleCRSignOf_NullInstallationDateAndWarranty() {
        Opportunity opp = getOpp();
        PO_Verification__c pov = new PO_Verification__c(
            Deal__c               = opp.Id,
            BP_Code__c            = 'TESTBP02',
            Warranty_in_Months__c = null
        );
        insert pov;

        PO_Line_Item__c li = new PO_Line_Item__c(
            Product__c          = [SELECT Id FROM Product2 LIMIT 1].Id,
            PO_Verification__c  = pov.Id,
            Quantity__c         = 1
        );
        insert li;

        Project__c proj = new Project__c(
            Name               = 'Null Installation Date Proj',
            CR_Signed__c       = 'No',
            PO_Verification__c = pov.Id,
            PO_Line_Item__c    = li.Id
        );
        insert proj;

        Project__c oldProj = proj.clone(true, true, false, false);
        proj.CR_Signed__c  = 'Yes';

        Test.startTest();
        ProjectTriggerHandler.handleCRSignOf(
            new List<Project__c>{ proj },
            new Map<Id, Project__c>{ proj.Id => oldProj }
        );
        Test.stopTest();
    }

    // ─────────────────────────────────────────
    // TEST 5 — handleCRSignOf: AMC Deal already exists & Asset already exists
    // ─────────────────────────────────────────
    @isTest
    static void testHandleCRSignOf_AMCAndAssetExist() {
        PO_Verification__c pov = getPOV();
        PO_Line_Item__c li     = getLI();
        Opportunity opp        = getOpp();

        Opportunity amcDeal = new Opportunity(
            Name      = 'AMC - Test Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = opp.AccountId
        );
        insert amcDeal;

        pov.AMC_Deal__c = amcDeal.Id;
        update pov;

        Project__c proj = new Project__c(
            Name                          = 'AMC & Asset Exist Proj',
            CR_Signed__c                  = 'No',
            PO_Verification__c            = pov.Id,
            PO_Line_Item__c               = li.Id,
            Installation_Complete_Date__c = Date.today()
        );
        insert proj;

        insert new Asset__c(
            Project__c = proj.Id,
            Deal__c    = amcDeal.Id,
            Account__c = opp.AccountId
        );

        Project__c oldProj = proj.clone(true, true, false, false);
        proj.CR_Signed__c  = 'Yes';

        Test.startTest();
        ProjectTriggerHandler.handleCRSignOf(
            new List<Project__c>{ proj },
            new Map<Id, Project__c>{ proj.Id => oldProj }
        );
        Test.stopTest();
    }

    // ─────────────────────────────────────────
    // TEST 6 — handleCRSignOf: Early return cases (CR_Signed unchanged / pov.Deal__c is null)
    // ─────────────────────────────────────────
    @isTest
    static void testHandleCRSignOf_EarlyReturns() {
        PO_Verification__c pov = getPOV();
        PO_Line_Item__c li     = getLI();

        Project__c proj = new Project__c(
            Name               = 'No Change Proj',
            CR_Signed__c       = 'No',
            PO_Verification__c = pov.Id,
            PO_Line_Item__c    = li.Id
        );
        insert proj;

        Project__c oldProj = proj.clone(true, true, false, false);

        ProjectTriggerHandler.handleCRSignOf(
            new List<Project__c>{ proj },
            new Map<Id, Project__c>{ proj.Id => oldProj }
        );

        PO_Verification__c povNoDeal = new PO_Verification__c(BP_Code__c = 'NODEAL');
        insert povNoDeal;

        Project__c projNoDeal = new Project__c(
            Name               = 'No Deal Proj',
            CR_Signed__c       = 'No',
            PO_Verification__c = povNoDeal.Id
        );
        insert projNoDeal;

        Project__c oldProjNoDeal = projNoDeal.clone(true, true, false, false);
        projNoDeal.CR_Signed__c  = 'Yes';

        Test.startTest();
        ProjectTriggerHandler.handleCRSignOf(
            new List<Project__c>{ projNoDeal },
            new Map<Id, Project__c>{ projNoDeal.Id => oldProjNoDeal }
        );
        Test.stopTest();
    }

    // ─────────────────────────────────────────
    // TEST 7 — createProjectStageHistory: Insert, Update, Time Calculation & Duration Formatting
    // ─────────────────────────────────────────
    @isTest
    static void testStageHistory_InsertUpdateAndDuration() {
        PO_Verification__c pov = getPOV();
        PO_Line_Item__c li     = getLI();

        Project__c proj = new Project__c(
            Name               = 'Stage History Test',
            PO_Verification__c = pov.Id,
            PO_Line_Item__c    = li.Id
        );
        insert proj;

        // Update all created stage records to 2 days ago so duration is non-zero
        List<Project_Stage__c> stages = [SELECT Id FROM Project_Stage__c WHERE Project__c = :proj.Id];
        for (Project_Stage__c s : stages) {
            s.Stage_Change_Date__c = DateTime.now().addDays(-2).addHours(-3).addMinutes(-15);
        }
        if (!stages.isEmpty()) {
            update stages;
        } else {
            Project_Stage__c s1 = new Project_Stage__c(
                Name                 = 'Finance Team',
                Project__c           = proj.Id,
                Stage_Change_Date__c = DateTime.now().addDays(-2).addHours(-3).addMinutes(-15)
            );
            insert s1;
        }

        Project__c oldProj = proj.clone(true, true, false, false);
        oldProj.Project_Status__c = 'Finance Team';
        proj.Project_Status__c    = 'SM_team';

        Test.startTest();
        ProjectTriggerHandler.createProjectStageHistory(
            new List<Project__c>{ proj },
            new Map<Id, Project__c>{ proj.Id => oldProj },
            false,
            true
        );
        Test.stopTest();

        Project_Stage__c updatedStage = [SELECT Time_Spent__c FROM Project_Stage__c WHERE Project__c = :proj.Id LIMIT 1];
        System.assert(String.isNotBlank(updatedStage.Time_Spent__c), 'Time_Spent__c should be calculated and formatted');
    }

    // ─────────────────────────────────────────
    // TEST 8 — validateProjectDates: Admin Bypass & PM Head Bypass
    // ─────────────────────────────────────────
    @isTest
    static void testValidateDates_ProfileBypasses() {
        PO_Verification__c pov = getPOV();
        PO_Line_Item__c li     = getLI();

        Project__c proj = new Project__c(
            Name               = 'Bypass Test',
            PO_Verification__c = pov.Id,
            PO_Line_Item__c    = li.Id
        );
        insert proj;

        Project__c oldProj = proj.clone(true, true, false, false);
        proj.Actual_P_S_Readiness_Date__c = Date.today().addDays(-10);

        Test.startTest();
        // Admin user call
        ProjectTriggerHandler.validateProjectDates(
            new List<Project__c>{ proj },
            new Map<Id, Project__c>{ proj.Id => oldProj }
        );

        User pmHead = getPMHeadUser();
        if (pmHead != null) {
            System.runAs(pmHead) {
                ProjectTriggerHandler.validateProjectDates(
                    new List<Project__c>{ proj },
                    new Map<Id, Project__c>{ proj.Id => oldProj }
                );
            }
        }
        Test.stopTest();
    }

    // ─────────────────────────────────────────
    // TEST 9 — validateProjectDates: Standard User Valid & Invalid Date Validations
    // ─────────────────────────────────────────
    @isTest
    static void testValidateDates_StandardUserValidation() {
        PO_Verification__c pov = getPOV();
        PO_Line_Item__c li     = getLI();

        Project__c proj = new Project__c(
            Name               = 'Standard Validation Test',
            PO_Verification__c = pov.Id,
            PO_Line_Item__c    = li.Id
        );
        insert proj;

        Project__c oldProj = proj.clone(true, true, false, false);

        Test.startTest();
        System.runAs(getStandardUser()) {
            proj.Actual_P_S_Readiness_Date__c = Date.today();
            proj.Invoicing_Date__c             = Date.today().addDays(-1);
            ProjectTriggerHandler.validateProjectDates(
                new List<Project__c>{ proj },
                new Map<Id, Project__c>{ proj.Id => oldProj }
            );

            proj.Actual_P_S_Readiness_Date__c = Date.today().addDays(-10);
            ProjectTriggerHandler.validateProjectDates(
                new List<Project__c>{ proj },
                new Map<Id, Project__c>{ proj.Id => oldProj }
            );

            proj.Actual_P_S_Readiness_Date__c = null;
            proj.Invoicing_Date__c             = Date.today().addDays(-30);
            ProjectTriggerHandler.validateProjectDates(
                new List<Project__c>{ proj },
                new Map<Id, Project__c>{ proj.Id => oldProj }
            );
        }
        Test.stopTest();
    }
}