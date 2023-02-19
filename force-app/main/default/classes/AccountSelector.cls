/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-18-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public with sharing class AccountSelector {
    
    /**
    * @description return account by account Id
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param accountIds 
    * @return Map<Id, Account> 
    **/
    public static Map<Id, Account> getAccountsById(Set<Id> accountIds){
        return new Map<Id, Account>([SELECT Id, (SELECT Id FROM Contacts ) FROM Account WHERE Id IN : accountIds WITH SECURITY_ENFORCED]);
    }
}