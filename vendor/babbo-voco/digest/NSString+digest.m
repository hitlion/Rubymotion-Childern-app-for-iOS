#import "NSString+digest.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString(digest)

-( NSString* )sha1
{
  const char *bytes = [self UTF8String];
  const NSUInteger length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];

  memset( hashBytes, 0, sizeof( hashBytes) );

  if( length < 1 || CC_SHA1( bytes, length, hashBytes ) == NULL )
  {
    return @"";
  }

  NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  NSUInteger i = 0;

  for( i = 0; i < CC_SHA1_DIGEST_LENGTH; ++i )
  {
    [result appendFormat:@"%02.2x", hashBytes[i]];
  }
  return result;
}


-( NSString* )sha256
{
  const char *bytes = [self UTF8String];
  const NSUInteger length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  unsigned char hashBytes[CC_SHA256_DIGEST_LENGTH];

  memset( hashBytes, 0, sizeof( hashBytes) );

  if( length < 1 || CC_SHA256( bytes, length, hashBytes ) == NULL )
  {
    return @"";
  }

  NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  NSUInteger i = 0;

  for( i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i )
  {
    [result appendFormat:@"%02.2x", hashBytes[i]];
  }
  return result;
}

-( NSString* )md5
{
  const char *bytes = [self UTF8String];
  const NSUInteger length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  unsigned char hashBytes[CC_MD5_DIGEST_LENGTH];

  memset( hashBytes, 0, sizeof( hashBytes) );

  if( length < 1 || CC_MD5( bytes, length, hashBytes ) == NULL )
  {
    return @"";
  }

  NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  NSUInteger i = 0;

  for( i = 0; i < CC_MD5_DIGEST_LENGTH; ++i )
  {
    [result appendFormat:@"%02.2x", hashBytes[i]];
  }
  return result;
}


@end

