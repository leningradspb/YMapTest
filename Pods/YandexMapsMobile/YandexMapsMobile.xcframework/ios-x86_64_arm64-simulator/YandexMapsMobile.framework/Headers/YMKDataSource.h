#import <Foundation/Foundation.h>

@class YMKDataSource;

/**
 * Undocumented
 */
@protocol YMKDataSourceListener <NSObject>

/**
 * Undocumented
 */
- (void)onDataSourceUpdatedWithDataSource:(nonnull YMKDataSource *)dataSource;

@end

/**
 * Undocumented
 */
@interface YMKDataSource : NSObject
/**
 * Stores id of data source.
 */
@property (nonatomic, readonly, nonnull) NSString *id;

/**
 * Invalidates data source and reloads all tiles. Must not be called if
 * DataSource does not support versioning: LayerOptions.versionSupport =
 * false;
 *
 * This method may be called on any thread. Its implementation must be thread-safe.
 */
- (void)invalidateWithVersion:(nonnull NSString *)version;

/**
 * Tells if this object is valid or no. Any method called on an invalid
 * object will throw an exception. The object becomes invalid only on UI
 * thread, and only when its implementation depends on objects already
 * destroyed by now. Please refer to general docs about the interface for
 * details on its invalidation.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
