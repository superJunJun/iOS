//
//  UIImageView+WebCacheAssistor.h
//
//  辅助简化SDWebImage模块
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface UIImageView (WebCacheAssistor)

- (void)setImageWithURLString:(NSString *)urlString;
- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder;
- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;
- (void)setImageWithURLString:(NSString *)urlString completed:(SDWebImageCompletedBlock)completedBlock;
- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock;
- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock;
- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock;

+ (unsigned long long)imageCacheMemorySize;
+ (void)clearImageCacheMemory;
+ (void)setMaxImageCacheMemoryCost:(NSUInteger)maxImageCacheMemoryCost;

@end
