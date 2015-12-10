#import "BBVJSBridgingHelper.h"
#import <objc/runtime.h>

@implementation BBVJSBridgingHelper
+( BOOL )injectProtocol:( NSString* )protocolName intoClass:( Class )cls
{
  /* ignore the following lines, Clang won't actually generate the protocols
   * unless it sees them used *somewhere*..
   */
  (void)@protocol(BBVJSBridgedObject);
  (void)@protocol(BBVJSBridgedObjectVideo);
  (void)@protocol(BBVJSBridgedObjectAudio);
  (void)@protocol(BBVJSBridgedObjectPicture);
  (void)@protocol(BBVJSBridgedObjectScreen);
  (void)@protocol(BBVJSBridgedFuture);
  (void)@protocol(BBVJSBridgedGlobal);
  (void)@protocol(BBVJSBridgedCache);

  Protocol *p = objc_getProtocol( [protocolName cStringUsingEncoding:NSUTF8StringEncoding] );
  if( p != NULL )
  {
    if( class_conformsToProtocol( cls, p ) == NO )
    {
      // inject only once
      class_addProtocol( cls, p );
    }
    return YES;
  }
  NSLog( @"I screwed up.. couldn't find a protocol named '%@'", protocolName );
  return NO;
}

+( BOOL )checkClass:( Class )cls forProtocol:( NSString* )protocolName
{
  Protocol *p = objc_getProtocol( [protocolName cStringUsingEncoding:NSUTF8StringEncoding] );
  if( p != NULL )
  {
    return class_conformsToProtocol( cls, p );
  }
  return NO;
}
@end

