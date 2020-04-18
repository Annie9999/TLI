public class CalloutAPI_Util {
    public static Boolean isHTTP503ServiceUnavailable (Exception e) {
        return e.getMessage().contains('HTTP/1.1 503 Service Unavailable') == true;
    }
}