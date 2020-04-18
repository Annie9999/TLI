@isTest
public class CustomerCalloutMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"code": "200", "status": "success", "result": {"tracking_system":{"SuperKey":"", "prospect_id": "", "message": ""}}}]');
        res.setStatusCode(200);
        return res;
    }

}