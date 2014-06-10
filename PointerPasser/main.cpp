#include "libPassPointer.h"
#include <iostream>
#include <thread>
#include <unistd.h>
#include <string>

#define MSGLEN  64

//void Process_RX(int *fd)
void Process_RX(std::string &message)
{

	// Initialize the MATLAB Compiler Runtime global state
	if (!mclInitializeApplication(NULL,0)) 
	{
	std::cerr << "Could not initialize the application properly."
	  << std::endl;
	//return -1;
	}

	// Initialize the Vigenere library
	if( !libPassPointerInitialize() )
	{
	std::cerr << "Could not initialize the library properly."
	  << std::endl;
	//return -1;
	}

	// Must declare all MATLAB data types after initializing the 
	// application and the library, or their constructors will fail.

    	mwArray Pointer;
    	mwArray ExitPointer;
    	Pointer = mwArray("HelloFromC++");
    
	int k;
	//std::string message = "HelloFromRX";
	for (k=0;k<100000;k++){

        	WriteDataToPipe(1,ExitPointer,Pointer);
		//std::cout<<Pointer<<std::endl;
        	//write(fd[1], "HelloFromRX", 11);
	}

	// Shut down the library and the application global state.
	libPassPointerTerminate();
	mclTerminateApplication();
	//mxfree(objSDRuReceiver);
}



int main(){

//int	pid;
int     fd[2];
pid_t pid;
int     result;
std::string Message="Hello World\n";

//Creating a pipe
result = pipe (fd);
if (result < 0) {
	//failure in creating a pipe
	perror("pipe");
	exit (1);
}

//Creating a child process
pid = fork();
if (pid < 0) {
	//failure in creating a child
	perror ("fork");
	exit(2);
}
if (pid > 0) {
	pid = fork();
	if (pid > 0){
		std::cout<<"Parent"<<std::endl;
		char message[MSGLEN];
		while (1){
		    std::cout << "##################" << std::endl;
                    //Clearing the message buffer
                    memset (message, 0, sizeof(message));

                    //Reading message from the pipe
                    //read (fd[0], message, sizeof(message));
		    sleep(30);
		    std::cout<<Message<<std::endl;
                    printf("-- %s\n",message);
		    std::cout << "##################" << std::endl;
		}
		}
	else{
		std::cout<<"Child"<<std::endl;
		//Process_TX( fd );
	}
}
else if (pid == 0) {
	std::cout<<"Child"<<std::endl;
	//Process_RX( fd );
	Process_RX(Message);
}

return 0;

}



