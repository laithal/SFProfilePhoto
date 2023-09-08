public class UserPhotoHandler {
    
    @future(callout=true)
    public static void setProfilePhoto(Id userId, String photoURL) {
        // Fetch the content from the URL
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(photoURL);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Blob photoBlob = res.getBodyAsBlob();
            
            // Insert the image as a ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.VersionData = photoBlob;
            cv.Title = 'Profile Photo';
            cv.PathOnClient = 'ProfilePhoto.jpg'; // can adjust this based on file type
            insert cv;
            
            // Query for the associated ContentDocumentId
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            
            // Use ConnectApi to update the profile photo
            try {
                ConnectApi.UserProfiles.setPhoto(null, userId, contentDocumentId, null);
            } catch (Exception e) {
                // Handle errors here
                System.debug('Error setting profile photo: ' + e.getMessage());
            }
        } else {
            // Handle errors here
            System.debug('Error fetching photo: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
    }
}
