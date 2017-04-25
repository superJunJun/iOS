//
//  TYDSearchAddressResultController.m
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDSearchAddressResultController.h"
#import <AMapSearchKit/AMapCommonObj.h>

@interface TYDSearchAddressResultController () 

@end

@implementation TYDSearchAddressResultController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self subviewsLoad];
}

- (void)subviewsLoad
{
    self.tableView.backgroundColor = [UIColor colorWithHex:0xffffff andAlpha:0.4];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectAddressCell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"selectAddressCell"];
    }
    
    AMapTip *tip = self.addressDataArray[indexPath.row];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = tip.name;
//    cell.detailTextLabel.text = tip.adcode;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.delegate respondsToSelector:@selector(addressResultSelect:searchTipAdCode:cityName:)])
    {
        AMapTip *tip = self.addressDataArray[indexPath.row];
        NSString *addressName = tip.name;
        NSString *addressAdCode = nil;
        NSString *cityName = nil;
        
        for(AMapTip *searchTip in self.searchTipsArray)
        {
            if([searchTip.name isEqualToString:addressName])
            {
                addressAdCode = searchTip.adcode;
                cityName = searchTip.district;
                break;
            }
        }
        
        [self.delegate addressResultSelect:addressName searchTipAdCode:addressAdCode cityName:cityName];
    }
}

@end
