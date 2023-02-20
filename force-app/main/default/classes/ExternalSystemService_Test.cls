/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Bader Eddine Elkhal
**/
@IsTest
public with sharing class ExternalSystemService_Test {
    @testSetup 
    static void prepareSetupData() {
        //Insert test User that will run tests
        User user = (User)TestDataFactory.createSObject('User', new Map<String,Object>{
            'ProfileId' => UserInfo.getProfileId(),
            'UserName'  => 'testUserEmail@test.com@EventSystem.com',
            'Email'     => 'testUserEmail@test.com',
            'Alias'     => 'tsEmail'
            });
        List<Account> accounts = [SELECT Id FROM Account LIMIT 2];
        if(accounts?.isEmpty()){
            Account account = (Account)TestDataFactory.createSObject('Account');   
        }     
    }
    @IsTest
    public static void callExternalSystemServiceSuccess(){
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        //Insert Email Template 
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = (List<Contact>)TestDataFactory.createSObjectList('Contact', new Map<String,Object>{
            'AccountId' => account.Id,
            'Email'      => 'TestContactemailS{!index}@test.com'
            }, 100);
            String jobId;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSystemServiceCalloutMock(201));
        System.runAs(user) {
            ExternalSystemService externalSysService = new ExternalSystemService(contacts);
            jobId = System.enqueueJob(externalSysService);
        }
        Test.stopTest();

        // Then
        System.assertEquals(jobId != null , true , 'Job enqueued');
    }
    @IsTest
    public static void callExternalSystemServiceFailled(){
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        //Insert Email Template 
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = (List<Contact>)TestDataFactory.createSObjectList('Contact', new Map<String,Object>{
            'AccountId' => account.Id,
            'Email'      => 'TestContactemailF{!index}@test.com'
            }, 100);
        String jobId;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSystemServiceCalloutMock(400));
        System.runAs(user) {
            ExternalSystemService externalSysService = new ExternalSystemService(contacts);
            jobId = System.enqueueJob(externalSysService);
        }
        Test.stopTest();

        // Then
        System.assertEquals(jobId != null , true , 'Job enqueued');
    }

    @IsTest
    public static void callExternalSystemServiceWithLimitCalloutExcceded(){
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        //Insert Email Template 
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = (List<Contact>)TestDataFactory.createSObjectList('Contact', new Map<String,Object>{
            'AccountId' => account.Id,
            'Email'      => 'TestContactemailSF{!index}@test.com'
            }, 200);
            String jobId;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSystemServiceCalloutMock(201));
        System.runAs(user) {
            ExternalSystemService externalSysService = new ExternalSystemService(contacts);
            jobId = System.enqueueJob(externalSysService);
        }
        Test.stopTest();
        Integer numberOfFailledCallouts = 0;
        for(LogEntry__c logEntry : [SELECT Id, Message__c FROM LogEntry__c LIMIT 200]){
            if(logEntry.Message__c.contains('Callout Limit Excceded - Failled to register and notify contact with Id')){
                numberOfFailledCallouts+= 1;
            }

        }
        // Then
        System.assertEquals(100 , numberOfFailledCallouts , '100 Failled Callout');
    }
    
}