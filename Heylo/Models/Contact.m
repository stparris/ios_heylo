//
//  Contact.m
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "Contact.h"
#import "User.h"
#import "AppDelegate.h"
#import "HeyloData.h"
#include <sqlite3.h>

@implementation Contact

+ (NSArray *)allContacts
{
    NSArray *contacts = [[NSArray alloc] initWithArray:[HeyloData getContacts]];
    return contacts;
}

+ (Contact *)findByPhone:(NSString *)_phone
{
    return [HeyloData getContactByPhone:_phone];
}

+ (Contact *)findByHeyloId:(NSString *)_hid
{
    return [HeyloData getContactByHeyloId:_hid];
    
}



- (id)initWithId:(NSNumber *)_cid abRecord:(NSNumber *)_abrec heyloId:(NSString *)_hid phoneNumber:(NSString *)_phone
       firstName:(NSString *)_fname lastName:(NSString *)_lname avatar:(NSString *)_imgStr activityDate:(NSNumber *)_adate createdDate:(NSNumber *)_date
{
    if ((self = [super init])) {
        self.contactId = _cid;
        self.abRecord = _abrec;
        self.heyloId = _hid;
        self.phoneNumber = _phone;
        self.firstName = _fname;
        self.lastName = _lname;
        self.avatar = _imgStr;
        self.activityDate = _adate;
        self.createdDate = _date;
    }
    return self;
}

- (ABRecordID)ABRecordId
{
    return (ABRecordID)[self.abRecord intValue];
}

- (BOOL)checkRecordWithFirstName:(NSString *)_abfname phoneNumber:(NSString *)_abphone {
    if (self.firstName != _abfname)
        return NO;
    if (self.phoneNumber != _abphone)
        return NO;
    
    return YES;
}

- (BOOL)update
{
    return [HeyloData updateContact:self];
}

- (BOOL)destroy
{
    return [HeyloData destroyContactWithId:self.contactId];
}



@end
