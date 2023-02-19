/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-18-2023
 * @last modified by  : Bader Eddine Elkhal
**/
@IsTest
public with sharing class AccountSelector_Test {

    @testSetup 
    static void prepareSetupData() {
        //Insert test User that will run tests
        User u = (User)TestDataFactory.createSObject('User', new Map<String,Object>{
            'ProfileId' => UserInfo.getProfileId(),
            'UserName'  => 'testUserAcc@test.com@EventSystem.com',
            'Email'     => 'testUserAcc@test.com',
            'Alias'     => 'tUAcc'
            });    

    }
    @IsTest
    public static void returnListOfAccountWhenIdsProvided(){
        List<Account> accounts = (List<Account>)TestDataFactory.createSObjectList('Account', 200);
        Set<Id> accountIds = new Set<Id>();
        for(Account account : accounts){
            accountIds.add(account.Id);
        }
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        Map<Id, Account> returnedAccountsMap;
        System.runAs(user) {
            returnedAccountsMap = AccountSelector.getAccountsById(accountIds);            
        }
        Test.stopTest();

        // Then
        System.assertEquals(returnedAccountsMap.values().size(), 200, 'Number of returned accounts is 200');
    }

    @IsTest
    public static void returnEmptyListOfAccounts(){
        
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        Map<Id, Account> returnedAccountsMap = new Map<Id, Account> ();
        System.runAs(user) {
            returnedAccountsMap = AccountSelector.getAccountsById(new Set<Id>());            
        }
        Test.stopTest();

        // Then
        System.assertEquals(returnedAccountsMap.values().size(), 0, 'No Account Record found');
    }

    
}