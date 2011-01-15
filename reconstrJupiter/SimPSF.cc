// simPSF.cc : Simulates a high-NA PSF (confocal and non-confocal)

/*   This file is part of a software package written by 
     Rainer Heintzmann
     Institute of Applied Optics and Information Processing
     Albert Ueberle Strasse 3-5
     69120 Heidelberg
     Tel.: ++49 (0) 6221  549264
     Current Address : Max Planck Inst. for Biophysical Chemistry, Am Fassberg 11, 37077 Goettingen, Germany
     Tel.: ++49 (0) 551 201 1029, e-mail: rheintz@gwdg.de  or rainer@heintzmann.de
     No garantee, whatsoever is given about functionallaty and  savety.
     No warranty is taken for any kind of damage it may cause.
     No support for it is provided !

     THIS IS NOT FREE SOFTWARE. All rights are reserved, and the software is only
     given to a limited number of persons for evaluation purpose !
     Please do not modify and/or redistribute this file or any other files, libraries
     object files or executables of this software package !
*/

#include <iostream>
#include "rawarray.h"
#include "parseargs.h"
extern "C" {
#include "ir.h"
}
#include <complex>
#include <string>

using namespace std;

typedef float ArrayBType;
typedef TArray3d<ArrayBType> TImgArray;
typedef TArray3d<complex<float> > TCImgArray;
int dopause=0;


int myexit(int num)
{
  char dummy;
  if (dopause) 
	{
  	cerr << "Terminating Program, please press any key to proceed\n";
	scanf("%c",&dummy);
	}
  exit(num);
}

void no_storage()
{
  cerr << "Error: Not enough storage available to allocate all arrays.\n";
  myexit(-1);
}

void usage(char * filename)
{
  cerr <<  "usage: " << filename << " [-k] -o outputfile [-sX SizeX] [-sY SizeY] [-sZ SizeZ] [-confocal] [-computeASF] [-circPol] [-scalarTheory] [-Pi4Ex] [-Pi4Em] [-twophoton] [-scaleX val] [-scaleY val] [-scaleZ val] [-na val] [-ri refractiveIndex] [-lambdaEx val] [-lambdaEm val] [-pimhole Airyval]\n" << flush;
  exit(-1);
}

int main(int argc, char *argv[])
{ 

static int kflag=0,SizeX=64,SizeY=64,SizeZ=64,Normalize=1;
static double lambdaEx=488,lambdaEm=520,na=1.2,ri=1.33, ScaleX=78,ScaleY=78,ScaleZ=162, tolerance=0.01, pinhole=1.0,relExPhase=0.0,relExInt=1.0,relEmPhase=0.0,relEmInt=1.0;
bool confocal = false, computeASF = false, circPol=false, ScalarTheory=false, Pi4Ex=false,Pi4Em=false,twophoton=false;

string OFileName;

char ** parg= & argv[1];
argc=0;  // to prevent warning

std::set_new_handler(&no_storage);

 while (* parg)
  {
   if (readArg("-pause", parg)) {dopause=1;continue;}
   if (readArg("-k",parg)) {kflag=1;continue;}
   if (readArg("-confocal",parg)) {confocal=true;continue;}
   if (readArg("-nonorm",parg)) {Normalize=0;continue;}  // Currently only useful for confocal data
   if (readArg("-computeASF",parg)) {computeASF=true;continue;}
   if (readArg("-circPol",parg)) {circPol=true;continue;}
   if (readArg("-scalarTheory",parg)) {ScalarTheory=true;continue;}
   if (readArg("-Pi4Ex",parg)) {Pi4Ex=true;continue;}
   if (readArg("-relExPhase", & relExPhase, parg)) continue;   // relative phase of second beam
   if (readArg("-relExInt", & relExInt, parg)) continue;  // relative intensity of second beam
   if (readArg("-Pi4Em",parg)) {Pi4Em=true;continue;}
   if (readArg("-relEmPhase", & relEmPhase, parg)) continue;   // relative phase of second beam
   if (readArg("-relEmInt", & relEmInt, parg)) continue;  // relative intensity of second beam
   if (readArg("-twophoton",parg)) {twophoton=true;continue;}
   if (readArg("-sX", & SizeX, parg)) continue; 
   if (readArg("-sY", & SizeY, parg)) continue;
   if (readArg("-sZ", & SizeZ, parg)) continue;
   if (readArg("-scaleX", & ScaleX, parg)) continue; // pixels distances
   if (readArg("-scaleY", & ScaleY, parg)) continue;
   if (readArg("-scaleZ", & ScaleZ, parg)) continue;
   if (readArg("-o", OFileName, parg)) continue;
   if (readArg("-na",& na,parg)) continue;    // Numerical aperture
   if (readArg("-ri",& ri,parg)) continue;    // Refraction index
   if (readArg("-lambdaEx",& lambdaEx,parg)) continue;    // excitation wavelength
   if (readArg("-lambdaEm",& lambdaEm,parg)) continue;    // emission wavelength
   if (readArg("-pinhole",& pinhole,parg)) continue;    // projected pinhole diameter (Airy units)
    usage(argv[0]);
  } 

 pinhole *= 2.0 * 0.61 * (lambdaEx +lambdaEm)/2.0 / na;
 if (confocal)
   cout << "Pinhole-diameter was " << pinhole << " nm \n";

 ir_Error error = IR_OK;
 ir_Image *psf = 0, * psfx = 0, *psfy=0, *psfz=0;
 int dimensionality, dimensions[3];


  if (OFileName == "") 
    usage(argv[0]);

  dimensions[0]=SizeX;
  dimensions[1]=SizeY;
  dimensions[2]=SizeZ;
  dimensionality = dimensions[2] > 2 ? 3 : 2;
 
  if (confocal)
    {
         error=ir_Init(&psf);
         if (error != IR_OK)
         cerr << "Error in initializing library\nError "<< error << "\n",myexit(-1);

         error=ir_ImageChange(psf, dimensionality, dimensions, IR_TYPE_IMAGE);
         if (error != IR_OK)
         cerr << "Error in creating PSF image!Error "<< error << "\n",myexit(-1);

	 cout << "Computing confocal PSF \n" << flush ;
	 if (computeASF)
	   cerr << "Confocla ASF currently not implemented !",myexit(-1);
      error=ir_ConfocalPSF(psf, ScaleX, ScaleY, ScaleZ, lambdaEx, lambdaEm, na, ri, pinhole, tolerance, Pi4Ex,Pi4Em, Normalize, twophoton,relExInt,relExPhase,relEmInt,relEmPhase,ScalarTheory);
      if (error != IR_OK)
	cerr << "Error in computing confocal PSF image!Error "<< error << "\n",myexit(-1);
    }
  else
    {
        if (computeASF)
        {
                dimensions[0] *= 2;   // has to account for complex numbers
                error=ir_Init(&psfx);
                error=ir_Init(&psfy);
                error=ir_Init(&psfz);
               if (error != IR_OK)
                cerr << "Error in initializing library\nError "<< error << "\n",myexit(-1);

              error=ir_ImageChange(psfx, dimensionality, dimensions, IR_TYPE_IMAGE);
              error=ir_ImageChange(psfy, dimensionality, dimensions, IR_TYPE_IMAGE);
              error=ir_ImageChange(psfz, dimensionality, dimensions, IR_TYPE_IMAGE);
              if (error != IR_OK)
                cerr << "Error in creating PSF image!Error "<< error << "\n",myexit(-1);

                error=ir_WidefieldASF(psfx,psfy,psfz, ScaleX, ScaleY, ScaleZ, lambdaEm, na, ri, tolerance, circPol, ScalarTheory, Pi4Em);
                if (error != IR_OK)
	cerr << "Error in computing widefield PSF image!Error "<< error << "\n",myexit(-1);
        }
        else  // Widefield PSF
        {
                 error=ir_Init(&psf);
                  if (error != IR_OK)
                  cerr << "Error in initializing library\nError "<< error << "\n",myexit(-1);

                  error=ir_ImageChange(psf, dimensionality, dimensions, IR_TYPE_IMAGE);
                  if (error != IR_OK)
                  cerr << "Error in creating PSF image!Error "<< error << "\n",myexit(-1);

                error=ir_WidefieldPSF(psf, ScaleX, ScaleY, ScaleZ, lambdaEm, na, ri, tolerance, Pi4Em, relEmInt, relEmPhase,ScalarTheory);
                if (error != IR_OK)
	cerr << "Error in computing widefield PSF image!Error "<< error << "\n",myexit(-1);
        }
    }

    if (computeASF && ! confocal)
    {
          TCImgArray * Img= new TCImgArray((complex<float> *)(psfx->data),SizeX,SizeY,SizeZ);
          ofstream * oi=new ofstream(OFileName.c_str());
         if (! oi)
               cerr << "Error ! Couldnt open " << OFileName << " for writing !! \n",myexit(-1);
         int Elements=3;
         if (ScalarTheory) Elements=1;
         Img->DHeader(kflag,* oi,Elements);
         Img->Write(oi);
         if (! ScalarTheory)
         {
                Img= new TCImgArray((complex<float> *)(psfy->data),SizeX,SizeY,SizeZ);  // overwrite, no garbage collection
                 Img->Write(oi);
                 Img= new TCImgArray((complex<float> *)(psfz->data),SizeX,SizeY,SizeZ);  // overwrite, no garbage collection
                 Img->Write(oi);
        }
         oi->close();
    }
        else
    {
          TImgArray Img(psf->data,SizeX,SizeY,SizeZ);
          Img.DSave(kflag,OFileName.c_str());
    }

  /*int i=0;
  for (z=0;z < SizeZ; z++)
    for (y=0;y < SizeY; y++)
      for (x=0;x < SizeX; x++, i++)
      Img.SetValue(x,y,z,psf->data[i]);*/

}
