#import "SentryDefines.h"

@class SentryOptions, SentryCrashWrapper, SentryAppState, SentryFileManager, SentrySysctl,
    SentryDispatchQueueWrapper;

NS_ASSUME_NONNULL_BEGIN

@interface SentryAppStateManager : NSObject
SENTRY_NO_INIT

@property (nonatomic, readonly) NSInteger startCount;

- (instancetype)initWithOptions:(SentryOptions *)options
                   crashWrapper:(SentryCrashWrapper *)crashWrapper
                    fileManager:(SentryFileManager *)fileManager
                         sysctl:(SentrySysctl *)sysctl
           dispatchQueueWrapper:(SentryDispatchQueueWrapper *)dispatchQueueWrapper;

#if SENTRY_HAS_UIKIT

- (void)start;
- (void)stop;
- (void)stopWithForce:(BOOL)forceStop;

/**
 * Builds the current app state.
 * @discussion The systemBootTimestamp is calculated by taking the current time and subtracting
 * @c NSProcessInfo.systemUptime . @c NSProcessInfo.systemUptime returns the amount of time the
 * system has been awake since the last time it was restarted. This means This is a good enough
 * approximation about the timestamp the system booted.
 */
- (SentryAppState *)buildCurrentAppState;

- (SentryAppState *)loadPreviousAppState;

- (void)storeCurrentAppState;

- (void)updateAppState:(void (^)(SentryAppState *))block;

#endif

@end

NS_ASSUME_NONNULL_END
