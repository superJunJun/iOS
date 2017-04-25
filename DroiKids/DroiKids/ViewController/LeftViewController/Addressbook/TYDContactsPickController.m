//
//  TYDContactsPickController.m
//  DroiKids
//
//  Created by wangchao on 15/8/31.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDContactsPickController.h"
#import <AddressBook/AddressBook.h>
#import <malloc/malloc.h>
#import "TYDContact.h"
#import "NSString+TKUtilities.h"

@interface TYDContactsPickController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *listContent;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation TYDContactsPickController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = cBasicBackgroundColor;
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    self.listContent = [NSMutableArray new];
    [self localAddressBookContacts];
}

- (void)navigationBarItemsLoad
{
    self.title = @"手机联系人";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"保存" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button sizeToFit];
    [button addTarget:self action:@selector(saveButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)subviewsLoad
{
    [self tableViewLoad];
}

- (void)localAddressBookContacts
{
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    
    ABAddressBookRef addressBooks = ABAddressBookCreateWithOptions(NULL, NULL);

    CFArrayRef allPerson = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    CFIndex personCount = ABAddressBookGetPersonCount(addressBooks);
    
    for(NSInteger i = 0; i < personCount; i++)
    {
        TYDContact *contact = [[TYDContact alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(allPerson, i);
        CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef fullName = ABRecordCopyCompositeName(person);
        
        NSString *firstNameString = (__bridge NSString *)firstName;
        NSString *lastNameString = (__bridge NSString *)lastName;
        
        NSString *nameString;
        if(fullName != nil)
        {
            nameString = (__bridge NSString *)fullName;
        }
        else
        {
            nameString = [NSString stringWithFormat:@"%@ %@", firstNameString, lastNameString];
        }
        
        if ([nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            continue;
        }
        
        contact.name = nameString;
        contact.recondID = (int)ABRecordGetRecordID(person);
        
        ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSInteger valuesCount = ABMultiValueGetCount(valuesRef);
        
        if(valuesCount == 0)
        {
            CFRelease(valuesRef);
            continue;
        }
        
        for(int i = 0; i < valuesCount; i++)
        {
            CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef, i);
            NSString *phoneNumber = [(__bridge NSString *)value telephoneWithReformat];
            [contact.phoneNumbers addObject:phoneNumber];
            
            CFRelease(value);
        }
        
        CFRelease(valuesRef);
        
        [addressBookTemp addObject:contact];
        
        if(firstName)
        {
            CFRelease(firstName);
        }
        if(lastName)
        {
            CFRelease(lastName);
        }
        if(fullName)
        {
            CFRelease(fullName);
        }
    }
    
    CFRelease(allPerson);
    CFRelease(addressBooks);
    
    //Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    
    for(TYDContact *contact in addressBookTemp)
    {
        NSInteger sect = [theCollation sectionForObject:contact
                                collationStringSelector:@selector(name)];
        
        contact.sectionNumber = sect;
    }
    
    NSInteger sectionCount = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:sectionCount];
    for(int i = 0; i <= sectionCount; i++)
    {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    
    for(TYDContact *contact in addressBookTemp)
    {
        [(NSMutableArray *)[sectionArrays objectAtIndex:contact.sectionNumber] addObject:contact];
    }
    
    for(NSMutableArray *sectionArray in sectionArrays)
    {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(name)];
        [self.listContent addObject:sortedSection];
    }
}

- (void)tableViewLoad
{
    UIView *tableViewFootView = [UIView new];
    tableViewFootView.backgroundColor = [UIColor clearColor];
    tableViewFootView.size = CGSizeMake(self.view.width, 20);
    
    CGRect frame = self.view.frame;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.tableFooterView = tableViewFootView;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.sectionIndexColor = [UIColor colorWithHex:0x6cbb52];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)selectNumber:(NSString *)phoneNumber
{
    if([self.delegate respondsToSelector:@selector(contactsPickComplete:)])
    {
        [self.delegate contactsPickComplete:phoneNumber];
    }
    
    [super popBackEventWillHappen];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [NSArray arrayWithArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.listContent count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.listContent objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[_listContent objectAtIndex:section] count] ? tableView.sectionHeaderHeight : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.listContent objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *contactCell = @"contactPickerControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactCell];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    TYDContact *addressBook = nil;
    addressBook = (TYDContact *)[[self.listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if([addressBook.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        cell.textLabel.text = addressBook.name;
    }
    else
    {
        cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
        cell.textLabel.text = @"No Name";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TYDContact *addressBook = (TYDContact *)[[self.listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [self selectNumber:addressBook.phoneNumbers[0]];
}

#pragma mark - TouchEvent

- (void)saveButtonTap:(UIButton *)sender
{
    NSLog(@"saveButtonTap");
}

@end
