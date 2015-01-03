// Generated by Swift version 1.1 (swift-600.0.56.1)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if defined(__has_include) && __has_include(<uchar.h>)
# include <uchar.h>
#elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
#endif

typedef struct _NSZone NSZone;

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted) 
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if defined(__has_feature) && __has_feature(modules)
@import CoreData;
@import Realm;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class NSError;

@interface NSManagedObject (SWIFT_EXTENSION(project))

/// Returns the class entity name
///
/// \returns String with the entity name
+ (NSString *)modelName;

/// Returns a the count of elements of this type
///
/// \returns Int
+ (NSInteger)count;

/// Creates a new object without inserting it in the context
///
/// \returns Created database object
+ (id)create;

/// Saves the object in the object context
///
/// \returns Bool indicating if the object has been properly saved
- (BOOL)save;

/// Saves the object in the object context asynchronously (or not) passing a completion closure
///
/// \param asynchronously Bool indicating if the saving process is asynchronous or not
///
/// \param completion Closure called when the saving operation has been completed
- (void)save:(BOOL)asynchronously completion:(void (^)(NSError *))completion;

/// Needed to be called when the object is going to be edited
///
/// \returns returns the current object
- (NSManagedObject *)beginWriting;

/// Needed to be called when the edition/deletion has finished
- (void)endWriting;

/// <ul><li><p>Asks the context for writing cancellation</p></li></ul>
- (void)cancelWriting;
@end

@class NSNotification;

@interface NSManagedObjectContext (SWIFT_EXTENSION(project))

/// Add observer of self to check when is going to save to ensure items are saved with permanent IDs
- (void)addObserverToGetPermanentIDsBeforeSaving;

/// Adds an observer when the context's objects have changed
///
/// \param closure Closure to be executed then objects have changed
- (void)addObserverWhenObjectsChanged:(void (^)(void))closure;

/// Method executed before saving that convert temporary IDs into permanet ones
///
/// \param notification Notification that fired this method
- (void)contextWillSave:(NSNotification *)notification;

/// Add observer of other context
///
/// \param context NSManagedObjectContext to be observed
///
/// \param mainThread Bool indicating if it's the main thread
- (void)startObserving:(NSManagedObjectContext *)context inMainThread:(BOOL)mainThread;

/// Stop observing changes from other contexts
///
/// \param context NSManagedObjectContext that is going to stop observing to
- (void)stopObserving:(NSManagedObjectContext *)context;

/// Method to merge changes from other contexts (fired by KVO)
///
/// \param notification Notification that fired this method call
- (void)mergeChanges:(NSNotification *)notification;

/// Method to merge changes from other contexts (in the main thread)
///
/// \param notification Notification that fired this method call
- (void)mergeChangesInMainThread:(NSNotification *)notification;
@end


@interface RLMResults (SWIFT_EXTENSION(project))
@end

#pragma clang diagnostic pop
