//
//  Contact.h
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "User.h"
#define BASE_URL @"http://tapto.me:3000"
#define API_VERSION @"api/v1"

@interface Contact : NSObject

@property (nonatomic, strong) NSNumber *contactId;
@property (nonatomic, strong) NSNumber *abRecord;
@property (nonatomic, strong) NSString *heyloId;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSNumber *activityDate;
@property (nonatomic, strong) NSNumber *createdDate;
@property (nonatomic, assign) ABAddressBookRef addressBook;

+ (NSArray *)allContacts;
+ (Contact *)findByPhone:(NSString *)_phone;
+ (Contact *)findByHeyloId:(NSString *)_hid;


- (id)initWithId:(NSNumber *)contactId abRecord:(NSNumber *)abRecord heyloId:(NSString *)_hid phoneNumber:(NSString *)_phone firstName:(NSString *)_fname lastName:(NSString *)_lname avatar:(NSString *)_imgStr activityDate:(NSNumber *)_adate createdDate:(NSNumber *)_date;

- (ABRecordID)ABRecordId;
- (BOOL)checkRecordWithFirstName:(NSString *)_abfname phoneNumber:(NSString *)_abphone;
- (BOOL)destroy;
- (BOOL)update;

@end
