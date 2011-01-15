
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

// correlator : this programm correlates the second input image and alligns it to the first.
// optional a intensity correction can also be computed
#include <iostream>
#include "parseargs.h"
#include "rawarray.h"
#include "fftarray.h"

typedef float ArrayBType;
typedef complex<float> ArrayBCType;


typedef TFFTArray<ArrayBType>  TImgArray; // All arrays have the same FFTabel format, so that they can be compared, divided, ...
typedef TFFTArray<ArrayBCType>  TImgCArray; // All arrays have the same FFTabel format, so that they can be compared, divided, ...

TImgArray InputImg,OutputImg,PlaneImg;
TImgCArray CImg1,CImg2,CImg3,CImg1Pow;

void usage(char * filename)
{
  cerr <<  "usage: " << filename << " [-k] [-iX X ...] [-i1 inputfile] [-i2 inputfile2] [-o outputfile] [-s]\n" << flush;
  cerr <<  "[-iX -iY -iZ]  : sizes of images\n" << flush;
  cerr <<  "[-e] :           Number of elements in second image\n" << flush;
  cerr <<  "[-k] :           use KDF format for in- and output \n" << flush;
  cerr <<  "[-s] :           also scale second image to match first\n" << flush;
  exit(-1);
}



int main(int argc, char *argv[])
{ 

int SizeX=32;  // These is the standart size, if raw data is used
int SizeY=32;  
int SizeZ=32; 
int SizeX1=32;  // These is the standart size, if raw data is used
int SizeY1=32;  
int SizeZ1=32; 
int Elements=1;

double factor=1.0,offset=0.0,phases=0.0,
        maxreldist = 0.0, maxreldistz = 0.0,  // 0.0 means do not apply maxreldist
        screamlimit = 0.0, exponent = 1.0, gaussf=0.0, gaussfz=1e20;

int Elem, range=1, steps=1, FixPlane = -1;
bool kflag=false,scale=false,IndividualScale=false,IndividualShifts=false,onlyoffset=false,
     withprevelem=false,plane=false,noshifts=false,forceplane=false,ReferenceIsFixed=false,zflipadd=false;

string  IFileName,I2FileName,I3FileName,OFileName,VFileName;

char ** parg= & argv[1];
argc=0;  // to prevent warning

 while (* parg)
  {
   if (readArg("-k",parg)) {kflag=true;continue;}
   if (readArg("-iscale",parg)) {IndividualScale=true;continue;}
   if (readArg("-zflipadd",parg)) {zflipadd=true;continue;}
   if (readArg("-onlyoffset",parg)) {onlyoffset=true;continue;}
   if (readArg("-ishifts",parg)) {IndividualShifts=true;continue;}
   if (readArg("-noshifts",parg)) {noshifts=true;continue;}
   if (readArg("-withprevelem", parg)) {withprevelem=true; continue;}  // correlate with previously (shifted) element
   if (readArg("-plane",parg)) {forceplane=true;continue;}
   if (readArg("-fixplane",& FixPlane, parg)) {forceplane=true; ReferenceIsFixed=true; continue;}
   if (readArg("-s",parg)) {scale=true;continue;}  // integrate in source image
   if (readArg("-p",parg)) {plane=true;continue;}  // shift only planes
   if (readArg("-phases",& phases, parg)) continue;  // factor of phase enhancement
   if (readArg("-expon",& exponent, parg)) continue;
   if (readArg("-i1",  IFileName, parg)) continue;
   if (readArg("-i2",  I2FileName, parg)) continue;
   if (readArg("-i3",  I3FileName, parg)) continue;
   if (readArg("-o",  OFileName, parg)) continue;
   if (readArg("-v",  VFileName, parg)) continue;
   if (readArg("-iX",& SizeX,parg)) continue; // input size X
   if (readArg("-iY",& SizeY,parg)) continue;
   if (readArg("-iZ",& SizeZ,parg)) continue;
   if (readArg("-e",& Elements,parg)) continue;
   if (readArg("-r",& range,parg)) continue;
   if (readArg("-gf",& gaussf,parg)) continue;  // lowpass gaussfilter distance to border in XY
   if (readArg("-gfz",& gaussfz,parg)) continue;  // lowpass gaussfilter distance to border in Z
   if (readArg("-md",& maxreldist,parg)) continue;  // maximal distance to border in XY, that is admitted for valid shifts
   if (readArg("-mdz",& maxreldistz,parg)) continue;  // maximal distance to border in Z, that is admitted for valid shifts
   if (readArg("-sl",& screamlimit,parg)) continue;  // if the final distance is bigger than this, the program ends with exit(-1)
   if (readArg("-steps",& steps,parg)) continue;
    usage(argv[0]);
  }            

 if (noshifts) plane=false;

 ofstream to(OFileName.c_str());
 ofstream * vfp=0;  // Vector File Pointer

 if (VFileName != "")
  if (! (vfp= new ofstream(VFileName.c_str())))
      cerr << "Could not open Vector output file " << VFileName << " !\n",exit(-1);
      

 Elements=1;
 int I1Elements=0;

 if (withprevelem)  // copy the FFT to the Img dataset and conjugate
   InputImg.DLoad(kflag,I2FileName.c_str(),"Float",& SizeX,& SizeY, & SizeZ,0);
 else
   I1Elements=InputImg.DLoad(kflag,IFileName.c_str(),"Float",& SizeX,& SizeY, & SizeZ);

 OutputImg.Resize(SizeX,SizeY,SizeZ);
 
 SizeX1=SizeX,SizeY1=SizeY,SizeZ1=SizeZ;
 // if (uneven(SizeX) || uneven(SizeY) || uneven(SizeZ))
 //   { cerr << "Error ! Sizes of images have all to be even for correct evaluation and shifting  !\n"; exit(-1); }

 double tx,ty,tz;

 if (plane==true)   // do only in-plane shifts
   {
     int i;
     double *xs,*ys,*zs;  // arrays for storing shifts
     xs= new double[SizeZ];
     ys= new double[SizeZ];
     zs= new double[SizeZ];
     if (FixPlane < 0) FixPlane = SizeZ/2;
     if (FixPlane > SizeZ-1) FixPlane = SizeZ-1;
     gaussfz=1e20;  // Do not use the Gaussfiltering along Z

     if (I2FileName != "")
       {
	 cerr << "WARNING : 2nd image should not be supplied for plane shifting operation !\n" << flush ;
	 exit (-1);
       }

     for (Elem=0;Elem<Elements;Elem++)
       {
     // The section below loads the reference image
	 Elements=InputImg.DLoad(kflag,IFileName.c_str(),"Float",& SizeX,& SizeY, & SizeZ,Elem);
	 CImg1.Resize(SizeX,SizeY,1);
	 CImg2.Resize(SizeX,SizeY,1);
	 CImg3.Resize(SizeX,SizeY,1);
	 PlaneImg.Resize(SizeX,SizeY,1);
	 CImg1.Set(0);
	 CImg1.extract(2,FixPlane,& InputImg);  // z-cut plane of middle plane
	 // CImg1.KSave("/tmp/xxx.kdf");
     if (exponent != 1.0)          // if the user wants, the image is raised to the ... th power.
       CImg1.Pow(exponent);

     CImg1.FFTfwd();
	 CImg1.Conjugate(); // Real Image is roominverted
	 PlaneImg.extract(2,FixPlane,& InputImg);  // just extracts the plane again
	 if (I3FileName=="")
	   OutputImg.insert(2,FixPlane,& PlaneImg); // and saves it in the output (no shift)

	 xs[FixPlane]=0;
	 ys[FixPlane]=0;
	 zs[FixPlane]=0;

	 for (i=FixPlane-1;i>=0;i--)
	   {
	     CImg2.extract(2,i,& InputImg);
	     
	     if ((Elem==0) || IndividualShifts)
	       {
             if (exponent != 1.0)          // if the user wants, the image is raised to the ... th power.
               CImg2.Pow(exponent);
             CImg2.FFTfwd();
             cout << "\nsection : " << i << "\n";
             CImg2.calcShift(& CImg1,& CImg3,steps,range,phases,tx,ty,tz,maxreldist, maxreldistz, false, gaussf, gaussfz);  // calculates and applies shift
             if (vfp)
               {
               (* vfp) << tx << "\t" << ty << "\t" << tz << "\n" << flush;
               }		 
             xs[i]=tx;
             ys[i]=ty;
             zs[i]=tz;
             if (! ReferenceIsFixed)
               {
               Copy(& CImg2,& CImg1); // still with the power(exponent) in it, if selected
               CImg1.Conjugate(); // Real Image is roominverted
               }
             if (exponent != 1.0)          // if the user wants, the image is raised to the ... th power.
               {  // re-extract the data, this time without application of the power(exponent)
               CImg2.extract(2,i,& InputImg);
               CImg2.FFTfwd();
               CImg2.scramble();
               CImg2.FFTshift(tx,ty,tz);
               CImg2.scramble(1);
               }
	       }
	     else
	       {
             CImg2.FFTfwd();
             CImg2.scramble();
             CImg2.FFTshift(xs[i],ys[i],zs[i]);
             CImg2.scramble(1);
             if (i==SizeZ/2) cout << "  applied shift as for element 0\n";
             cout << "shift section " << i << " was: x=" << xs[i] << ", y=" << ys[i] << ", z=" << zs[i] << "\n";
	       }

	     CImg2.FFTbwd();
	     CopyCtoR(&CImg2,& PlaneImg);
	     if (I3FileName == "")
	       OutputImg.insert(2,i,& PlaneImg);
	   }

	 CImg1.Set(0);
	 CImg1.extract(2,FixPlane,& InputImg);  // z-cut first reference plane again
     if (exponent != 1.0)          // if the user wants, the image is raised to the ... th power.
       CImg1.Pow(exponent);
	 // CImg1.KSave("/tmp/xxx.kdf");
	 CImg1.FFTfwd();
	 CImg1.Conjugate(); // Real Image is roominverted

	 for (i=FixPlane+1;i< SizeZ;i++)
	   {
	     CImg2.extract(2,i,& InputImg);
	     
	     if ((Elem==0) || IndividualShifts)
	       {
            if (exponent != 1.0)          // if the user wants, the image is raised to the ... th power.
               CImg2.Pow(exponent);
             CImg2.FFTfwd();
             cout << "\nsection : " << i << "\n";
             CImg2.calcShift(& CImg1,& CImg3,steps,range,phases,tx,ty,tz,maxreldist, maxreldistz, false, gaussf, gaussfz);  // calculates and applies shift
             if (vfp)
               {
                   (* vfp) << tx << "\t" << ty << "\t" << tz << "\n" << flush;
                }		 
            xs[i]=tx;
            ys[i]=ty;
            zs[i]=tz;
            if (! ReferenceIsFixed)
              {
                Copy(& CImg2,& CImg1);     // still with the power(exponent) in it, if selected
                CImg1.Conjugate(); // Real Image is roominverted
              }
            if (exponent != 1.0)          // if the user wants, the image is raised to the ... th power.
               {  // re-extract the data, this time without application of the power(exponent)
               CImg2.extract(2,i,& InputImg);
               CImg2.FFTfwd();
               CImg2.scramble();
               CImg2.FFTshift(tx,ty,tz);
               CImg2.scramble(1);
               }
	       }
	     else
	       {
            CImg2.FFTfwd();
            CImg2.scramble();
            CImg2.FFTshift(xs[i],ys[i],zs[i]);
            CImg2.scramble(1);
            cout << "shift section " << i << " was: x=" << xs[i] << ", y=" << ys[i] << ", z=" << zs[i] << "\n";
	       }
	     
	     CImg2.FFTbwd();
	     CopyCtoR(&CImg2,& PlaneImg);
	     if (I3FileName=="")
	       OutputImg.insert(2,i,& PlaneImg);
	   }

	 if (I3FileName!="")  // apply scale, shift to this element of I3
	   {
	     int El;
	     El=InputImg.DLoad(kflag,I3FileName.c_str(),"Float",& SizeX1,& SizeY1, & SizeZ1,Elem);
	     CImg2.Resize(SizeX1,SizeY1,1);
	     PlaneImg.Resize(SizeX1,SizeY1,1);
	     if (Elem == 0)
	       {
             OutputImg.Resize(SizeX1,SizeY1,SizeZ1);
	       }
      	 	
	     int min= (SizeZ1-SizeZ)/2;
	     if (min < 0) min=0;
	     int max= min + SizeZ;
	     if (max > SizeZ1)
	       max = SizeZ1;
	     for (i=min;i< max;i++) // will allign to the middle
	       {
             CImg2.extract(2,i,& InputImg);
             CImg2.FFTfwd();
             CImg2.scramble();
             CImg2.FFTshift(xs[i-min],ys[i-min],zs[i-min]);
             CImg2.scramble(1);
             CImg2.FFTbwd();
             CopyCtoR(&CImg2,& PlaneImg);
             OutputImg.insert(2,i,& PlaneImg);
           }
             cout << "  shifted alternate file\n";
	   }
    
	 if (Elem == 0)
	   OutputImg.DHeader(kflag,to,Elements);

	 OutputImg.Write(& to);
       }

   }
 else // if (plane==false)
   {
     CImg1.Resize(SizeX,SizeY,SizeZ);
     CImg2.Resize(SizeX,SizeY,SizeZ);
     CImg3.Resize(SizeX,SizeY,SizeZ);
     CImg1.Set(0);

     Copy(& InputImg,& CImg1);
     if (exponent != 1.0)          // if the user wants, the image is raised to the ... th power.
       {
         CImg1Pow.Resize(SizeX,SizeY,SizeZ);
         Copy(& InputImg,& CImg1Pow);
         CImg1Pow.Pow(exponent);
         CImg1Pow.FFTfwd();
         CImg1Pow.Conjugate(); // Real Image is roominverted
       }
     CImg1.FFTfwd();
     CImg1.Conjugate(); // Real Image is roominverted

   for (Elem=0;Elem<Elements;Elem++)
     {
       cout << "\nLoading Element " << Elem << "\n";
       CImg2.Set(0);
       Elements=InputImg.DLoad(kflag,I2FileName.c_str(),"Float",& SizeX1,& SizeY1, & SizeZ1,Elem);

       if (zflipadd)
         InputImg.Flip(false,false,true);
       
       Copy(& InputImg,& CImg2);

              
    if (! noshifts)
	 if ((Elem==0) || IndividualShifts)
	   {
         if (exponent != 1.0)          // if the user wants, the image is raised to the ... th power.
           {
             CImg2.Pow(exponent);
             CImg2.FFTfwd();
             CImg2.calcShift(& CImg1Pow,& CImg3,steps,range,phases,tx,ty,tz,maxreldist,maxreldistz,forceplane, gaussf, gaussfz);  // calculates and applies shift
             Copy(& InputImg,& CImg2);  // This time without the pow
             CImg2.FFTfwd();
             CImg2.scramble();
             CImg2.FFTshift(tx,ty,tz);
             CImg2.scramble(1);
           }
         else
           {
             CImg2.FFTfwd();
             CImg2.calcShift(& CImg1,& CImg3,steps,range,phases,tx,ty,tz,maxreldist,maxreldistz,forceplane, gaussf, gaussfz);  // calculates and applies shift
           }

	     if (zflipadd)
	       {
             CImg1.Conjugate(); // Real Image is roominverted
             CImg2.Add(& CImg1);
             CImg2.scramble();
             double hz=-tz/2.0;
             if (2*(SizeZ/2) == SizeZ)   // Even Size Array
               {
                 hz -= 0.5;
                 cout << "Center is defined to be at z=" << SizeZ/2 << "\n";
               }
             else                    // UnEven Size Array
               {
                 hz -= 1.0;
                 cout << "Center is defined to be at z=" << SizeZ/2 << "\n";
               }
             CImg2.FFTshift(0,0,hz);
             CImg2.scramble(1);
             CImg1.Conjugate(); // Real Image is roominverted
             cout << "Image to align correlated, added with reference, and centered by using half shift\n";
	       }

	     if (vfp)
	       {
             (* vfp) << tx << "\t" << ty << "\t" << tz << "\n" << flush;
	       }	   
	   }
	 else 
	   { // apply only tx,ty,tz
         CImg2.FFTfwd();  // Power(elements) does not need to be applied here !
	     CImg2.scramble();
	     CImg2.FFTshift(tx,ty,tz);
	     CImg2.scramble(1);
	     if (zflipadd)
	       {
             CImg1.Conjugate(); // Real Image is roominverted
             CImg2.Add(& CImg1);
             CImg2.scramble();
             CImg2.FFTshift(0,0,-tz/2.0);
             CImg2.scramble(1);
             CImg1.Conjugate();     // Real Image is roominverted
             cout << "Image to align correlated, added with reference, and centered by using half shift\n";
           }

	     cout << "  applied shift as for element 0\n";
	   }

       if ((Elem==0) || IndividualScale)
         if (scale)
           {
             factor= sqrt(CImg1.HighFreqEnergy(0.1)/CImg2.HighFreqEnergy(0.1));
             cout << " HF scaling factor (by Energy > 0.1*FreqMax) : " << factor << "\n";
             CImg2.Mul(factor);
             cout << "scaling image by : " << factor << "\n";

             offset = (real(CImg2.Value(0,0,0)) - real(CImg1.Value(0,0,0)))/ sqrt((double) SizeX * SizeY * SizeZ);
             cout << " image two has a zero-frequency offset of : " << offset/factor << "\n";
             CImg2.SetValue(0,0,0,CImg1.Value(0,0,0)); // apply offset
           }
         else ;
       else
           {  // Apply same scale and offset
           if (scale)
             {
               CImg2.Mul(factor);
               CImg2.SetValue(0,0,0,CImg1.Value(0,0,0));
               cout << "  applied same scale and offset as for element 0\n";
             }
           }

       if (withprevelem)  // copy the FFT to the Img dataset and conjugate
         {
           CImg1.Copy(&CImg2);
           CImg1.Conjugate(); // Real Image is roominverted
         }
	   
       if (I3FileName!="")  // apply scale, shift to this element of I3
      	 {
      	 	int el=Elem,El;
      	 	
           El=InputImg.DLoad(kflag,I3FileName.c_str(),"Float",& SizeX1,& SizeY1, & SizeZ1,el);
           CImg2.Resize(SizeX1,SizeY1,SizeZ1);
           OutputImg.Resize(SizeX1,SizeY1,SizeZ1);
           Copy(& InputImg,& CImg2);
           CImg2.FFTfwd();
           if (scale)
       		{
             CImg2.Mul(factor);
             CImg2.SetValue(0,0,0,CImg1.Value(0,0,0)); // apply offset
			}
           if (zflipadd)
           {
		    CImg1.Conjugate(); // Real Image is roominverted
		    CImg2.Add(& CImg1);
		    CImg2.scramble();
		    CImg2.FFTshift(0,0,-tz/2.0);
		    CImg2.scramble(1);
		    CImg1.Conjugate(); // Real Image is roominverted
		    cout << "Image to align correlated, added with reference, and centered by using half shift\n";
            }

	     	CImg2.scramble();
	     	CImg2.FFTshift(tx,ty,tz);
	        CImg2.scramble(1);
            cout << "  shifted alternate file\n";
          }

       CImg2.FFTbwd();
       
       CopyCtoR(&CImg2,& OutputImg);
       
       if (onlyoffset)  // only apply offset
       {
         cout << "scaling back to original intensity\n";
         OutputImg.Mul(1.0/factor);
       }
       
       if (Elem == 0)
         OutputImg.DHeader(kflag,to,Elements);
       
       OutputImg.Write(& to);

       if (Elem+1 < I1Elements)  // load a new element of image 1  if existent
       {
         InputImg.DLoad(kflag,IFileName.c_str(),"Float",& SizeX,& SizeY, & SizeZ, Elem+1);
         Copy(& InputImg,& CImg1);
         CImg1.FFTfwd();
         CImg1.Conjugate(); // Real Image is roominverted
       }
     }
   }

 if (to) 
   to.close(); 
 if (vfp)
   vfp->close();

 if (screamlimit > 0.0)
   if (tx*tx+ty*ty+tz*tz > screamlimit*screamlimit)
	 {
	   cerr << "WARNING !!! Screamlimit of " << screamlimit << " was exceeded in total distance \n";
	   exit(-1);
	 }
}
