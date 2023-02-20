/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Bader Eddine Elkhal
**/
@IsTest
public with sharing class EmailTemplateSelector_Test {
    @testSetup 
    static void prepareSetupData() {
        //Insert test User that will run tests
        User u = (User)TestDataFactory.createSObject('User', new Map<String,Object>{
            'ProfileId' => UserInfo.getProfileId(),
            'UserName'  => 'testUserEmail@test.com@EventSystem.com',
            'Email'     => 'testUserEmail@test.com',
            'Alias'     => 'tsEmail'
            });    
    }
    @IsTest
    public static void returnEmailTemplateThatMatchProvidedName(){
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        EmailTemplate emailTemplate = (EmailTemplate) TestDataFactory.createSObject('EmailTemplate', new Map<String,Object>{
            'Name'          => Constants.EMAIL_TEMPLATE_NAME,
            'DeveloperName' => Constants.EMAIL_TEMPLATE_NAME,
            'isActive'      => true,
            'TemplateType'  => Constants.EMAIL_TEMPLATE_TYPE_TEXT,
            'FolderId'      => user.Id,
            'Subject'       => Constants.EMAIL_TEMPLATE_NAME
            });
        
        Test.startTest();
        List<EmailTemplate> emailTemplates;
        System.runAs(user) {
            emailTemplates = EmailTemplateSelector.getEmailTEmplateByName(Constants.EMAIL_TEMPLATE_NAME);           
        }
        Test.stopTest();

        // Then
        System.assertEquals(emailTemplates.size() , 1 , 'the email template ' + Constants.EMAIL_TEMPLATE_NAME + ' successfully found');
    }

    @IsTest
    public static void returnNullWhenNoEmailtemplateMatchTheName(){
        
        User user = [SELECT Id, Email, Name FROM User LIMIT 1];
        Test.startTest();
        List<EmailTemplate> emailTemplates;
        System.runAs(user) {
            emailTemplates = EmailTemplateSelector.getEmailTEmplateByName('');           
        }
        Test.stopTest();

        // Then
        System.assertEquals(emailTemplates.isEmpty() , true , 'No email template found');
    }
    
}