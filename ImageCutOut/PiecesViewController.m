//
//  PiecesViewController.m
//  ImageCutOut
//
//  Created by Kseniya Kalyuk Zito on 1/20/14.
//  Copyright (c) 2014 KZito. All rights reserved.
//

#import "PiecesViewController.h"
#import "ImagePieceReadWrite.h"
#import "SideMenuViewController.h"
#import "CollageViewController.h"

static NSString * const kMenuTableViewCellIdentifier = @"menuCell";

@interface PiecesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UILabel *noPiecesLbl;
@property (nonatomic, strong) NSArray *allPiecesArray;

@end

@implementation PiecesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMenuTableViewCellIdentifier];
    
    [self updateMenu];
}


-(void)updateMenu
{
    self.allPiecesArray = [[ImagePieceReadWrite sharedClient] thumbnailsNames];
    
    //if pieces available show list of them in table view, if not show label saying that there are no pieces
    
    [self.tableView reloadData];
    
    if ((self.allPiecesArray)&&(self.allPiecesArray.count >0))
    {
        self.noPiecesLbl.hidden = YES;
    }
    else
    {
        self.noPiecesLbl.hidden = NO;
    }
}


- (UIImage*)pieceThumbnailAtIndex:(NSInteger)index
{
    return [[ImagePieceReadWrite sharedClient] thumbnailAtIndex:index];
}


#pragma mark UITableViewDataSourse

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allPiecesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuTableViewCellIdentifier forIndexPath:indexPath];
    
    UIImage *pieceImage = [self pieceThumbnailAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = pieceImage;
    cell.imageView.bounds = CGRectMake(0.0, 0.0, pieceImage.size.width, pieceImage.size.height);
        
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UIImage *pieceImage = [self pieceThumbnailAtIndex:indexPath.row];
    
    return pieceImage.size.height + 20.0;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.sideMenuViewController openCloseMenuWithCompletion:^(MenuAnimationType animationType) {
        
        if (animationType == MenuAnimationTypeClosed)
        {
            //Add selected piece on collage view
            if ([self.sideMenuViewController.mainViewController isKindOfClass:[CollageViewController class]])
            {
                CollageViewController *collageViewController = (CollageViewController *)self.sideMenuViewController.mainViewController;
                [collageViewController addPieceToCollage:[[ImagePieceReadWrite sharedClient] imageAtIndex:indexPath.row]];
                collageViewController.collageMakingView.userInteractionEnabled = YES;
            }
        }
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[ImagePieceReadWrite sharedClient] deleteImageAndThumbnailAtIndex:indexPath.row completion:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateMenu];
            });
        }];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"CutModalView"])
    {
        //Close opened menu
        [self.sideMenuViewController openCloseMenuWithCompletion:^(MenuAnimationType animationType) {
            
            CollageViewController *collageViewController = (CollageViewController *)self.sideMenuViewController.mainViewController;
            
            if (animationType == MenuAnimationTypeOpened)
            {
                collageViewController.collageMakingView.userInteractionEnabled = NO;
            }
            else
            {
                collageViewController.collageMakingView.userInteractionEnabled = YES;
            }
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
