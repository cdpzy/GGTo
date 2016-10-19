// ConsoleApplication1.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "xxtea.h"

unsigned char* getFileData(const char* filename, int* size) 
{
	*size = 0;
	FILE* fp = fopen(filename, "rb");
	if (nullptr == fp) {
		return nullptr;
	}

	fseek(fp, 0, SEEK_END);
	*size = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	unsigned char* buffer = nullptr;
	buffer = (unsigned char*)malloc(*size);
	*size = fread(buffer, sizeof(unsigned char), *size, fp);
	fclose(fp);

	return buffer;
}

int main(int argc, char* argv[])
{
	int size;
	auto buffer = getFileData(argv[1], &size);

	xxtea_long len = 0;
	auto signLen = strlen(argv[3]);
	auto keyLen = strlen(argv[4]);
	auto result = xxtea_decrypt(buffer + signLen,
								(xxtea_long)size - signLen,
								(unsigned char*)argv[4],
								(xxtea_long)keyLen,
								&len
								);
	FILE* fp = fopen(argv[2], "wb");
	fwrite(result, 1, size, fp);
	fclose(fp);

	return 0;
}

