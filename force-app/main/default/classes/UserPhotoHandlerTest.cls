@isTest
private class UserPhotoHandlerTest {

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement the respond method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'image/jpeg');
            res.setBody('FakeImageBlob'); // This is a simple string to represent the Blob. In reality, image data is more complex.
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest static void testSetProfilePhoto() {
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
        
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        // Call the method to test
        UserPhotoHandler.setProfilePhoto(testUser.Id, 'http://someurl.com/image.jpg');
        Test.stopTest();
        
        // Verify the result
        // Verify the result
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'Profile Photo' LIMIT 1];
        System.assert(!cvList.isEmpty(), 'ContentVersion record not created');
        System.assertEquals('FakeImageBlob'.length(), cvList[0].VersionData.size());
    }
}
