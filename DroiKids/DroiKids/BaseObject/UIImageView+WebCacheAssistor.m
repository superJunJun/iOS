//
//  UIImageView+WebCacheAssistor.m
//

#import "UIImageView+WebCacheAssistor.h"

@implementation UIImageView (WebCacheAssistor)

- (void)setImageWithURLString:(NSString *)urlString
{
    [self setImageWithURL:[NSURL URLWithString:urlString]];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholder];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholder options:options];
}

- (void)setImageWithURLString:(NSString *)urlString completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:[NSURL URLWithString:urlString] completed:completedBlock];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholder completed:completedBlock];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholder options:options completed:completedBlock];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
}

#pragma mark - Memory Manage

+ (unsigned long long)imageCacheMemorySize
{
    return [[SDImageCache sharedImageCache] getSize];
}

+ (void)clearImageCacheMemory
{
    [[SDImageCache sharedImageCache] clearMemory];
}

+ (void)setMaxImageCacheMemoryCost:(NSUInteger)maxMemoryCost
{
    [[SDImageCache sharedImageCache] setMaxMemoryCost:maxMemoryCost];
}

@end
