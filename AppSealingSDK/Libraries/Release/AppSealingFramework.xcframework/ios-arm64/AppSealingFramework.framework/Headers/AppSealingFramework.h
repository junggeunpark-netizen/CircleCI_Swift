//
//  AppSealingFramework.h
//  AppSealingFramework
//
//  Created by Hyeseon Oh on 11/27/24.
//  Copyright © 2024 Inka. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for AppSealingFramework.
FOUNDATION_EXPORT double AppSealingFrameworkVersionNumber;

//! Project version string for AppSealingFramework.
FOUNDATION_EXPORT const unsigned char AppSealingFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AppSealingFramework/PublicHeader.h>

@interface AppSealingInterface : NSObject
- ( int )_IsAbnormalEnvironmentDetected __attribute__((deprecated("This method is deprecated. Use _IsAbnormalEnvironmentDetectedAsync instead.")));
- ( void )_IsAbnormalEnvironmentDetectedAsync:(void (^)(int result))completion;
+ ( void )_NotifySwizzlingDetected:(void (^)(NSString*))handler;
+ ( int )_ReturnSwizzlingDetected;
- ( const char* )_GetAppSealingDeviceID;
- ( const char* )_GetEncryptedCredential __attribute__((deprecated("This method is deprecated. Use _GetEncryptedCredentialAsync instead.")));
- ( void )_GetEncryptedCredentialAsync:(void (^)(const char *result))completion;
+ ( NSString* )_DSS: ( NSString* )string;  // Decrypt String (for Objective-C / Swift string)
+ ( NSString* )_DSC: ( char* )string;      // Decrypt String (for C string)
- ( BOOL )_EncryptData:( NSData* )plain iv:( NSData* )iv cipherOut:( NSMutableData* )cipherOut outLen:( size_t* )outLen;
- ( BOOL )_DecryptData:( NSData* )cipher iv:( NSData* )iv plainOut:( NSMutableData* )plainOut outLen:( size_t* )outLen;
- ( NSString* )_EncryptString:( NSString* )plain iv:( NSData* )iv;
- ( NSString* )_DecryptString:( NSString* )cipher iv:( NSData* )iv;
@end

#ifdef __cplusplus
extern "C"
{
#endif
int ObjC_IsAbnormalEnvironmentDetected() __attribute__((deprecated("This method is deprecated. Use _IsAbnormalEnvironmentDetectedAsync instead.")));
int ObjC_IsSwizzlingDetected();
int ObjC_IsSwizzlingDetectedReturn();
int ObjC_GetAppSealingDeviceID( char* deviceIDBuff );
int ObjC_GetEncryptedCredential( char* buffer ) __attribute__((deprecated("This method is deprecated. Use _GetEncryptedCredentialAsync instead.")));
char* ObjC_DecryptString( char* string );
int SecureStorage_AES256_Encrypt( uint8_t* plaintext, size_t plaintext_len, const uint8_t* iv, uint8_t* ciphertext_out, size_t* ciphertext_len_out );
int SecureStorage_AES256_Decrypt( const uint8_t* ciphertext, size_t ciphertext_len, const uint8_t* iv, uint8_t* plaintext_out, size_t* plaintext_len_out );

extern const int kAppSealingErrorNone;
extern const int kAppSealingErrorJailbreakDetected;
extern const int kAppSealingErrorDRMDecrypted;
extern const int kAppSealingErrorDebugAttached;
extern const int kAppSealingErrorHashInfoCorrupted;
extern const int kAppSealingErrorCodesignCorrupted;
extern const int kAppSealingErrorHashModified;
extern const int kAppSealingErrorExecutableCorrupted;
extern const int kAppSealingErrorCertificateChanged;
extern const int kAppSealingErrorBlacklistCorrupted;
extern const int kAppSealingErrorCheatToolDetected;
#ifdef __cplusplus
}
#endif