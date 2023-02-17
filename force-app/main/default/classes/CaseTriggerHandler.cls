/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public with sharing class CaseTriggerHandler extends TriggerHandler {

    private List<Case> newCaseList;
  
    public CaseTriggerHandler() {
      this.newCaseList = (List<Case>)Trigger.new;
    }

    public override void beforeInsert() {
      Logger.debug('$$ CaseTriggerHandler - beforeInsert Start');
      
      //get AccountIds by cases
      Set<String> accountIds = CaseService.getCaseAccountIds(newCaseList);
      //process before insert case validation
      try{
        CaseService.validateCases(newCaseList,accountIds);
      }catch(Exception e){
        Logger.error(e.getMessage());
        logger.saveLog();

      }
      
    }
    public override void afterUpdate() {
        Logger.debug('$$ CaseTriggerHandler - afterUpdate debug Start');
        
        CaseService.registerAttendees(newCaseList);
    }
  
}