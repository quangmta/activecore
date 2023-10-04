#ifndef SYSTEM_CORE_INCLUDE_MINCRYPT_SHA256_H_
#define SYSTEM_CORE_INCLUDE_MINCRYPT_SHA256_H_
#include <stdint.h>
#include "hash-internal.h"
#ifdef __cplusplus
extern "C" {
#endif // __cplusplus
typedef HASH_CTX SHA256_CTX;
void SHA256_init(SHA256_CTX* ctx);
void SHA256_update(SHA256_CTX* ctx, const void* data, int len);
const uint8_t* SHA256_final(SHA256_CTX* ctx);
// Convenience method. Returns digest address.
const uint8_t* SHA256_hash(const void* data, int len, uint8_t* digest);
#define SHA256_DIGEST_SIZE 32
#ifdef __cplusplus
}
#endif // __cplusplus
#endif  // SYSTEM_CORE_INCLUDE_MINCRYPT_SHA256_H_