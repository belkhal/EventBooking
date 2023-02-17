/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public with sharing class ContactSelector {
    
    /**
    * @description return list of contact for giving accounts
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param accountIds 
    * @return List<Contact> 
    **/
    public static List<Contact> getContactsByAccount(Set<String> accountIds){
        return [SELECT Id, Name, Email, AccountId FROM Contact WHERE AccountId IN : accountIds WITH SECURITY_ENFORCED]; 
    }
}