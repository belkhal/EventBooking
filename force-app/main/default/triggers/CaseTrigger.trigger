/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : Bader Eddine Elkhal
**/
trigger CaseTrigger on Case (before insert, before update, after insert, after update) {

    new CaseTriggerHandler().run();

}