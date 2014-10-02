//
//  FMAssetCollectionViewController.m
//  Pods
//
//  Created by Kyle Shank on 7/4/14.
//
//

#import "FMAssetCollectionViewController.h"
#import "FMAssetCollectionViewCell.h"

#define FM_COLLECTION_CELL_REUSE_ID @"FMCollectionViewCell"

@interface FMAssetCollectionViewController ()
@property (nonatomic, retain) UICollectionView* collectionView;
@property (nonatomic, retain) NSMutableArray* selected;
@end

@implementation FMAssetCollectionViewController

-(id)init{
    if(self = [super init]){
        [self setDefaults];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self setDefaults];
    }
    return self;
}

-(id)initWithAssets:(NSArray*)assets{
    if(self = [super init]){
        [self setDefaults];
        self.assets=assets;
    }
    return self;
}

-(void)setDefaults{
    self.assets = [NSArray array];
    self.selected = [NSMutableArray array];
    self.selectionMode = NO;
    self.cellSize = 75;
    self.cellSpacing = 4.0;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        self.cellSize = 150;
        self.cellSpacing = 3.0;
    }
    
}

-(void)loadView{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing=self.cellSpacing;
    layout.minimumLineSpacing=self.cellSpacing;
    layout.sectionInset = UIEdgeInsetsMake(self.cellSpacing, self.cellSpacing, self.cellSpacing, self.cellSpacing);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView registerClass:[FMAssetCollectionViewCell class] forCellWithReuseIdentifier:FM_COLLECTION_CELL_REUSE_ID];
    self.view = self.collectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Configuration

-(void)setAssets:(NSArray *)assets{
    _assets = assets;
    if(self.collectionView){
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.collectionView setContentOffset:CGPointZero animated:NO];
            [self.collectionView reloadData];
        });
    }
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMAssetCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:FM_COLLECTION_CELL_REUSE_ID forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.index = indexPath.row;
    cell.asset = [self.assets objectAtIndex:indexPath.row];
    cell.selected = [self assetSelected:cell.index];
    
    UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(assetLongPress:)];
    [cell addGestureRecognizer:pressRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(assetTap:)];
    [tapRecognizer requireGestureRecognizerToFail:pressRecognizer];
    [cell addGestureRecognizer:tapRecognizer];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.cellSize, self.cellSize);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.assets count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - Asset selection

- (void)assetTap:(UITapGestureRecognizer *)tapRecognizer
{
    if (self.selected.count >= self.maximum) {
        return;
    }
    NSInteger index = tapRecognizer.view.tag;
    if(self.selectionMode){
        BOOL isSelected = NO;
        for (NSURL *selectedUrl in self.selected) {
            ALAsset *asset = [self.assets objectAtIndex:index];
            if ([[asset valueForProperty:ALAssetPropertyAssetURL] isEqual:selectedUrl]) {
                isSelected=YES;
                break;
            }
        }
        if(!isSelected){
            if(self.delegate!=nil){
                ALAsset* asset = [self.assets objectAtIndex:index];
                [self.delegate assetTapped:asset atIndex:index];
            }
        }
        [self.collectionView reloadData];
    }
}

- (void)assetLongPress:(UILongPressGestureRecognizer *)pressRecognizer
{
    if(pressRecognizer.state == UIGestureRecognizerStateBegan){
        NSInteger index = pressRecognizer.view.tag;
        if(self.delegate!=nil){
            ALAsset* asset = [self.assets objectAtIndex:index];
            [self.delegate assetLongPressed:asset atIndex:index];
        }
    }
}

- (BOOL) assetSelected:(NSUInteger)index{
    if(self.selectionMode){
        BOOL isSelected = NO;
        for (NSURL *selectedUrl in self.selected) {
            ALAsset *asset = [self.assets objectAtIndex:index];
            if ([[asset valueForProperty:ALAssetPropertyAssetURL] isEqual:selectedUrl]) {
                isSelected=YES;
                break;
            }
        }
        return isSelected;
    }else{
        return NO;
    }
}

- (void)setSelectedAssets:(NSArray *)selectedAssets{
    [self.selected removeAllObjects];
    for (NSURL *url in selectedAssets) {
        [self.selected addObject:url];
    }
}

-(void)deselectAll{
    [self.selected removeAllObjects];
    [self.collectionView reloadData];
}

-(void)selectAll{
    [self.selected removeAllObjects];
    for (ALAsset *asset in self.assets) {
        [self.selected addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
    }
    [self.collectionView reloadData];
}

@end
