#import "SentryDefines.h"

#if SENTRY_HAS_UIKIT

@class UIApplication;
@class UIScene;
@class UIWindow;
@class UIViewController;
@protocol UIApplicationDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * A helper tool to retrieve informations from the application instance.
 */
@interface SentryUIApplication : NSObject

/**
 * Application shared UIApplication instance.
 */
@property (nonatomic, readonly, nullable) UIApplication *sharedApplication;

/**
 * All application open windows.
 */
@property (nonatomic, readonly, nullable) NSArray<UIWindow *> *windows;

/**
 * Retrieves the application delegate for given UIApplication
 */
- (nullable id<UIApplicationDelegate>)getApplicationDelegate:(UIApplication *)application;

/**
 * Retrieves connected scenes for given UIApplication
 */
- (NSArray<UIScene *> *)getApplicationConnectedScenes:(UIApplication *)application
    API_AVAILABLE(ios(13.0), tvos(13.0));

/**
 * Return the most relevant view controller being presented in the app.
 */
- (NSArray<UIViewController *> *)relevantViewControllers;

@end

NS_ASSUME_NONNULL_END

#endif // SENTRY_HAS_UIKIT
