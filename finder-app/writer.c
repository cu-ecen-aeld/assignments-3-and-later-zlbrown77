#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	openlog("myLog", 0, LOG_USER);
	//error catch for empty inputs
	if(argc < 2){
		printf("Error, not enough inputs");
		exit(1);
	}
	else if(argv[2] == ""){
	 	exit(1);
	 	printf("Error, empty text input");
	 	syslog(LOG_ERR, "Error, empty text input");	
	}
	//error catch for empty inputs
	else if(argv[1] == ""){
		exit(1);
		printf("Error, empty path input");
		syslog(LOG_ERR, "Error, empty path input");
	}
	FILE *f;
	f = fopen(argv[1], "w");
		//error catch for file constructor error
		if(f == NULL)
		{
			printf("Error, file path not specified\n");
			syslog(LOG_ERR, "Error, file path not specified");
			exit(1);
		}
		else{
			//printf("Writing %s to %s", argv[2], argv[1]);
			syslog(LOG_DEBUG, "Writing %s to %s", argv[2], argv[1]);
			
		}
	
		//write input to file
		fputs(argv[2], f);
		fclose(f);
	
	//check to see if file exists
	if (access(argv[1], F_OK) == 0)
	{
		return 0;
	}
	else
	{
		printf("Error, file couldn't be created");
		syslog(LOG_ERR, "Error, file couldn't be created");
		exit(1);
	}
	return 0;

	closelog();
}
