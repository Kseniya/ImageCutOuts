//
//  ShareView.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 2/5/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "ShareView.h"
#import <ShareKit/SHKSharer.h>
#import <ShareKit/SHKConfiguration.h>
#import "UIImage+ImageBlur.h"

#define MARGIN_X 15.0
#define MARGIN_Y 44.0

@interface ShareView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (strong) SHKSharer* limboSharer;	// used to postpone the call to share until the menu has finished animating out.

@end

@implementation ShareView

-(void)dealloc
{
    if(self.limboSharer != nil)
		[self.limboSharer share];
}


- (void)setItem:(SHKItem *)item
{
    //set Item that will be shared
    _item = item;
    self.tableData = [NSMutableArray arrayWithCapacity:0];
    [self.tableData addObject:[self section:@"services"]];
    [self.tableData addObject:[self section:@"actions"]];
}

+ (id)shareViewInView:(UIView*)view
{
    ShareView *shareView = [[ShareView alloc]initWithFrame:CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height)];
    
    //blur background
    UIImage *blurImage = [UIImage standardBlurImageFromView:view];
    shareView.backgroundColor = [UIColor colorWithPatternImage:blurImage];
    
    //TableView
    CGSize tableViewSize = CGSizeMake(shareView.frame.size.width - 2*MARGIN_X, shareView.frame.size.height - 2*MARGIN_Y - 20.0);
    CGRect tableViewRect = CGRectMake(MARGIN_X, MARGIN_Y + 20.0, tableViewSize.width, tableViewSize.height);
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    tableView.layer.cornerRadius = 3.0;
    tableView.dataSource = shareView;
    tableView.delegate = shareView;
    [shareView addSubview:tableView];
    
    //Navigation Bar
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, tableViewSize.width, 44.0)];
    tableView.tableHeaderView = navBar;
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    navBar.items = [NSArray arrayWithObject:navigationItem];
    
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:shareView
                                                                                          action:@selector(removeView)];
    navigationItem.title = @"Share";
    [view addSubview:shareView];

    //scale to 0 to prepare for zoom animation
    tableView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    
    //Blur view crossdisolve animation
    [UIView transitionWithView:view duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^ {
                        [view addSubview:shareView];
                    }
                    completion:^(BOOL finished){ }];
    
    
    //UITableView zoom with bounce animation
    [UIView animateWithDuration:0.3/2 delay:0.1 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3/2 animations:^{
                             tableView.transform = CGAffineTransformIdentity;
                         }];
                     }];
    
    return shareView;
}


- (NSMutableArray *)section:(NSString *)section
{ //get options for social and actions sections
	id class;
	NSMutableArray *sectionData = [NSMutableArray arrayWithCapacity:0];
	NSArray *source = [[SHK sharersDictionary] objectForKey:section];
	
	for( NSString *sharerClassName in source)
	{
		class = NSClassFromString(sharerClassName);
		if ( [class canShare] && [class canShareItem:self.item] )
			[sectionData addObject:[NSDictionary dictionaryWithObjectsAndKeys:sharerClassName,@"className",[class sharerTitle],@"name",nil]];
	}
    
	if (sectionData.count && [SHKCONFIG(shareMenuAlphabeticalOrder) boolValue])
		[sectionData sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
	
	return sectionData;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableData.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) //services
    {
        return 1;
    }
    else //actions
        return [[self.tableData objectAtIndex:section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([[self.tableData objectAtIndex:section] count])
	{
		if (section == 1)
			return SHKLocalizedString(@"Actions");
		
		else if (section == 0)
			return SHKLocalizedString(@"Share on ");
	}
	
	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[SHKCONFIG(SHKShareMenuCellSubclass) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir Next" size:15];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
	}
    
    if (indexPath.section == 0) //services
    {
        NSArray *services = [self.tableData objectAtIndex:indexPath.section];
        
        //create buttons for social networks
        [services enumerateObjectsUsingBlock:^(NSDictionary *rowData, NSUInteger idx, BOOL *stop) {
            
            UIButton *socialButton = [UIButton buttonWithType:UIButtonTypeCustom];
            socialButton.tag = idx;
            socialButton.frame = CGRectMake(15.0 + idx *50.0, 10.0, 40.0, 40.0);
            [socialButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Icon", rowData[@"name"]]] forState:UIControlStateNormal];
            [socialButton addTarget:self action:@selector(serviceSelected:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:socialButton];
            
        }];
    }
    else //actions
    {
        NSDictionary *rowData = [self rowDataAtIndexPath:indexPath];
        cell.textLabel.text = [rowData objectForKey:@"name"];
    }
	
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) //services
    {
        return 60.0;
    }
    else //actions
    {
        return 44.0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        NSDictionary *rowData = [self rowDataAtIndexPath:indexPath];
        [self share:rowData];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


- (NSDictionary *)rowDataAtIndexPath:(NSIndexPath *)indexPath
{
	return [[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}


#pragma mark Select and share

- (void)serviceSelected:(UIButton*)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    NSDictionary *rowData = [self rowDataAtIndexPath:indexPath];
    [self share:rowData];
}


- (void)share:(NSDictionary *)data
{
    bool doShare = YES;
    SHKSharer* sharer = [[NSClassFromString([data objectForKey:@"className"]) alloc] init];
    [sharer loadItem:self.item];
    
    if(doShare)
        self.limboSharer = sharer;
    
    [self removeView];
}


- (void)removeView
{
	UIView *aSuperview = [self superview];
    
    [UIView transitionWithView:aSuperview duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^ {
                        [super removeFromSuperview];
                        
                    }
                    completion:^(BOOL finished){ }];
}


@end
