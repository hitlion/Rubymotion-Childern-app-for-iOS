#pragma once
#include <unistd.h>
#import <JavaScriptCore/JSExport.h>

@protocol BBVJSBridgedHelper <JSExport>
-( void )log:( NSString* )message;
-( void )msleep:( useconds_t )millisec;
@end

@protocol BBVJSBridgedObject <JSExport>
-( NSString* )name;
@end

@protocol BBVJSBridgedObjectVideo <JSExport>
- (NSString* )status;

-( void )start;
-( void )stop;
-( void )pause;
-( void )restart;
@end

@protocol BBVJSBridgedObjectAudio <JSExport>
-( void )start;
-( void )stop;
-( void )pause;
-( void )restart;
@end

@protocol BBVJSBridgedObjectPicture <JSExport>
-( NSString* )name;
@end

@protocol BBVJSBridgedObjectScreen <JSExport>
-( void )exit_to:( NSString* )path;
-( void )exit_story;
@end

@interface BBVJSBridgingHelper : NSObject<BBVJSBridgedHelper>
+( BOOL )injectProtocol:( NSString* )protocolName intoClass:( Class )cls;
+( BOOL )checkClass:( Class )cls forProtocol:( NSString* )protocolName;
@end

