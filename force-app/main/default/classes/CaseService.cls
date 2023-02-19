/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-18-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public with sharing class CaseService {
    public static final String CASE_ORIGIN_WEB = 'Web';
    public static final String CASE_ORIGIN_PHONE = 'Phone';
    public static final String CASE_STATUS_CLOSED = 'Closed';

    /**
    * @description method that check the validation of list of cases data and add an error to the sepecific field if a rule was broken
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param case 
    **/
    public static void validateCases(List<Case> cases, Set<Id> accountIds){
        Logger.debug('$$ CaseService - validateCases Start');
        Map<Id, Account> accountByIdMap = AccountSelector.getAccountsById(accountIds);
        for(Case caseRecord : cases){
            //add error to case not linked to any account
            if(caseRecord.AccountId == null){
                caseRecord.AccountId.addError('You cannot create a request without attaching an account');
            }
            else{
                Integer numberOfContact = accountByIdMap.containsKey(caseRecord.AccountId) ? accountByIdMap.get(caseRecord.AccountId).Contacts.size() : 0;
                //add error to case when the origin is web-reservation and the number of attendees greather than 1
                if(numberOfContact > 1 && caseRecord.Origin.equalsIgnoreCase(CASE_ORIGIN_WEB)){
                    caseRecord.Origin.addError('Web request are only allowed to have one attendee');
                }
                //add error to case when the origin is phone-reservation and the number of attendee greather than 3
                else if(numberOfContact > 3 && caseRecord.Origin.equalsIgnoreCase(CASE_ORIGIN_PHONE)){
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
            if(caseRecord.Status.equalsIgnoreCase(CASE_STATUS_CLOSED)){
                closedCases.add(caseRecord);
            }
        }
        if(closedCases.isEmpty()){
            return;
        }
        //get AccountIds by cases
        accountIds = CaseService.getCaseAccountIds(closedCases);
        contacts = ContactSelector.getContactsByAccount(accountIds);
        // call ExternalSystemService to process registration and send email notification
        if(!contacts.isEmpty()){
            ExternalSystemService externalSysService = new ExternalSystemService(contacts);
            System.enqueueJob(externalSysService);
        }
    }
    
}