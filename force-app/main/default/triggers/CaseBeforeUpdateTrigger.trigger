/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : Bader Eddine Elkhal
**/
trigger CaseBeforeUpdateTrigger on Case (before update, after update) {

    Boolean requestSentToExternalSystem = false;
    Integer i=0;
    
    Case request = Trigger.new[0];

    Case r = [SELECT AccountId, Status FROM Case where id=:request.ID];
    if(r.Status == 'Closed'){
        //ExternalSystemService service = new ExternalSystemService();
        //service.registerAttendees(r);
    }
}