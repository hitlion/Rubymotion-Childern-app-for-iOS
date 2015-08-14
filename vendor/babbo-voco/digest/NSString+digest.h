#pragma once

@interface NSString(digest)
/* Return the SHA1 digest of the UTF8Bytes in this NSString. */
-( NSString* )sha1;

/* Return the SHA256 digest of the UTF8Bytes in this NSString. */
-( NSString* )sha256;

/* Return the MD5 digest of the UTF8Bytes in this NSString. */
-( NSString* )md5;
@end

