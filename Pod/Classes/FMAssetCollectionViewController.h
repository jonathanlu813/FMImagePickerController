//
//  FMAssetCollectionViewController.h
//  Pods
//
//  Created by Kyle Shank on 7/4/14.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol FMAssetCollectionViewControllerDelegate <NSObject>
-(void)assetTapped:(ALAsset*)asset atIndex:(NSUInteger)index;
-(void)assetLongPressed:(ALAsset*)asset atIndex:(NSUInteger)index;
@end

@interface FMAssetCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property id<FMAssetCollectionViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray* assets;
@property (nonatomic, assign) NSInteger maximum;
@property BOOL selectionMode;
@property NSUInteger cellSize;
@property CGFloat cellSpacing;
- (void)setSelectedAssets:(NSArray *)selectedAssets;
-(void)deselectAll;
-(void)selectAll;
@end
