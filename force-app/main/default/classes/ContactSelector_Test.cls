/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-18-2023
 * @last modified by  : Bader Eddine Elkhal
**/
@IsTest
public with sharing class ContactSelector_Test {
    @testSetup 
    static void prepareSetupData() {
        //Insert test User that will run tests
        User u = (User)TestDataFactory.createSObject('User', new Map<String,Object>{
            'ProfileId' => UserInfo.getProfileId(),
            'UserName'  => 'testUserCon@test.com@EventSystem.com',
            'Email'     => 'testUserCon@test.com',
            'Alias'     => 'tsCon'
            });    

    }
    @IsTest
    public static void returnContactsWhenAccountIdsProvided(){
        Account account = (Account)TestDataFactory.createSObject('Account');
        List<Contact> insertedContacts = (List<Contact>)TestDataFactory.createSObjectList('Contact', new Map<String,Object>{
            'AccountId' => account.Id
          }, 200);
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        List<Contact> contacts;
        System.runAs(user) {
            contacts = ContactSelector.getContactsByAccount(new set<Id>{account.Id});            
        }
        Test.stopTest();

        // Then
        System.assertEquals(contacts.size(), 200, 'Number of returned Contacts is 200');
    }

    @IsTest
    public static void returnEmptyListOfContacts(){
        
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        List<Contact> contacts = new List<Contact>();
        System.runAs(user) {
            contacts = ContactSelector.getContactsByAccount(new Set<Id>());            
        }
        Test.stopTest();

        // Then
        System.assertEquals(contacts.size(), 0, 'No Contact Record found');
    }
}