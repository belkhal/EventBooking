/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public with sharing class CaseService {
    /**
    * @description method that check the validation of list of cases data and add an error to the sepecific field if a rule was broken
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param case 
    **/
    public static void validateCases(List<Case> cases){
        Logger.debug('$$ CaseService - validateCases Start');
        //get AccountIds
        Set<Id> accountIds = getCaseAccountIds(cases);
        //get list of account with contacts associated to cases
        Map<Id, Account> accountByIdMap = AccountSelector.getAccountsById(accountIds);
        for(Case caseRecord : cases){
            //add error to case not linked to any account
            if(caseRecord.AccountId == null){
                caseRecord.AccountId.addError('You cannot create a request without attaching an account');
            }
            else{
                Integer numberOfContact = accountByIdMap.containsKey(caseRecord.AccountId) ? accountByIdMap.get(caseRecord.AccountId).Contacts.size() : 0;
                //add error to case when no contact associated to the account related to case record
                if(numberOfContact == 0){
                    caseRecord.Origin.addError('You cannot create a request for accounts without contacts');
                }
                //add error to case when the origin is web-reservation and the number of attendees greather than 1
                else if(numberOfContact > 1 && caseRecord.Origin.equalsIgnoreCase(Constants.CASE_ORIGIN_WEB)){
                    caseRecord.Origin.addError('Web request are only allowed to have one attendee');
                }
                //add error to case when the origin is phone-reservation and the number of attendee greather than 3
                else if(numberOfContact > 3 && caseRecord.Origin.equalsIgnoreCase(Constants.CASE_ORIGIN_PHONE)){
                    caseRecord.Origin.addError('Phone request are only allowed to have three attendee');
                }
            }      
        }
    }
    /**
    * @description return a set of accountIds for a giving list of cases
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param cases 
    * @return Set<Id> 
    **/
    public static Set<Id> getCaseAccountIds(List<Case> cases){
        Set<Id> accountIds = new Set<Id>();
        for(Case caseToProcess : cases){
            if(caseToProcess.AccountId != null){
                accountIds.add(caseToProcess.AccountId);
            }
        }
        return accountIds;
    }
    /**
    * @description method that call ExternalSystemService and enqueueJob to process attendee registration
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param cases 
    * @param accountIds 
    **/
    public static void registerAttendees(List<Case> cases){
        List<Case> closedCases = new List<Case>();
        Set<Id> accountIds;
        List<Contact> contacts;
        for(Case caseRecord : cases){
            if(caseRecord.Status.equalsIgnoreCase(Constants.CASE_STATUS_CLOSED)){
                closedCases.add(caseRecord);
            }
        }
        if(closedCases.isEmpty()){
            return;
        }
        //get AccountIds by cases
        accountIds = getCaseAccountIds(closedCases);
        contacts = ContactSelector.getContactsByAccount(accountIds);
        // call ExternalSystemService to process registration and send email notification
        if(!contacts.isEmpty()){
            ExternalSystemService externalSysService = new ExternalSystemService(contacts);
            System.enqueueJob(externalSysService);
        }
    }
    
}