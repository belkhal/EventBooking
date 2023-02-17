/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public with sharing class EmailTemplateSelector {
    
    /**
    * @description return emailtemplate by template name
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param emailTemplateName 
    * @return EmailTemplate 
    **/
    public static List<EmailTemplate> getEmailTEmplateByName(String emailTemplateName){
        return [SELECT Id, Name FROM EmailTemplate WHERE Name =: emailTemplateName WITH SECURITY_ENFORCED];
    }
}