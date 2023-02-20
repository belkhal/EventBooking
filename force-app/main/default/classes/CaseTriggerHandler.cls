/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public with sharing class CaseTriggerHandler extends TriggerHandler {

    private List<Case> newCaseList;
  
    public CaseTriggerHandler() {
      this.newCaseList = (List<Case>)Trigger.new;
    }

    public override void beforeInsert() { 
      //process before insert case validation
      CaseService.validateCases(newCaseList);   
    }
    public override void afterUpdate() {
       CaseService.registerAttendees(newCaseList);
    }
  
}