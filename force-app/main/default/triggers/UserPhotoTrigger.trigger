trigger UserPhotoTrigger on User (after insert, after update) {
    List<Map<String, String>> userBatch = new List<Map<String, String>>();
    
    for(User u : Trigger.new) {
        if ((Trigger.isInsert || (Trigger.isUpdate && u.SF_User_Profile_Photo__c != Trigger.oldMap.get(u.Id).SF_User_Profile_Photo__c)) 
            && u.SF_User_Profile_Photo__c != null) {
            Map<String, String> userDetails = new Map<String, String>{
                'UserId' => u.Id,
                'PhotoURL' => u.SF_User_Profile_Photo__c
            };
            userBatch.add(userDetails);

            if(userBatch.size() == 49 || u == Trigger.new[Trigger.new.size()-1]) {
                UserPhotoHandler handler = new UserPhotoHandler(userBatch);
                System.enqueueJob(handler);
                userBatch.clear();
            }
        }
    }
}