// #define DEBUG_SAVE
// This version for ML-deconvolution expects a psf for every element given for reconstructing one image
// The measured projections have allready to be turned into the right postionens. The psfs have to be turned the same angles but centered

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
#include <new>
#include <time.h>
#include "fftarray.h"
#include "khoros.h"

#include "parseargs.h"
#include "window.h"

static clock_t lasttime;
static double totaltime;

static const int MaxPrjs=100;

// following objects are global, because they are too big to be on the main stack

typedef float          ArrayBType;

typedef TFFTArray<ArrayBType>  TAllArray; // All arrays have the same FFTabel format, so that they can be compared, divided, ...
typedef TArray3d<ArrayBType> TPSFArray; // All arrays have the same FFTabel format, so that they can be compared, divided, ...

// Images needed
static   TAllArray reconImg,BgImg;          // Zero as first guess  // Arra, ItsPos, ItsDir
static   TAllArray correctionImg,BgCor;     // will collect the correction information before the update is done
static   TAllArray ConstrainArr;      // If given, this image is multiplicated in every step with reconstruction image
  
static   TAllArray * measuredPrjs[MaxPrjs],  // holds the measured data
                    PatternArr[MaxPrjs];    // excitation patterns

static   TAllArray * OTFs[MaxPrjs];         // the OTFs

static   TAllArray reconPrj,tmpImg;          // Serves as data memory for computation of intermediate projection
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
  cerr << "usage: " << filename << " [-k] [-mX X ...] [-i inputfile] [-p psffile] [-o outputfile] [-c corrimage] [-fX X ...] [-n iterations]\n" << flush;
  cerr << "-mX X -mY Y -mZ Z :  X,Y,Z == sizes of measured projection\n";
  cerr << "-pX X -pY Y -pZ Z :  X,Y,Z == sizes of PSF\n";
  cerr << "-k : khoros data format flag\n";
  cerr << "-s file : file for starting iteration with\n";
  cerr << "-f file : file to save forward projection in\n";
  cerr << "-rW file : Width (Pixels) of edge blending window\n";
  cerr << "-mf relative maximal frequency (if <1.0 image will be restrained to this each step)\n";
  myexit(-1);
}


int main(int argc, char *argv[])
{
  int i,k,Elements=1,byte=0,min=0;
  double overrelax=1.0,MaxFreq=1.0,MaxZFreq=1.0,HFPercent=0.1;  // Measure Frequencies > 10% of max
  double WindowPixels=0.0;

  int kflag=0,IterNum=60,applywindow=0,noPSFnorm=0,PatternSeparation=0,EstimateBg=0;
  bool HolmesLiu=false;

  string IFileName, OFileName, CFileName, PFileName, OvFileName;  // Overralax-table
  string HFFileName, FFileName, SFileName, ConstrainFileName, PatternFileName, BgFileName;
  string IType="Float";

  int MEASUREDSizeX=256, MEASUREDSizeY=256, MEASUREDSizeZ=32;
  int PSFSizeX=256, PSFSizeY=256, PSFSizeZ=32;
  int SizeX=256, SizeY=256, SizeZ=32;

std::set_new_handler(&no_storage);

printCall(argc,argv);

char ** parg= & argv[1];
argc = 0; // to prevent warning

 while (* parg)
  {
   if (readArg("-pause", parg)) {dopause=1;continue;}
   if (readArg("-min", parg)) {min=1;continue;}
   if (readArg("-byte", parg)) {byte=1;continue;}
   if (readArg("-k",parg)) {kflag=1;continue;}
   // if (readArg("-norichardson",parg)) {norichardson=1;continue;}   // this is automatically set
   if (readArg("-noPSFnorm",parg)) {noPSFnorm=1;continue;}  // Do not normalize PSF
   if (readArg("-i", & IFileName, parg)) continue;
   if (readArg("-o", & OFileName, parg)) continue;
   if (readArg("-c", & CFileName, parg)) continue;
   if (readArg("-p", & PFileName, parg)) continue;
   if (readArg("-patterns", & PatternFileName, parg)) continue;   // Accounts for spatially variing excitation patterns
   if (readArg("-patsep",parg)) {PatternSeparation=1;continue;}
   if (readArg("-background",parg)) {EstimateBg=1;continue;}    // If selected a background estimation will be attempted
   if (readArg("-bgFile", & BgFileName, parg)) continue;   // will store the estimated Background (if -background was given)
   if (readArg("-constrain", & ConstrainFileName, parg)) continue;   // Image that will be multiplied with reconstruction
   if (readArg("-hf",& HFFileName, parg)) continue;   // File for High-Frequency Output
   if (readArg("-hfp",& HFPercent, parg)) continue;   // Percentage where high frequency measure starts
   if (readArg("-mX",& MEASUREDSizeX, parg)) continue;
   if (readArg("-mY",& MEASUREDSizeY,parg)) continue;
   if (readArg("-mZ",& MEASUREDSizeZ,parg)) continue;
   if (readArg("-pX",& PSFSizeX, parg)) continue;
   if (readArg("-pY",& PSFSizeY,parg)) continue;
   if (readArg("-pZ",& PSFSizeZ,parg)) continue;
   if (readArg("-rW",& WindowPixels,parg)) continue;
   if (readArg("-Over", & OvFileName, parg)) continue;  // relaxationtable (ascii-file with overralaxation values)
   if (readArg("-HolmesLiu",parg)) {HolmesLiu=true;continue;}
   if (readArg("-s", & SFileName, parg)) continue;  // start-file
   if (readArg("-f", & FFileName, parg)) continue;  // forward-file

   if (readArg("-mf",& MaxFreq, parg)) { applywindow=1;continue; }
   if (readArg("-mzf",& MaxZFreq, parg)) { applywindow=1;continue; }

   if (readArg("-n",& IterNum, parg)) continue;

   usage(argv[0]);
  }

 if (byte) IType="Unsigned Byte";
 if (IFileName=="") cerr << "Error : No input file given !\n",myexit(-1);
 if (OFileName=="") cerr << "Error : No output file given !\n",myexit(-1);
 if (PFileName=="") cerr << "Error : No psf file given !\n",myexit(-1);

 lasttime = clock();
 totaltime = 0.0;
 cout << " start CPU time is " << lasttime/(double) CLOCKS_PER_SEC << "  \n" << flush;
 
 int NPsf=1;
 Elements=1;
 int PElements=1;

 double NormFac=1.0;

 for (i=0;i<Elements;i++)
   {
     if (i >= MaxPrjs) cerr << "Error : Maximal projections number reached\n",myexit(-1);
     measuredPrjs[i]=new TAllArray;
       Elements=measuredPrjs[i]->DLoad(kflag,IFileName.c_str(),IType.c_str(),& MEASUREDSizeX,& MEASUREDSizeY,& MEASUREDSizeZ,i);    
     SizeX=MEASUREDSizeX;SizeY=MEASUREDSizeY;SizeZ=MEASUREDSizeZ;

     double MinVal;
     int minx,miny,minz;
     MinVal =  measuredPrjs[i]->MinPosReal(minx,miny,minz);
     if (min) 
	{
	     measuredPrjs[i]->Sub(MinVal);
	     cout << "Minimum  " << MinVal << " at " << minx<<"x" << miny << "x"<<minz << "was subtracted from data\n";
	}
     else if (measuredPrjs[i]->Minimum() < 0.0)
       {
	 cerr << "Warning : Measured data element " << i << " contains values < 0, clipping them to 0 !\n";
	 measuredPrjs[i]->ClipAt(0.0);  // avoid negative values in measured image !
       }
     //measuredPrjs[i]->DSave(kflag,"/tmp/xxx.kdf");
 
     if (PatternFileName!="") // accounts for patterned excitation
       {
	 // cout << "Loading Pattern Element " << i << "\n";
	 if (i < PElements)
	   PElements=PatternArr[i].DLoad(kflag,PatternFileName.c_str(),IType.c_str(),
					 & SizeX,& SizeY,& SizeZ,i);
	 
	 if ( ! (measuredPrjs[i]->GetSize(0) == PatternArr[i].GetSize(0) && 
		 measuredPrjs[i]->GetSize(1) == PatternArr[i].GetSize(1))) 
	   {
	     cerr << "Error : PatternImage size is different from InputSize !\n";
	     cerr << "Pattern Sizes: " << SizeX << " x " << SizeY << " x " << SizeZ << " x " << PElements<< "\n";
	     myexit(-1);
	   }
	 /* if (! PatternSeparation)
	   PatternArr[i].Normalize(MEASUREDSizeX*MEASUREDSizeY*MEASUREDSizeZ);  // Necessary for stability
	 else
	   if (i == 0)
	     NormFac=PatternArr[0].Normalize(1.0);  // Necessary for stability
	   else
	   PatternArr[i].Mul(NormFac);  // Necessary for stability 
	   */
       }
   }
 
 if (ConstrainFileName!="") // will be multiplied with every reconstructed image
   {
     ConstrainArr.DLoad(kflag,ConstrainFileName.c_str(),IType.c_str(),& SizeX,& SizeY,& SizeZ);
     
     if ( ! measuredPrjs[0]->SizesEqual(& ConstrainArr))
       {
	 cerr << "Error : ConstrainImage size is different from InputSize !\n";
	 myexit(-1);
       }
   }


 double innerborder=1.0-(2*WindowPixels/MEASUREDSizeX);
 GaussWindow<TAllArray> BorderWin(innerborder,1.0,innerborder,1.0,innerborder,1.0,
				  true,false);  // rectangular Gaussian window, no ring shape
 BorderWin.gaussstretch=0.7;
 
 if (WindowPixels > 0)
   for (i=0;i<Elements;i++)
     {
       BorderWin.ApplyWindow(measuredPrjs[i]);
     }
 
 SinWindow<TAllArray> FreqWin(MaxFreq-0.15,MaxFreq+0.15,
			   MaxFreq-0.15,MaxFreq+0.15,
			   MaxZFreq-0.15,MaxZFreq+0.15,false,false);  // elliptical Sinusoidal window
 
 
 TPSFArray * Psf = new TPSFArray();

 NormFac=1.0;
 NPsf=1;
 for (i=0;i< NPsf;i++)
   {
     if (i >= MaxPrjs) cerr << "Error : Maximal psf number reached\n",myexit(-1);
     if (i >= Elements)
       {
	 cerr << "Warning ! Too many Psfs given using only Psf up to #" << i-1 <<" \n"; break;
       }
     
     NPsf=Psf->DLoad(kflag,PFileName.c_str(),IType.c_str(),& PSFSizeX,& PSFSizeY,& PSFSizeZ,i);
     
     if ( ! measuredPrjs[0]->SizesEqual(Psf))
       {
	 cerr << "Warning : PSF size is different from InputSize !\n";
	 cerr << "Measured : " << MEASUREDSizeX << "x" << MEASUREDSizeY << "x" << MEASUREDSizeZ << ",  PSF: "<< PSFSizeX << "x" << PSFSizeY << "x" << PSFSizeZ <<"\n";
	 cerr << "Zero-Padding PSF !\n";
       }
     
     if (Psf->Minimum() < 0.0)
       {
	 cerr << "Warning : PSF contains values < 0, clipping them to 0 !\n";
	 Psf->ClipAt(0.0);  // avoid PSF having negative values
       }

     OTFs[i]= new TAllArray(MEASUREDSizeX,
			    MEASUREDSizeY,
			    MEASUREDSizeZ);
     
     OTFs[i] -> Clear();
     
     Copy(Psf,OTFs[i]);       // centered copy algorithm
     
     cout << "Computing OTF #"<<i<<"\n";
     
     // To get the integral intensity correct use following normalization : (0-freq == 1.0 +0*i)
     if (PatternSeparation)
       {
	 cerr << "\nWARNING: PatternSeparation was used, but PSFs shall be individually normalized! Does not make sense: Changing to NOPSFNORM!\n\n";
	 noPSFnorm = true;
	 cout << "PatternSeparation was selected. Ignoring NoPSFNorm, normalizing first PSF\n";
	 if (i == 0)
	   NormFac=OTFs[0]->Normalize(1.0/(MEASUREDSizeX*MEASUREDSizeY*MEASUREDSizeZ));  // Necessary for stability
	 else
	   OTFs[i]->Mul(NormFac);  // Necessary for stability
       }
     else
       if (! noPSFnorm)
	 OTFs[i]->Normalize(1.0/(MEASUREDSizeX*MEASUREDSizeY*MEASUREDSizeZ));  // Does contain psf at this moment
       else
	 OTFs[i]->Mul(1.0/(MEASUREDSizeX*MEASUREDSizeY*MEASUREDSizeZ));  // Assume, that one PSF is allready normalized
     // Normalization is special, since it accounts for the optimized factors during FFTs
     // doing the fft with "true" needs Mul(sqrt(X*Y*Z));

     // cout << ".. normalized\n"<<flush;
     OTFs[i]->scramble(1);     // Move center to the edge
     // cout << ".. scrambled\n"<<flush;
     OTFs[i]->FFTfwd(false);          // Generate OTF
     // cout << ".. fft-ed\n"<<flush;
     
     if (applywindow)  // restrict PSF to low frequencies
       {
	 FreqWin.ApplyWindow(OTFs[i],false);  // may generate small negative numbers in PSF !
       }
     // cout << ".. windowed\n"<<flush;
   }

 if (PatternSeparation && ! (PatternArr[0].GetSize(2) == NPsf))
   {
     cerr << "Error : PatternSeparation was sected but number of 2D patterns (Z-direction of pattern file) does not match number of PSFs (elements)!\n";
     cerr << "Patterns " << PatternArr[0].GetSize(2) << ", PSFs " << NPsf<< "\n";
     myexit(-1);
   }
 
 if (! PatternSeparation)
   {
     if (NPsf < Elements)
       cerr << "Warning ! Fewer Psf s than measured datasets ! using Psf #0 for missing Psfs ! \n";

     for (i=NPsf;i<Elements;i++)
       OTFs[i]= OTFs[0];
     // cout << ".. OTF copied\n"<<flush;
   }
 
 delete(Psf); // not needed any more
     // cout << ".. deleted\n"<<flush;
 
 reconImg.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);
 if (EstimateBg)
   {
     BgImg.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);
     BgCor.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);
   }
 correctionImg.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);  
 reconPrj.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);
 if (PatternSeparation)
   tmpImg.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);
 
 cout << "Starting Reconstruction .. \n";
 
 // Generate the Forwardfile
 ofstream to;
 
 
 reconImg.Set(1.0); // Only accessible measured parts are important
 if (EstimateBg)
   {
     BgImg.Set(0);
     BgCor.Clear();
   }
 
 reconPrj.Clear();
 
 if (SFileName!="")
   {
     int sx=MEASUREDSizeX,sy=MEASUREDSizeY,sz=MEASUREDSizeZ;
     reconImg.DLoad(kflag,SFileName.c_str(),IType.c_str(),&sx,&sy,&sz);
     
     if (! measuredPrjs[0]->SizesEqual(& reconImg)) 
       cerr << "Error : StartImage has wrong sizes ! \n", myexit(-1);
   }
 else
   reconImg.Set(1.0);
 
 FILE * overfile=0,* hffile=0;
 
 if (OvFileName!="")
   {
     if (! (overfile=fopen(OvFileName.c_str(),"r"))) cerr << "Error opening File " << OvFileName.c_str() << "\n",myexit(-1);
   }
 
 if (HFFileName!="")
   {
     if (! (hffile=fopen(HFFileName.c_str(),"w"))) cerr << "Error opening File " << HFFileName.c_str() << "\n",myexit(-1);
   }
 
 overrelax = 1.0;
 cout << "Starting first iteration \n";
 for (i=1;i < IterNum+1;i++)
   {
     if (FFileName!="")   // write a new fwd-projectionfile
       {
	 to.open(FFileName.c_str());
	 
	 if (! to )
	   {
	     cerr << "Couldn't open file " << FFileName.c_str() << " for writing !!\n" << flush;
	     myexit(-1);
	   }
	 
	 ArrayBType dummy;
	 
	 if (kflag) 
	   WriteKhorosHeader(& to,"Generated by Reconstruction Set 1997",TypeString(dummy),MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ,Elements);
	 cerr << "writing file " << FFileName.c_str() << " \n" << flush;
	 
       } 
     
     if (! HolmesLiu)
       {
	 if (! overfile)
	   {
	     overrelax=1.0;
	     
	     if (i > 100) overrelax=1.0; 
	   }
	 else
	   fscanf(overfile,"%lf",&overrelax);
       }
     
     
     
     correctionImg.Clear();
     
     double likelihoodsum = 0.0,likelihood=0.0;
     if (hffile)
       fprintf(hffile,"%d\t%g\t",i,overrelax);

     int SepPatterns=1;
     if (PatternSeparation)
       SepPatterns=NPsf;

     for (k=0;k<Elements;k++)
       {
	 for (int pat=0;pat<SepPatterns;pat++)
	   {
	     reconPrj.Copy(& reconImg);  // just transfer it into the tmp
	     if (! PatternSeparation)
	       {
		 if (PatternFileName!="") // account for patterned excitation
		   reconPrj.Mul(&PatternArr[k % PElements]);
	       }
	     else
	       if (PatternFileName!="") // account for separable patterns
		 reconPrj.PlaneMul(&PatternArr[k % PElements],pat); // multiplies the whole stack with the pat's plane in the PatternArr
	     
	     reconPrj.FFTfwd(false);        // Now do first half of convolution with PSF

	     if (! PatternSeparation)
	       reconPrj.ConvMul(OTFs[k]);
	     else
	       reconPrj.ConvMul(OTFs[pat]);  // These contain the Z-multiplications of the patterns

	     if (PatternSeparation)
	       if (pat==0)
		 tmpImg.Copy(& reconPrj);  // transfer it into the tmp for accumulation
	       else
		 tmpImg.Add(& reconPrj);  // sum results in tmp
	     // cout << "Elem: " << k << ", pattern: " << pat << "\n";
	   }
	 if (PatternSeparation)
	   reconPrj.Copy(& tmpImg);  // transfer it back. Can be optimized away ...

	 reconPrj.FFTbwd(false);        

	 if (EstimateBg)
	   if (k==0)                   // The next estimate is allways the difference Mi - Simulated(without addition)
	     {
	       BgCor.Copy(measuredPrjs[k]);
	       BgCor.Sub(& reconPrj);
	     }
	   else
	     {
	       BgCor.Add(measuredPrjs[k]);
	       BgCor.Sub(& reconPrj);
	     }

	 if (EstimateBg)
	   reconPrj.Add(& BgImg);

	 if (FFileName!="")   
	   reconPrj.Write(& to);

	 if (hffile)
	   {
	     likelihood=reconPrj.ArgDivSelfLogLikelihood(measuredPrjs[k]);
	     likelihoodsum += likelihood;
	     fprintf(hffile,"%g\t",likelihood);
	   }
	 else
	   reconPrj.ArgDivSelfM1(measuredPrjs[k]);   // Needs minus one here !

	 reconPrj.FFTfwd(false);        // Now convolve with PSF, roominversion is done below
	 if (PatternSeparation)
	   tmpImg.Copy(& reconPrj);  // transfer it into the tmp for accumulation
	 for (int pat=0;pat<SepPatterns;pat++)
	   {
	     if (PatternSeparation && pat > 0)
	       reconPrj.Copy(& tmpImg);  // restore the FFT
	     if (! PatternSeparation)
	       reconPrj.ConvMul(OTFs[k],true); // complex conjugate OTF, to invert room dimensions of PSF
	     else
	       reconPrj.ConvMul(OTFs[pat],true);  // These contain the Z-multiplications of the patterns
	     // pulling this out of the loop makes it faster for multiple elements
	     if (applywindow)   // because of multiplicative algorithm HF can emerge !!
	       {
		 cout << " restraining frequencies ...\n";
		 FreqWin.ApplyWindow(& correctionImg,false);
		 reconImg.DSave(kflag,"/tmp/1.kdf");
	       }
	     reconPrj.FFTbwd(false); 
	     
	     if (! PatternSeparation)
	       {
		 if (PatternFileName!="") // account for patterned excitation
		   reconPrj.Mul(&PatternArr[k % PElements]);
	       }
	     else
	       if (PatternFileName!="") // account for separable patterns
		 reconPrj.PlaneMul(&PatternArr[k % PElements],pat); // multiplies the whole stack with the pat's plane in the PatternArr

	     correctionImg.Add(& reconPrj);  // this work, because a complex is two reals . Addition works on real and imaginary part
	   }
       }

     if (hffile)
       {
	 fprintf(hffile,"%g\n",likelihoodsum);
       }
     
     // correctionImg.FFTbwd(false); 

     if (HolmesLiu)
       {
	 double maxsum=-1e30;
	 overrelax=0.5;  // will be set to 1.0 in the first step
	 likelihoodsum = -1e29;
	 while (likelihoodsum > maxsum)
	 {
	   maxsum = likelihoodsum;
	   overrelax *= 2.0;
	   likelihoodsum = 0.0;
	   for (k=0;k<Elements;k++)
	     {
	       for (int pat=0;pat<SepPatterns;pat++)
		 {
		   reconPrj.Copy(& reconImg);  // just transfer it into the tmp
		   if (! PatternSeparation)
		     {
		       if (PatternFileName!="") // account for patterned excitation
			 reconPrj.Mul(&PatternArr[k % PElements]);
		     }
		   else
		     if (PatternFileName!="") // account for separable patterns
		       reconPrj.PlaneMul(&PatternArr[k % PElements],pat); // multiplies the whole stack with the pat's plane in the PatternArr
		   
		   // reconPrj.ClipAt(0.000001);    // Constraint to prevent impossible overrelaxiations : Now done below !
		   reconPrj.MulSelfAdd(& correctionImg,float(overrelax)/float(Elements));        // Apply correction. Is /float(Elements) needed?
		   // reconPrj.MulMinusSelfAdd(& correctionImg,float(overrelax) / float(Elements), float(Elements));        // Apply correction
		   reconPrj.FFTfwd(false);        // Now do first half of convolution with PSF
		   
		   if (! PatternSeparation)
		     reconPrj.ConvMul(OTFs[k]);
		   else
		     reconPrj.ConvMul(OTFs[pat]);  // These contain the Z-multiplications of the patterns
		   
		   if (PatternSeparation)
		     if (pat==0)
		       tmpImg.Copy(& reconPrj);  // transfer it into the tmp for accumulation
		     else
		       tmpImg.Add(& reconPrj);  // sum results in tmp
		 }
	       if (PatternSeparation)
		 reconPrj.Copy(& tmpImg);  // transfer it back. Can be optimized away ...
	       
	       reconPrj.FFTbwd(false);        
	       if (EstimateBg)
		 reconPrj.Add(& BgImg);
	       
	       likelihoodsum+=reconPrj.ArgDivSelfLogLikelihood(measuredPrjs[k]);
	     }
	   printf("overrelax : %g\t likelihoodsum: %g\n",overrelax,likelihoodsum);
	 }
	 overrelax /= 2.0;  // because last step was unsucessful
       }
     
     cout << "Iteration Nr. " << i <<", Overrelaxation Factor is " << overrelax << "  \n";
     if (! EstimateBg)
       reconImg.MulSelfAdd(& correctionImg,float(overrelax)/float(Elements));        // Apply correction. Is /float(Elements) needed?
     // reconImg.MulMinusSelfAdd(& correctionImg,float(overrelax) / float(Elements), float(Elements));        // Apply correction
     // also clips at 0.000001
     if (EstimateBg)
       {
	 if (i%4 == 0)
	   {
	     BgImg.Copy(&BgCor);
	     BgImg.Mul(1.0/float(Elements));  // To get the mean
	     // BgImg.MulMinusSelfAdd(&BgCor,0.2* float(overrelax) / float(Elements), float(Elements));
	     BgImg.ClipAt(0.000001);    // Constraint 
	     if (BgFileName!="")
	       {
		 BgImg.DSave(kflag,BgFileName.c_str());
		 BgCor.DSave(kflag,"/tmp/BgCor.kdf");
	       }
	   }
	 else
	   reconImg.MulSelfAdd(& correctionImg,float(overrelax)/float(Elements));        // Apply correction. Is /float(Elements) needed?
	 // reconImg.MulMinusSelfAdd(& correctionImg,float(overrelax) / float(Elements), float(Elements));        // Apply correction
       }

     if (ConstrainFileName!="")
       {
	 cout << " constraining image ...\n";
	 reconImg.Mul(&ConstrainArr);
       }
     // reconImg.ClipAt(0.000001);    // Constraint to prevent impossible overrelaxiations
     
     reconImg.DSave(kflag,OFileName.c_str());
     if (CFileName!="")
       correctionImg.DSave(kflag,CFileName.c_str());

     if (FFileName!="")
       to.close();


     totaltime += (clock()-lasttime)/double(CLOCKS_PER_SEC);
     lasttime = clock();
     cout << " used CPU time is " << totaltime << "  \n" << flush;
   } 
 if (hffile) fclose(hffile);
  int dummy;
  if (dopause) scanf("%d",&dummy);

 return 0;
}


