#import <YandexMapsMobile/YMKAnnotationLang.h>
#import <YandexMapsMobile/YMKDrivingSession.h>
#import <YandexMapsMobile/YMKRequestPoint.h>
#import <YandexMapsMobile/YRTError.h>

@class YMKDrivingOptions;
@class YMKDrivingVehicleOptions;

/**
 * Driving router type.
 */
typedef NS_ENUM(NSUInteger, YMKDrivingRouterType) {
    /**
     * Online driving router. Always tries to use online router even if
     * network is not available.
     */
    YMKDrivingRouterTypeOnline,
    /**
     * Offline driving router. Always tries to use offline router even if
     * network is available.
     */
    YMKDrivingRouterTypeOffline,
    /**
     * Combined driving router. Decision to use online or offline router is
     * based on internal timeout. If server manages to respond within given
     * time, then online router result is returned. Otherwise uses offline
     * router.  Will combine online and offline router result in single
     * session (hence the name). Timeout logic is applied on each resubmit
     * until first response from offline router is returned to the listener.
     * After that timeout is reduced to zero for all following resubmits.
     */
    YMKDrivingRouterTypeCombined
};

/**
 * Undocumented
 */
@interface YMKDrivingTooComplexAvoidedZonesError : YRTError

@end

/**
 * Driving options.
 */
@interface YMKDrivingOptions : NSObject

/**
 * Starting location azimuth.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, copy, nullable) NSNumber *initialAzimuth;

/**
 * The number of alternatives.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, copy, nullable) NSNumber *routesCount;

/**
 * The 'avoidTolls' option instructs the router to return routes that
 * avoid tolls when possible.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, copy, nullable) NSNumber *avoidTolls;

/**
 * The 'avoidUnpaved' option instructs the router to return routes that
 * avoid unpaved roads when possible.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, copy, nullable) NSNumber *avoidUnpaved;

/**
 * The 'avoidPoorConditions' option instructs the router to return
 * routes that avoid roads in poor conditions when possible.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, copy, nullable) NSNumber *avoidPoorConditions;

/**
 * Optional field, can be nil.
 */
@property (nonatomic, copy, nullable) NSDate *departureTime;

/**
 * A method to set the annotation language. lang The annotation
 * language.
 *
 * Optional field, can be nil.
 */
@property (nonatomic, copy, nullable) NSNumber *annotationLanguage;

+ (nonnull YMKDrivingOptions *)drivingOptionsWithInitialAzimuth:(nullable NSNumber *)initialAzimuth
                                                    routesCount:(nullable NSNumber *)routesCount
                                                     avoidTolls:(nullable NSNumber *)avoidTolls
                                                   avoidUnpaved:(nullable NSNumber *)avoidUnpaved
                                            avoidPoorConditions:(nullable NSNumber *)avoidPoorConditions
                                                  departureTime:(nullable NSDate *)departureTime
                                             annotationLanguage:(nullable NSNumber *)annotationLanguage;


@end

/**
 * Interface for the driving router.
 */
@interface YMKDrivingRouter : NSObject

/**
 * Builds a route.
 *
 * @param points Route points.
 * @param drivingOptions Driving options.
 * @param vehicleOptions Vehicle options.
 * @param routeListener Route listener object.
 */
- (nonnull YMKDrivingSession *)requestRoutesWithPoints:(nonnull NSArray<YMKRequestPoint *> *)points
                                        drivingOptions:(nonnull YMKDrivingOptions *)drivingOptions
                                        vehicleOptions:(nonnull YMKDrivingVehicleOptions *)vehicleOptions
                                          routeHandler:(nonnull YMKDrivingSessionRouteHandler)routeHandler;

/**
 * Creates a route summary.
 *
 * @param points Route points.
 * @param drivingOptions Driving options.
 * @param vehicleOptions Vehicle options.
 * @param summaryListener Summary listener object.
 */
- (nonnull YMKDrivingSummarySession *)requestRoutesSummaryWithPoints:(nonnull NSArray<YMKRequestPoint *> *)points
                                                      drivingOptions:(nonnull YMKDrivingOptions *)drivingOptions
                                                      vehicleOptions:(nonnull YMKDrivingVehicleOptions *)vehicleOptions
                                                      summaryHandler:(nonnull YMKDrivingSummarySessionSummaryHandler)summaryHandler;

@end
