public class UserPhotoHandler implements Queueable, Database.AllowsCallouts {
    
    List<Map<String, String>> userBatch;

    public UserPhotoHandler(List<Map<String, String>> userBatch) {
        this.userBatch = userBatch;
    }

    public void execute(QueueableContext context) {
        for(Map<String, String> userDetails : userBatch) {
            Id userId = userDetails.get('UserId');
            String photoURL = userDetails.get('PhotoURL');
            String userName = userDetails.get('Username');
            
            // Fetch the content from the URL
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(photoURL);
            req.setMethod('GET');
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Blob photoBlob = res.getBodyAsBlob();
                ConnectApi.BinaryInput photoInput = new ConnectApi.BinaryInput(photoBlob, 'image/jpg', userName + '_Profile.jpg');
                try {
                    ConnectApi.UserProfiles.setPhoto(null, userId, photoInput);
                } catch (Exception e) {
                    System.debug('Error setting profile photo: ' + e.getMessage());
                }
            } else {
                System.debug('Error retrieving photo: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        }
    }
}