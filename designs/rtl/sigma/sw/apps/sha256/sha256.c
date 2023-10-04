#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "sha256.h"
#include "io.h"

#define ror(value, bits) (((value) >> (bits)) | ((value) << (32 - (bits))))
#define shr(value, bits) ((value) >> (bits))

#define IO_LED (*(volatile unsigned int *)(0x80000000))
#define IO_SW (*(volatile unsigned int *)(0x80000004))

union
{
    uint8_t hash32[SHA256_DIGEST_SIZE];
    unsigned int hash8[(int)(SHA256_DIGEST_SIZE * sizeof(uint8_t) / sizeof(unsigned int))];
} hash;

void delay(uint32_t count){
    while(count--) asm volatile("nop");
}


// wrapper for instruction activating custom coprocessor
inline unsigned int custom0_instr_wrapper(unsigned int a, unsigned int b, unsigned int funct7)
{
    unsigned int result;
    asm volatile(".insn r 0x0b, 0x0, %[_funct7], %0, %1, %2"
                 : "=r"(result)
                 : "r"(a), "r"(b), [_funct7]"i"(funct7));
    return result;
}

static const uint32_t K[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

static void SHA256_Transform(SHA256_CTX *ctx)
{
    uint32_t W[64];
    uint32_t A, B, C, D, E, F, G, H;
    uint8_t *p = ctx->buf;
    int i;
    int t;

    for (t = 0; t < 16; ++t)
    {
        uint32_t tmp = *p++ << 24;
        tmp |= *p++ << 16;
        tmp |= *p++ << 8;
        tmp |= *p++;
        W[t] = tmp;
    }

    // ---------------------the most “hot” fragment------------------------
    // for (; t < 64; t++)
    // {

    //     uint32_t s0 = ror(W[t-15], 7) ^ ror(W[t-15], 18) ^ shr(W[t-15], 3);
    //     uint32_t s1 = ror(W[t-2], 17) ^ ror(W[t-2], 19) ^ shr(W[t-2], 10);
    //     W[t] = W[t-16] + s0 + W[t-7] + s1; // custom0_instr_wrapper(W[t-15],W[t-2]);
    // }

    // A = ctx->state[0];
    // B = ctx->state[1];
    // C = ctx->state[2];
    // D = ctx->state[3];
    // E = ctx->state[4];
    // F = ctx->state[5];
    // G = ctx->state[6];
    // H = ctx->state[7];
    // for(t = 0; t < 64; t++) {
    //     uint32_t s0 = ror(A, 2) ^ ror(A, 13) ^ ror(A, 22);
    //     uint32_t maj = (A & B) ^ (A & C) ^ (B & C);
    //     uint32_t t2 = s0 + maj;
    //     uint32_t s1 = ror(E, 6) ^ ror(E, 11) ^ ror(E, 25);
    //     uint32_t ch = (E & F) ^ ((~E) & G);
    //     uint32_t t1 = H + s1 + ch + K[t] + W[t];
    //     H = G;
    //     G = F;
    //     F = E;
    //     E = D + t1;
    //     D = C;
    //     C = B;
    //     B = A;
    //     A = t1 + t2;
    // }
    // ctx->state[0] += A;
    // ctx->state[1] += B;
    // ctx->state[2] += C;
    // ctx->state[3] += D;
    // ctx->state[4] += E;
    // ctx->state[5] += F;
    // ctx->state[6] += G;
    // ctx->state[7] += H;

    // ---------------------- System bus -------------------------------//
    for (; t < 64; t++)
    {
        *(volatile unsigned int *)(0x80000100) = W[t - 15];
        *(volatile unsigned int *)(0x80000200) = W[t - 2];   
        W[t] = W[t - 16] + W[t - 7] + *(volatile unsigned int *)(0x80000300);
    }

    *(volatile unsigned int *)(0x80001000) = ctx->state[0];
    *(volatile unsigned int *)(0x80001100) = ctx->state[1];
    *(volatile unsigned int *)(0x80001200) = ctx->state[2];
    *(volatile unsigned int *)(0x80001300) = ctx->state[3];
    *(volatile unsigned int *)(0x80001400) = ctx->state[4];
    *(volatile unsigned int *)(0x80001500) = ctx->state[5];
    *(volatile unsigned int *)(0x80001600) = ctx->state[6];
    *(volatile unsigned int *)(0x80001700) = ctx->state[7];


    for(t = 0; t < 64; t++) {
        *(volatile unsigned int *)(0x80001800) = K[t];
        *(volatile unsigned int *)(0x80001900) = W[t];
    }

    ctx->state[0] += *(volatile unsigned int *)(0x80002000);
    ctx->state[1] += *(volatile unsigned int *)(0x80002100);
    ctx->state[2] += *(volatile unsigned int *)(0x80002200);
    ctx->state[3] += *(volatile unsigned int *)(0x80002300);
    ctx->state[4] += *(volatile unsigned int *)(0x80002400);
    ctx->state[5] += *(volatile unsigned int *)(0x80002500);
    ctx->state[6] += *(volatile unsigned int *)(0x80002600);
    ctx->state[7] += *(volatile unsigned int *)(0x80002700);


    // --------------------- Using co-processor to speed up ------------------------ //

    // for (; t < 64; t++)
    // {
    //     W[t] = W[t-16] + W[t-7] + custom0_instr_wrapper(W[t-15],W[t-2],0x00);
    // }

    // custom0_instr_wrapper(ctx->state[0], ctx->state[1], 0x01);
    // custom0_instr_wrapper(ctx->state[2], ctx->state[3], 0x02);
    // custom0_instr_wrapper(ctx->state[4], ctx->state[5], 0x03);
    // custom0_instr_wrapper(ctx->state[6], ctx->state[7], 0x04);

    // for(t = 0; t < 64; t++) {
    //     custom0_instr_wrapper(K[t],W[t], 0x05);
    // }

    // custom0_instr_wrapper(K[0], 0x09);
    // custom0_instr_wrapper(W[0], 0x0a);
    // custom0_instr_wrapper(K[1], 0x09);
    // custom0_instr_wrapper(W[1], 0x0a);
    // custom0_instr_wrapper(K[2], 0x09);
    // custom0_instr_wrapper(W[2], 0x0a);
    // custom0_instr_wrapper(K[3], 0x09);
    // custom0_instr_wrapper(W[3], 0x0a);
    // custom0_instr_wrapper(K[4], 0x09);
    // custom0_instr_wrapper(W[4], 0x0a);
    // custom0_instr_wrapper(K[5], 0x09);
    // custom0_instr_wrapper(W[5], 0x0a);
    // custom0_instr_wrapper(K[6], 0x09);
    // custom0_instr_wrapper(W[6], 0x0a);
    // custom0_instr_wrapper(K[7], 0x09);
    // custom0_instr_wrapper(W[7], 0x0a);
    // custom0_instr_wrapper(K[8], 0x09);
    // custom0_instr_wrapper(W[8], 0x0a);
    // custom0_instr_wrapper(K[9], 0x09);
    // custom0_instr_wrapper(W[9], 0x0a);
    // custom0_instr_wrapper(K[10], 0x09);
    // custom0_instr_wrapper(W[10], 0x0a);
    // custom0_instr_wrapper(K[11], 0x09);
    // custom0_instr_wrapper(W[11], 0x0a);
    // custom0_instr_wrapper(K[12], 0x09);
    // custom0_instr_wrapper(W[12], 0x0a);
    // custom0_instr_wrapper(K[13], 0x09);
    // custom0_instr_wrapper(W[13], 0x0a);
    // custom0_instr_wrapper(K[14], 0x09);
    // custom0_instr_wrapper(W[14], 0x0a);
    // custom0_instr_wrapper(K[15], 0x09);
    // custom0_instr_wrapper(W[15], 0x0a);
    // custom0_instr_wrapper(K[16], 0x09);
    // custom0_instr_wrapper(W[16], 0x0a);
    // custom0_instr_wrapper(K[17], 0x09);
    // custom0_instr_wrapper(W[17], 0x0a);
    // custom0_instr_wrapper(K[18], 0x09);
    // custom0_instr_wrapper(W[18], 0x0a);
    // custom0_instr_wrapper(K[19], 0x09);
    // custom0_instr_wrapper(W[19], 0x0a);
    // custom0_instr_wrapper(K[20], 0x09);
    // custom0_instr_wrapper(W[20], 0x0a);
    // custom0_instr_wrapper(K[21], 0x09);
    // custom0_instr_wrapper(W[21], 0x0a);
    // custom0_instr_wrapper(K[22], 0x09);
    // custom0_instr_wrapper(W[22], 0x0a);
    // custom0_instr_wrapper(K[23], 0x09);
    // custom0_instr_wrapper(W[23], 0x0a);
    // custom0_instr_wrapper(K[24], 0x09);
    // custom0_instr_wrapper(W[24], 0x0a);
    // custom0_instr_wrapper(K[25], 0x09);
    // custom0_instr_wrapper(W[25], 0x0a);
    // custom0_instr_wrapper(K[26], 0x09);
    // custom0_instr_wrapper(W[26], 0x0a);
    // custom0_instr_wrapper(K[27], 0x09);
    // custom0_instr_wrapper(W[27], 0x0a);
    // custom0_instr_wrapper(K[28], 0x09);
    // custom0_instr_wrapper(W[28], 0x0a);
    // custom0_instr_wrapper(K[29], 0x09);
    // custom0_instr_wrapper(W[29], 0x0a);
    // custom0_instr_wrapper(K[30], 0x09);
    // custom0_instr_wrapper(W[30], 0x0a);
    // custom0_instr_wrapper(K[31], 0x09);
    // custom0_instr_wrapper(W[31], 0x0a);
    // custom0_instr_wrapper(K[32], 0x09);
    // custom0_instr_wrapper(W[32], 0x0a);
    // custom0_instr_wrapper(K[33], 0x09);
    // custom0_instr_wrapper(W[33], 0x0a);
    // custom0_instr_wrapper(K[34], 0x09);
    // custom0_instr_wrapper(W[34], 0x0a);
    // custom0_instr_wrapper(K[35], 0x09);
    // custom0_instr_wrapper(W[35], 0x0a);
    // custom0_instr_wrapper(K[36], 0x09);
    // custom0_instr_wrapper(W[36], 0x0a);
    // custom0_instr_wrapper(K[37], 0x09);
    // custom0_instr_wrapper(W[37], 0x0a);
    // custom0_instr_wrapper(K[38], 0x09);
    // custom0_instr_wrapper(W[38], 0x0a);
    // custom0_instr_wrapper(K[39], 0x09);
    // custom0_instr_wrapper(W[39], 0x0a);
    // custom0_instr_wrapper(K[40], 0x09);
    // custom0_instr_wrapper(W[40], 0x0a);
    // custom0_instr_wrapper(K[41], 0x09);
    // custom0_instr_wrapper(W[41], 0x0a);
    // custom0_instr_wrapper(K[42], 0x09);
    // custom0_instr_wrapper(W[42], 0x0a);
    // custom0_instr_wrapper(K[43], 0x09);
    // custom0_instr_wrapper(W[43], 0x0a);
    // custom0_instr_wrapper(K[44], 0x09);
    // custom0_instr_wrapper(W[44], 0x0a);
    // custom0_instr_wrapper(K[45], 0x09);
    // custom0_instr_wrapper(W[45], 0x0a);
    // custom0_instr_wrapper(K[46], 0x09);
    // custom0_instr_wrapper(W[46], 0x0a);
    // custom0_instr_wrapper(K[47], 0x09);
    // custom0_instr_wrapper(W[47], 0x0a);
    // custom0_instr_wrapper(K[48], 0x09);
    // custom0_instr_wrapper(W[48], 0x0a);
    // custom0_instr_wrapper(K[49], 0x09);
    // custom0_instr_wrapper(W[49], 0x0a);
    // custom0_instr_wrapper(K[50], 0x09);
    // custom0_instr_wrapper(W[50], 0x0a);
    // custom0_instr_wrapper(K[51], 0x09);
    // custom0_instr_wrapper(W[51], 0x0a);
    // custom0_instr_wrapper(K[52], 0x09);
    // custom0_instr_wrapper(W[52], 0x0a);
    // custom0_instr_wrapper(K[53], 0x09);
    // custom0_instr_wrapper(W[53], 0x0a);
    // custom0_instr_wrapper(K[54], 0x09);
    // custom0_instr_wrapper(W[54], 0x0a);
    // custom0_instr_wrapper(K[55], 0x09);
    // custom0_instr_wrapper(W[55], 0x0a);
    // custom0_instr_wrapper(K[56], 0x09);
    // custom0_instr_wrapper(W[56], 0x0a);
    // custom0_instr_wrapper(K[57], 0x09);
    // custom0_instr_wrapper(W[57], 0x0a);
    // custom0_instr_wrapper(K[58], 0x09);
    // custom0_instr_wrapper(W[58], 0x0a);
    // custom0_instr_wrapper(K[59], 0x09);
    // custom0_instr_wrapper(W[59], 0x0a);
    // custom0_instr_wrapper(K[60], 0x09);
    // custom0_instr_wrapper(W[60], 0x0a);
    // custom0_instr_wrapper(K[61], 0x09);
    // custom0_instr_wrapper(W[61], 0x0a);
    // custom0_instr_wrapper(K[62], 0x09);
    // custom0_instr_wrapper(W[62], 0x0a);
    // custom0_instr_wrapper(K[63], 0x09);
    // custom0_instr_wrapper(W[63], 0x0a);

    // ctx->state[0] += custom0_instr_wrapper(0, 0, 0x06);
    // ctx->state[1] += custom0_instr_wrapper(0, 0, 0x07);
    // ctx->state[2] += custom0_instr_wrapper(0, 0, 0x08);
    // ctx->state[3] += custom0_instr_wrapper(0, 0, 0x09);
    // ctx->state[4] += custom0_instr_wrapper(0, 0, 0x0a);
    // ctx->state[5] += custom0_instr_wrapper(0, 0, 0x0b);
    // ctx->state[6] += custom0_instr_wrapper(0, 0, 0x0c);
    // ctx->state[7] += custom0_instr_wrapper(0, 0, 0x0d);
  
    // --------------------- End of using co-processor------------------------ //
}
static const HASH_VTAB SHA256_VTAB = {
    SHA256_init,
    SHA256_update,
    SHA256_final,
    SHA256_hash,
    SHA256_DIGEST_SIZE};
void SHA256_init(SHA256_CTX *ctx)
{
    ctx->f = &SHA256_VTAB;
    ctx->state[0] = 0x6a09e667;
    ctx->state[1] = 0xbb67ae85;
    ctx->state[2] = 0x3c6ef372;
    ctx->state[3] = 0xa54ff53a;
    ctx->state[4] = 0x510e527f;
    ctx->state[5] = 0x9b05688c;
    ctx->state[6] = 0x1f83d9ab;
    ctx->state[7] = 0x5be0cd19;
    ctx->count = 0;
}
void SHA256_update(SHA256_CTX *ctx, const void *data, int len)
{
    int i = (int)(ctx->count & 63);
    const uint8_t *p = (const uint8_t *)data;
    ctx->count += len;
    while (len--)
    {
        ctx->buf[i++] = *p++;
        if (i == 64)
        {
            SHA256_Transform(ctx);
            i = 0;
        }
    }
}
const uint8_t *SHA256_final(SHA256_CTX *ctx)
{
    uint8_t *p = ctx->buf;
    uint64_t cnt = ctx->count * 8;
    int i;
    SHA256_update(ctx, (uint8_t *)"\x80", 1);
    while ((ctx->count & 63) != 56)
    {
        SHA256_update(ctx, (uint8_t *)"\0", 1);
    }
    for (i = 0; i < 8; ++i)
    {
        uint8_t tmp = (uint8_t)(cnt >> ((7 - i) * 8));
        SHA256_update(ctx, &tmp, 1);
    }
    for (i = 0; i < 8; i++)
    {
        uint32_t tmp = ctx->state[i];
        *p++ = tmp >> 24;
        *p++ = tmp >> 16;
        *p++ = tmp >> 8;
        *p++ = tmp >> 0;
    }
    return ctx->buf;
}
/* Convenience function */
const uint8_t *SHA256_hash(const void *data, int len, uint8_t *digest)
{
    SHA256_CTX ctx;
    SHA256_init(&ctx);
    SHA256_update(&ctx, data, len);
    memcpy(digest, SHA256_final(&ctx), SHA256_DIGEST_SIZE);
    return digest;
}

// Function to print the hash as a hexadecimal string
// void print_hash(uint8_t hash[SHA256_DIGEST_SIZE]) {
//     for (int i = 0; i < SHA256_DIGEST_SIZE; i++) {
//         printf("%02x", hash[i]);
//     }
//     printf("\n");
// }

int main()
{
    const char *message = "Hello";

    IO_LED = 0x0;

    SHA256_hash((const uint8_t *)message, strlen(message), hash.hash32);

    // IO_LED = 0x55555555;
    // printf("SHA-256 Hash: ");
    // print_hash(hash.hash32);

    for (uint8_t i = 0; i < 8; i++)
    {
        // printf("%x\n",hash.hash8[i]);
        IO_LED = hash.hash8[i];
        io_buf_uint[i] = hash.hash8[i];
    }

    // unsigned int value = 0;
    // for (uint8_t i = 0; i < 32; i++)
    // {
    //     value = (value << 8) | hash[i];
    //     if (i % 4 == 3)
    //     {
    //         IO_LED = value;
    //         // printf("%02x\n",value);
    //         value = 0;
    //     }
    // }

    while (1)
    {
    }

    // return 0;
}