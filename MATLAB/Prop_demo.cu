//Compile method within MATLAB -> | nvcc -ptx -arch=sm_21 Prop_demo.cu'
 
#include "sgp4unit.cu"
 
//This function 
__global__ void PartPd_Kernel(double* ResultOut, int rows, int cols, int t,
	    double del, double* jdsatepoch, double* bstar,
        double* ecco, double* argpo, double* inclo, double* mo, double* no,
        double* nodeo, double* tse)
	{
    //Determine Thread Position in Grid
    double rowD = blockIdx.y * blockDim.y + threadIdx.y;
    double colD = blockIdx.x * blockDim.x + threadIdx.x;
	int row = (int) rowD;
	int col = (int) colD;
	gravconsttype whichconst = wgs72old;
	elsetrec satrec;
	
	
    
    //Ensure Excess Threads are not Evaluated
    if ((row < rows)&&(col < cols)){
		sgp4init(whichconst, 'i',  1,  jdsatepoch[col], bstar[col],
                  ecco[col],  argpo[col],  inclo[col],  mo[col],  no[col],
                  nodeo[col], satrec);
		double time = (tse[col]*1440) + ((t + rowD)*del);
		double ro[3];
		double vo[3];
		
		sgp4(whichconst, satrec, time, ro, vo);

        ResultOut[row + rows*(col+cols*0)] = ro[0];
		ResultOut[row + rows*(col+cols*1)] = ro[1];
		ResultOut[row + rows*(col+cols*2)] = ro[2];
    }
	
}


