/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Bader Eddine Elkhal
**/
public with sharing class Constants {
    
    public static final String CASE_ORIGIN_WEB    = 'Web';
    public static final String CASE_ORIGIN_PHONE  = 'Phone';
    public static final String CASE_ORIGIN_EMAIL  = 'Email';
    public static final String CASE_STATUS_NEW    = 'New';
    public static final String CASE_STATUS_CLOSED = 'Closed';



    public static final String HTTP_ENDPOINT               = 'callout:herokuapp';
    public static final String HTTP_METHOD                 = 'POST';
    public static final String HTTP_CONTENT_TYPE           = 'Content-Type';
    public static final String HTTP_CONTENT_DATA           = 'application/json;charset=UTF-8';
    public static final String EMAIL_NOTIFICATION          = 'Email Register confirmation';
    public static final String CONDIRMATION_EMAIL_TEMPLATE = 'reservationConfirm';
    public static final String EMAIL_TEMPLATE_NAME         = 'TestTemplate';
    public static final String EMAIL_TEMPLATE_TYPE_TEXT    = 'text';
}