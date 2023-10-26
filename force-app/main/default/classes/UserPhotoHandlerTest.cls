@isTest
private class UserPhotoHandlerTest {

    static final String SMALL_PHOTO_URL = '/profilephoto/005/T';
    static final String MEDIUM_PHOTO_URL = '/profilephoto/005/M';
    static final String LARGE_PHOTO_URL = '/profilephoto/005/F';
    static final String SEARCH_STRING =   'file.force.com'; //might change in future releases!
    //A tiny Base64 encoded JPG
    static final String IMAGE_BASE64 = '/9j/4AAQSkZJRgABAQAASABIAAD/4QB2RXhpZgAATU0AKgAAAAgAAwESAAMAAAABAAEAAAExAAIAAAARAAAAModpAAQAAAABAAAARAAAAAB3d3cuaW5rc2NhcGUub3JnAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAEKADAAQAAAABAAAAEAAAAAD/7QA4UGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAAAA4QklNBCUAAAAAABDUHYzZjwCyBOmACZjs+EJ+/8AAEQgAEAAQAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/bAEMAHBwcHBwcMBwcMEQwMDBEXERERERcdFxcXFxcdIx0dHR0dHSMjIyMjIyMjKioqKioqMTExMTE3Nzc3Nzc3Nzc3P/bAEMBIiQkODQ4YDQ0YOacgJzm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5v/dAAQAAf/aAAwDAQACEQMRAD8A0ZmDXLpJK6KoQDaccsT1/Ko7Ce5V1t7kMSy5BYYOR1Hv1ouRcJctsVvLkVQWQZI254H1z1othcNcrvVvLjVgGcYJ3Y4P0x1oA//Z'; 

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement the respond method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a valid response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'image/jpeg');            
            res.setBodyAsBlob(EncodingUtil.base64Decode(IMAGE_BASE64));
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest(SeeALlData=true)
    static void testSetProfilePhoto() {
        // Setup: Create a test user
        User testUser = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser@testorg.com' + DateTime.now().getTime()
        );        
        insert testUser;
        
        //Get the user profile without profile photo
        ConnectApi.Photo usrPhoto = ConnectApi.UserProfiles.getPhoto(null, testUser.Id);
        
        //Check for the default path for images (as no image has been set yet)
        String smallPhoto = usrPhoto.smallPhotoUrl.substring(usrPhoto.smallPhotoUrl.indexOf(SEARCH_STRING) + SEARCH_STRING.length());
        System.assertEquals(SMALL_PHOTO_URL, smallPhoto);
        String mediumPhoto = usrPhoto.mediumPhotoUrl.substring(usrPhoto.mediumPhotoUrl.indexOf(SEARCH_STRING) + SEARCH_STRING.length());
        System.assertEquals(MEDIUM_PHOTO_URL, mediumPhoto);
        String largePhoto = usrPhoto.largePhotoUrl.substring(usrPhoto.largePhotoUrl.indexOf(SEARCH_STRING) + SEARCH_STRING.length());
        System.assertEquals(LARGE_PHOTO_URL, largePhoto);
        
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());                
        
        Test.startTest();        
        // Updating the user will fire the trigger
        testUser.SF_User_Profile_Photo__c = 'http://someurl.com/newimage.jpg';
        update testUser;        
        Test.stopTest();

        //Check the default path has been replaced
        usrPhoto = ConnectApi.UserProfiles.getPhoto(null, testUser.Id);
        smallPhoto = usrPhoto.smallPhotoUrl.substring(usrPhoto.smallPhotoUrl.indexOf(SEARCH_STRING) + SEARCH_STRING.length());
        System.assertNotEquals(SMALL_PHOTO_URL, smallPhoto);
        mediumPhoto = usrPhoto.mediumPhotoUrl.substring(usrPhoto.mediumPhotoUrl.indexOf(SEARCH_STRING) + SEARCH_STRING.length());
        System.assertNotEquals(MEDIUM_PHOTO_URL, mediumPhoto);
        largePhoto = usrPhoto.largePhotoUrl.substring(usrPhoto.largePhotoUrl.indexOf(SEARCH_STRING) + SEARCH_STRING.length());
        System.assertNotEquals(LARGE_PHOTO_URL, largePhoto);
    }
}
