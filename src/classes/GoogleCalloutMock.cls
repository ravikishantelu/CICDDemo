@isTest
global class GoogleCalloutMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        
        System.debug('rrrrrrrrrrrr'+req.getEndpoint());
        String respBody;
        if (!req.getEndPoint().contains('12312312')) {
            respBody = '{"results": [], "status": "ZERO RESULTS"}';
        }
        else {
           respBody = '{"results": [{"formatted_address": "116 SW Clay St, Portland, OR 97201, USA","geometry": {"location": {"lat": 45.512101,"lng": -122.6770504}}}],"status": "OK"}'; 
        }
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(respBody);
        res.setStatusCode(200);
        res.setStatus('OK');
        system.debug('+++++Inside test method+++++'+res.toString());
        return res;
    }
}