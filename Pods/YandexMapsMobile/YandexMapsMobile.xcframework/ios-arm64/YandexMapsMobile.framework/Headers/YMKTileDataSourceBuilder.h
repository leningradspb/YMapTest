#import <YandexMapsMobile/YMKImagesImageUrlProvider.h>
#import <YandexMapsMobile/YMKProjection.h>
#import <YandexMapsMobile/YMKTileFormat.h>
#import <YandexMapsMobile/YMKTileProvider.h>
#import <YandexMapsMobile/YMKTilesUrlProvider.h>
#import <YandexMapsMobile/YMKZoomRange.h>

@class YMKTileDataSourceBuilder;

/**
 * Undocumented
 */
typedef void(^YMKCreateTileDataSource)(
    YMKTileDataSourceBuilder * _Nonnull builder);

/**
 * Undocumented
 */
@interface YMKBaseTileDataSourceBuilder : NSObject

/**
 * The class does not retain the object in the 'urlProvider' parameter.
 * It is your responsibility to maintain a strong reference to
 * the target object while it is attached to a class.
 */
- (void)setTileUrlProviderWithUrlProvider:(nonnull id<YMKTilesUrlProvider>)urlProvider;

/**
 * The class does not retain the object in the 'tileProvider' parameter.
 * It is your responsibility to maintain a strong reference to
 * the target object while it is attached to a class.
 */
- (void)setTileProviderWithTileProvider:(nonnull id<YMKTileProvider>)tileProvider;

/**
 * The class does not retain the object in the 'urlProvider' parameter.
 * It is your responsibility to maintain a strong reference to
 * the target object while it is attached to a class.
 */
- (void)setImageUrlProviderWithUrlProvider:(nonnull id<YMKImagesImageUrlProvider>)urlProvider;

/**
 * Undocumented
 */
- (void)setProjectionWithProjection:(nonnull YMKProjection *)projection;

/**
 * Undocumented
 */
- (void)setZoomRangesWithZoomRanges:(nonnull NSArray<YMKZoomRange *> *)zoomRanges;

/**
 * Undocumented
 */
- (void)setTileFormatWithFormat:(YMKTileFormat)format;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end

/**
 * Undocumented
 */
@interface YMKTileDataSourceBuilder : YMKBaseTileDataSourceBuilder

@end
