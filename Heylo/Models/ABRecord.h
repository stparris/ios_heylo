//
//  ABRecord.h
//  notify
//
//  Created by Scott Parris on 4/24/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ABRecord : NSObject

@property (nonatomic,strong) NSNumber *recordId;
@property (nonatomic,strong) NSString *firstName;
@property (nonatomic,strong) NSString *lastName;
@property (nonatomic,strong) NSArray *phoneNumbers;
@property (nonatomic,strong) NSData *thumbnail;
@property (nonatomic,strong) NSNumber *createdDate;
@property (nonatomic,assign) BOOL isMember;


+ (NSArray *)abRecords;
- (id)initWithRecordId:(NSNumber *)_rid firstName:(NSString *)_fname lastName:(NSString *)_fname
          phoneNumbers:(NSArray *)_pnums thumbnail:(NSData *)_thumb createdDate:(NSNumber *)_created isMember:(BOOL)_member;

@end
