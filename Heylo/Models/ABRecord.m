//
//  ABRecord.m
//  notify
//
//  Created by Scott Parris on 4/24/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "ABRecord.h"
#import "Contact.h"
#import "AppDelegate.h"

@implementation ABRecord


+ (NSArray *)abRecords
{
    // Creates a dictionary of existing members
    NSMutableDictionary *recordContact = [[NSMutableDictionary alloc] init];
    for (Contact *c in [Contact allContacts]) {
        [recordContact setObject:c.contactId forKey:c.abRecord];
     //   NSLog(@"is member %@", c.firstName);
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\$|\\_|\\!|\\>|\\<"
                                                                           options:0
                                                                             error:NULL];

    
    NSMutableArray *unsorted = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBookRef));
    for (int i= 0; i < [allPeople count]; i++) {
        ABRecordRef person = CFBridgingRetain([allPeople objectAtIndex:i]);
        NSNumber *recordId = [NSNumber numberWithInteger:ABRecordGetRecordID(person)];
        // Check if record exists and add to web query if not
        BOOL isMember = NO;
        if ([recordContact objectForKey:recordId])
            isMember = YES;
        
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex PhoneCount = ABMultiValueGetCount(phones);
        BOOL gotPhone = NO;
        NSMutableArray *pnums = [[NSMutableArray alloc] init];
        for (int k  = 0; k < PhoneCount; k++) {
            NSString *rawType = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phones, k));
            if (rawType) {
                gotPhone = YES;
                NSString *type = [regex stringByReplacingMatchesInString:rawType options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [rawType length]) withTemplate:@""];

                NSString *pnum = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, k);
                if (type && pnum) {
                    NSDictionary *phoneNum = [[NSDictionary alloc] initWithObjects:@[type,pnum] forKeys:@[@"type",@"number"]];
                    [pnums addObject:phoneNum];
                }
            }
        }
        NSDate *creationDate = (__bridge NSDate*) ABRecordCopyValue(person, kABPersonCreationDateProperty);
        NSTimeInterval time_seconds = [creationDate timeIntervalSince1970];
        NSNumber *createdDate = [NSNumber numberWithDouble:time_seconds];
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue (person, kABPersonFirstNameProperty)) ?
            (__bridge NSString *)(ABRecordCopyValue (person, kABPersonFirstNameProperty)) : @"";
        NSString *lastName  = (__bridge NSString *)(ABRecordCopyValue (person, kABPersonLastNameProperty)) ?
               (__bridge NSString *)(ABRecordCopyValue (person, kABPersonLastNameProperty)) : @"";
        NSData *imageData = nil;
        if (ABPersonHasImageData(person)) {
            imageData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        }
        if (gotPhone && (firstName.length > 0 || lastName.length > 0)) {
            ABRecord *abrec = [[ABRecord alloc] initWithRecordId:recordId firstName:firstName lastName:lastName phoneNumbers:pnums thumbnail:imageData createdDate:createdDate isMember:isMember];
            [unsorted addObject:abrec];
        }
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [unsorted sortedArrayUsingDescriptors:sortDescriptors];
}

- (id)initWithRecordId:(NSNumber *)_rid firstName:(NSString *)_fname lastName:(NSString *)_lname
          phoneNumbers:(NSArray *)_pnums thumbnail:(NSData *)_thumb createdDate:(NSNumber *)_created isMember:(BOOL)_member
{
    if (self = [super init]) {
        self.recordId = _rid;
        self.firstName = _fname;
        self.lastName = _lname;
        self.phoneNumbers = _pnums;
        self.thumbnail = _thumb;
        self.createdDate = _created;
        self.isMember = _member;
    }
    return self;
}

@end
