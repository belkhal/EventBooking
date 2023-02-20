/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public  class ExternalSystemService implements Queueable, Database.AllowsCallouts {
    private List<Contact> contactToRegister;

    /**
    * @description constructor
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param contacts 
    **/
    public ExternalSystemService(List<Contact> contacts){
        this.contactToRegister = contacts;
    }
    /**
    * @description excute method that call registerAttendees and sendEmailNotification
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param context 
    **/
    public void execute(QueueableContext context) {
        Set<Id> contactsToNotify = new Set<Id>();

        for(Contact contact : contactToRegister){
            if(Limits.getLimitCallouts() - Limits.getCallouts() > 0){
                if(!String.isBlank(contact.Email)){
                    //process contact registration
                    Boolean isRegistred = registerAttendee(contact.Name + '-' +contact.Email);
                    //stack contact email when registration succed to send notifcation 
                    if(isRegistred){
                        contactsToNotify.add(contact.Id);
                    }
                }
            }
            else{
                Logger.error('Callout Limit Excceded - Failled to register and notify contact with Id : ' + contact.Id );

            } 
        }
        if(!contactsToNotify.isEmpty()){
            //send emails to contacts
            sendEmailNotification(contactsToNotify);
        }
        Logger.saveLog();

    }

    /**
    * @description call external service to process contact
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param contactDetails 
    * @return Boolean 
    **/
    public Boolean registerAttendee(String contactDetails){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Constants.HTTP_ENDPOINT);
        request.setMethod(Constants.HTTP_METHOD);
        request.setHeader(Constants.HTTP_CONTENT_TYPE, Constants.HTTP_CONTENT_DATA);
        // Set the body as a JSON object
        request.setBody('{"name":"'+ contactDetails  +'"}');
        HttpResponse response;
        try{
            response = http.send(request);
        }catch(CalloutException e){
            Logger.error('Error on ' + contactDetails + ' - ' + e.getMessage());
            return false;
        }
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            return false;
        } else {
            return true;
        }  
    }

    /**
    * @description send email to notification to a giving list of contact
    * @author Bader Eddine Elkhal | 02-17-2023 
    * @param contactIds 
    **/
    public void sendEmailNotification(Set<Id> contactIds){
        
        //get email template
        List<EmailTemplate> emailTemplates = EmailTemplateSelector.getEmailTEmplateByName(Constants.CONDIRMATION_EMAIL_TEMPLATE);
        if(emailTemplates == null){
            return;
        }
        Messaging.MassEmailMessage emailMessage = new Messaging.MassEmailMessage();
        emailMessage.setDescription(Constants.EMAIL_NOTIFICATION); 
        emailMessage.setTargetObjectIds(new List<Id>(contactIds));
        emailMessage.setTemplateId(emailTemplates[0].Id);
        try{
            Messaging.sendEmail(new Messaging.MassEmailMessage[] { emailMessage });
        }
        catch(EmailException e){
            Logger.error(e.getMessage());
        }
    } 



}