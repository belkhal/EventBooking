/**
 * @description       : 
 * @author            : Bader Eddine Elkhal
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Bader Eddine Elkhal
**/
@IsTest
public with sharing class ExternalSystemServiceCalloutMock implements HttpCalloutMock {
    private Integer statusCode;
    public ExternalSystemServiceCalloutMock(Integer httpStatusCode){
        this.statusCode = httpStatusCode;
    }
    public HTTPResponse respond(HTTPRequest req) {
        // assert endpoint matching
        System.assertEquals(Constants.HTTP_ENDPOINT, req.getEndpoint(), 'Check endpoint');
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{}');
        response.setStatusCode(statusCode);
        return response;
    }
    
}