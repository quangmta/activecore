#include <string.h>
#include "io.h"
#include "md5.h" 


int main()
{
	char* testStr = "Hello World!";
	int length = strlen(testStr);
	IO_LED = 0x00;
	md5s result = md5(testStr, length);

	for ( int i = 0; i < 4; ++i ){
		IO_LED = result.v[i];
		io_buf_uint[i] = result.v[i];
	}

	IO_LED = 0x55555555;
        
    while (1) {}
}