/*
 * main file.cpp
 *
 *  Created on: 25 May 2019
 *      Author: ilg
 */


#include <iostream>

int
main(int argc, char* argv[])
{
	std::cout << "Hello World!" << std::endl;
	return 0;
}

extern "C" {
void __sync_synchronize() {}
}

