public class GoogleResponse {

    public cls_results[] results;
    public String status;
    
    public class cls_results {
        public String formatted_address;
        public cls_geometry geometry;
    }
    public class cls_geometry {
        public cls_location location;
    }
    public class cls_location {
        public Double lat;
        public Double lng;
    }
    public static GoogleResponse parse(String json){
        return (GoogleResponse) System.JSON.deserialize(json, GoogleResponse.class);
    }    
}