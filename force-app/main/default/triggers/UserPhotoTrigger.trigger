trigger UserPhotoTrigger on User (after insert, after update) {
    for(User u : Trigger.new) {
        if ((Trigger.isInsert || (Trigger.isUpdate && u.SF_User_Profile_Photo__c != Trigger.oldMap.get(u.Id).SF_User_Profile_Photo__c)) 
            && u.SF_User_Profile_Photo__c != null) {
            UserPhotoHandler.setProfilePhoto(u.Id, u.SF_User_Profile_Photo__c);
        }
    }
}
