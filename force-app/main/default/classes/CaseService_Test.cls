/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-19-2023
 * @last modified by  : Bader Eddine Elkhal
**/
@IsTest
public with sharing class CaseService_Test {

    public static final String CASE_ORIGIN_WEB    = 'Web';
    public static final String CASE_ORIGIN_PHONE  = 'Phone';
    public static final String CASE_ORIGIN_EMAIL  = 'Email';
    public static final String CASE_STATUS_NEW    = 'New';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    
    @testSetup 
    static void prepareSetupData() {
        //Insert test User that will run tests
        User u = (User)TestDataFactory.createSObject('User', new Map<String,Object>{
            'ProfileId' => UserInfo.getProfileId(),
            'UserName'  => 'testUserCS@test.com@EventSystem.com',
            'Email'     => 'testUserCS@test.com',
            'Alias'     => 'tsCS'
            });
        List<Account> accounts = [SELECT Id FROM Account LIMIT 2];
        if(accounts?.isEmpty()){
            Account account = (Account)TestDataFactory.createSObject('Account');   
        }

    }
    @IsTest
    public static void caseValidationOnBeforeInsertSuccess(){
       
        Account account = [SELECT Id FROM Account LIMIT 1];
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        List<Case> insertedCases;
        System.runAs(user) {
            BusinessHours businessHrs = [SELECT Id FROM BusinessHours LIMIT 1];
            insertedCases = TestDataFactory.createSObjectList('Case', new Map<String,Object>{
                'AccountId' => account.Id,
                'Origin'    => CASE_ORIGIN_EMAIL,
                'Status'    => CASE_STATUS_NEW,
                'businesshoursId'    => businessHrs.Id
              },100);            
        }
        Test.stopTest();

        // Then
        System.assertEquals(insertedCases.size(), 100, 'Number of Inserted case is 100');
    }
    @IsTest
    public static void failedCaseInsertionAccountIdMissing(){
       
        Account account = [SELECT Id FROM Account LIMIT 1];
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        List<Case> insertedCases;
        String errorMessage;
        System.runAs(user) {
            BusinessHours businessHrs = [SELECT Id FROM BusinessHours LIMIT 1];
            try{
                insertedCases = TestDataFactory.createSObjectList('Case', new Map<String,Object>{
                'AccountId' => null,
                'Origin'    => CASE_ORIGIN_EMAIL,
                'Status'    => CASE_STATUS_NEW,
                'businesshoursId'    => businessHrs.Id
              },100);  
            }catch(Exception e){
                errorMessage = e.getMessage();
            }
                      
        }
        Test.stopTest();

        // Then
        System.assertEquals(errorMessage.contains('You cannot create a request without attaching an account'), true, 'error handling when Account Id missed');
    }
    @IsTest
    public static void failedCaseInsertionWhenOriginWeb(){
       
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> insertedContacts = (List<Contact>)TestDataFactory.createSObjectList('Contact', new Map<String,Object>{
            'AccountId' => account.Id
          }, 2);
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        List<Case> insertedCases;
        String errorMessage;
        System.runAs(user) {
            BusinessHours businessHrs = [SELECT Id FROM BusinessHours LIMIT 1];
            try{
                insertedCases = TestDataFactory.createSObjectList('Case', new Map<String,Object>{
                'AccountId' => account.Id,
                'Origin'    => CASE_ORIGIN_WEB,
                'Status'    => CASE_STATUS_NEW,
                'businesshoursId'    => businessHrs.Id
              },100);  
            }catch(Exception e){
                errorMessage = e.getMessage();
            }
                      
        }
        Test.stopTest();

        // Then
        System.assertEquals(errorMessage.contains('Web request are only allowed to have one attendee'), true, 'error handling when number of attendee greather than 1 and case origin is web');
    }
    @IsTest
    public static void failedCaseInsertionWhenOriginPhone(){
       
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> insertedContacts = (List<Contact>)TestDataFactory.createSObjectList('Contact', new Map<String,Object>{
            'AccountId' => account.Id
          }, 4);
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        List<Case> insertedCases;
        String errorMessage;
        System.runAs(user) {
            BusinessHours businessHrs = [SELECT Id FROM BusinessHours LIMIT 1];
            try{
                insertedCases = TestDataFactory.createSObjectList('Case', new Map<String,Object>{
                'AccountId' => account.Id,
                'Origin'    => CASE_ORIGIN_PHONE,
                'Status'    => CASE_STATUS_NEW,
                'businesshoursId'    => businessHrs.Id
              },100);  
            }catch(Exception e){
                errorMessage = e.getMessage();
            }
                      
        }
        Test.stopTest();

        // Then
        System.assertEquals(errorMessage.contains('Phone request are only allowed to have three attendee'), true, 'error handling when number of attendee greather than 3 and case origin is Phone');
    }
    @IsTest
    public static void closeCasesToRegisterAttendee(){
       
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> insertedContacts = (List<Contact>)TestDataFactory.createSObjectList('Contact', new Map<String,Object>{
            'AccountId' => account.Id
          }, 4);
        BusinessHours businessHrs = [SELECT Id FROM BusinessHours LIMIT 1];
        List<Case> insertedCases = TestDataFactory.createSObjectList('Case', new Map<String,Object>{
            'AccountId' => account.Id,
            'Origin'    => CASE_ORIGIN_EMAIL,
            'Status'    => CASE_STATUS_NEW,
            'businesshoursId'    => businessHrs.Id
            },100);
        for(Case caseToUpdate : insertedCases){
            caseToUpdate.Status = CASE_STATUS_CLOSED;
        }
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        
        System.runAs(user) {
            Database.SaveResult[] dbSaveResults = Database.update(insertedCases, true);
        }
        Test.stopTest();
        List<Case> closedCases = [SELECT Id FROM Case WHERE Status = : CASE_STATUS_CLOSED];
        // Then
        System.assertEquals(insertedCases.size(), 100, 'Number of Inserted cases is 100');
        System.assertEquals(closedCases.size(), 100, 'Number of closed cases is 100');
    }
    @IsTest
    public static void updateCasesWithoutContacts(){
       
        Account account = [SELECT Id FROM Account LIMIT 1];
        BusinessHours businessHrs = [SELECT Id FROM BusinessHours LIMIT 1];
        List<Case> insertedCases = TestDataFactory.createSObjectList('Case', new Map<String,Object>{
            'AccountId'       => null,
            'Origin'          => CASE_ORIGIN_EMAIL,
            'Status'          => CASE_STATUS_NEW,
            'businesshoursId' => businessHrs.Id
            },100);
        for(Case caseToUpdate : insertedCases){
            caseToUpdate.AccountId = account.Id;
        }
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        
        System.runAs(user) {
            Database.SaveResult[] dbSaveResults = Database.update(insertedCases, true);
        }
        Test.stopTest();
        List<Case> updatedCases = [SELECT Id FROM Case WHERE AccountId = : account.Id];
        // Then
        System.assertEquals(updatedCases.size(), 100, 'Number of updated cases is 100');
    }
}