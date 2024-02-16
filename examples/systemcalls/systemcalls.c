#include "systemcalls.h"
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <errno.h>

/**List of helpful prior submission references:
  *ajsanthosh14 helped
  *mamo6538
  *MehulCUB
  *psk73
  *
*/
/**
 * @param cmd the command to execute with system()
 * @return true if the command in @param cmd was executed
 *   successfully using the system() call, false if an error occurred,
 *   either in invocation of the system() call, or if a non-zero return
 *   value was returned by the command issued in @param cmd.
*/
bool do_system(const char *cmd)
{

/*
 * TODO  add your code here
 *  Call the system() function with the command set in the cmd
 *   and return a boolean true if the system() call completed with success
 *   or false() if it returned a failure
*/

	int ret_value = system(cmd);
	//check to see if system was able to be completed
	if (ret_value != 0)
		return false;
	else
		return true;
}
/**
* @param count -The numbers of variables passed to the function. The variables are command to execute.
*   followed by arguments to pass to the command
*   Since exec() does not perform path expansion, the command to execute needs
*   to be an absolute path.
* @param ... - A list of 1 or more arguments after the @param count argument.
*   The first is always the full path to the command to execute with execv()
*   The remaining arguments are a list of arguments to pass to the command in execv()
* @return true if the command @param ... with arguments @param arguments were executed successfully
*   using the execv() call, false if an error occurred, either in invocation of the
*   fork, waitpid, or execv() command, or if a non-zero return value was returned
*   by the command issued in @param arguments with the specified arguments.
*/

bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];

/*
 * TODO:
 *   Execute a system command by calling fork, execv(),
 *   and wait instead of system (see LSP page 161).
 *   Use the command[0] as the full path to the command to execute
 *   (first argument to execv), and use the remaining arguments
 *   as second argument to the execv() command.
 *
*/	//printf("Count: %d \n", count);
	int status;
	pid_t pid;

	pid = fork();//create fork
	
	if (pid == -1)//fork not able to be created
	{
		//printf("77 PID: -1\n");
		return false;
	}
	else if (pid == 0)//Child process
	{
		//printf("83 PID: %d\n", pid);
		//printf("execv performed\n");
		int ret_value = execv(command[0], command);
		//printf("ret_value: %d \n", ret_value);
		
		if (ret_value == -1) //check if execv could execute
		{
			exit(-1);
		}	
	}
	
	else//Parent process
	{
		printf("WAITPID: %d\n", (waitpid (-1, &status, 0)));
		if(waitpid (-1, &status, 0) == -1)
		{
			if(WIFEXITED(status))
			{
				if(WEXITSTATUS(status))
				{
					return false;
				}
				else
					return true;
			}
			else 
				return false;
		}
	}
		
		
	
    va_end(args);

    return true;
}

/**
* @param outputfile - The full path to the file to write with command output.
*   This file will be closed at completion of the function call.
* All other parameters, see do_exec above
*/
bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];


/*
 * TODO
 *   Call execv, but first using https://stackoverflow.com/a/13784315/1446624 as a refernce,
 *   redirect standard out to a file specified by outputfile.
 *   The rest of the behaviour is same as do_exec()
 *
*/
	int status;
	pid_t pid;
	int fd = open(outputfile, O_WRONLY|O_TRUNC|O_CREAT, 0644);
	if (fd < 0) {perror("open");return false;}
	
	switch (pid = fork())
	{
	case -1: perror("fork"); return false;
	case 0:
		if (dup2(fd,1) < 0) { perror("dup2"); return false;}
		close(fd);
		execv(command[0], command); perror("execvp"); return false;
		
		//check
		//int ret_value = execv(command[0], command);
		//if (ret_value == -1)
		//{
			//return false;printf("186\n");
		//}
		//return false;	
	default:
		close(fd);
		if(waitpid (-1, &status, 0) == -1)//wait for any child process to end
		{
			if(WIFEXITED(status))//check if child terminated normally
			{
				if(WEXITSTATUS(status))//check exit status of child, only to be employed if WIFEXITED returned true
				{
					return false;
				}
				else
					return true;
			}
			else 
				return false;
		}
	}
    
    va_end(args);

    return true;
}
