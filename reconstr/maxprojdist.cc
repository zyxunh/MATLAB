// maxprojdist : maximum projects and generates a file of distance of maximum to neares spot-position

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
#include <string>
#include "tarrayclipf.h"
#include "parseargs.h"

#include <time.h>
#include "poidev.h"

long rval=-5;       // initvalue of random-generator, can be changed

typedef float ArrayBType;
typedef Dyn2dArray(ArrayBType,ClipperatorNoClip)  TProjArray;  // Clipping is needed
typedef Dyn3dArray(ArrayBType,ClipperatorNoClip)  TImgArray;  // Clipping is needed

static TImgArray InputImg,O2Img;
static TProjArray O1Img,O3Img;

double Pos0x,Pos0y,  // First spot position
  spdistXx,spdistXy,lenX, // spot distance vectors of spots for X-direction
  spdistYx,spdistYy,lenY, // spot distance vectors of spots for Y-direction
  moveXx,moveXy, // move vectors of spots for X-direction
  moveYx,moveYy; // move vectors of spots for Y-direction
int stepsX,stepsY;  // Number of steps before a line-break occurs and total number of steps in Y
double refac=-0.5;

double GaussWeight(double r2,double spotsize)
{
  return exp(-r2/(spotsize*spotsize));
}



void GetNearestSpot(double & dx, double & dy, int x,int y,int z, double & relPosX, double & relPosY) // returns dx, dy in units of spot-to-spot distances (X,Y) and pixel's coordinates in these units
{
  //double relPosX,relPosY;  // position of pixel in units of spot-to-spot vector relative to the start position.
  double Posx = Pos0x + (z % stepsX)*moveXx + (z / stepsX)*moveYx;   // calculate the first spot position in this shifted slice
  double Posy = Pos0y + (z % stepsX)*moveXy + (z / stepsX)*moveYy;

  // scalar product of the spot-line vectors with the position in the image (relative to Pos-vector)
  relPosX = ((x-Posx)*spdistXx+(y-Posy)*spdistXy) / (lenX) / (lenX);  // in units of the stepping vectors
  relPosY = ((x-Posx)*spdistYx+(y-Posy)*spdistYy) / (lenY) / (lenY);

  if (relPosX < 0)
    relPosX += 2 + int(-relPosX);  // force it to be positive
  if (relPosY < 0)
    relPosY += 2 + int(-relPosY);  // force it to be positive
  
  dx = relPosX-int(relPosX);
  if (dx > 0.5) dx = 1.0-dx;   // selects nearest spot  (spot to the right direction == positive)
  else
    dx = -dx;

  dy = relPosY-int(relPosY);
  if (dy > 0.5) dy = 1.0-dy;   // selects nearest spot  (spot to the right direction == positive)
  else
    dy = -dy;

  return;
}

void clip(int & pos, int min,int max)
{
  if (pos < min) pos = min;
  if (pos >= max) pos = max-1;
}

void InterpolateToReassigned(double val, int x,int y,int z) // returns dx, dy in pixel's coordinates
{
  double relPosX,relPosY,dx,dy;  // position of pixel in units of spot-to-spot vector relative to the start position.
  GetNearestSpot(dx,dy,x,y,z,relPosX,relPosY);
  double xm= x + refac*(dx*spdistXx + dy*spdistYx);
  double ym= y + refac*(dx*spdistXy + dy*spdistYy);

  int x1=int(xm); 
  clip(x1,0,O1Img.GetSize(0));
  int y1=int(ym);
  clip(y1,0,O1Img.GetSize(1));
  int x2=int(xm+1.0); 
  clip(x2,0,O1Img.GetSize(0));
  int y2=int(ym+1.0);
  clip(y2,0,O1Img.GetSize(1));

  double r11 = 1.0/(0.00001+sqrt((xm-x1)*(xm-x1)+(ym-y1)*(ym-y1)));
  double r12 = 1.0/(0.00001+sqrt((xm-x1)*(xm-x1)+(ym-y2)*(ym-y2)));
  double r21 = 1.0/(0.00001+sqrt((xm-x2)*(xm-x2)+(ym-y1)*(ym-y1)));
  double r22 = 1.0/(0.00001+sqrt((xm-x2)*(xm-x2)+(ym-y2)*(ym-y2)));
  double rsum=r11+r12+r21+r22;
  if (rsum ==0) rsum=0.001;
  
  // O1Img.SetValue(x,y,O1Img.Value(x,y)+val);
  O1Img.SetValue(x1,y1,O1Img.Value(x1,y1)+val*(r11/rsum));
  O1Img.SetValue(x1,y2,O1Img.Value(x1,y2)+val*(r12/rsum));
  O1Img.SetValue(x2,y1,O1Img.Value(x2,y1)+val*(r21/rsum));
  O1Img.SetValue(x2,y2,O1Img.Value(x2,y2)+val*(r22/rsum));

  return;
}

void usage(char * filename)
{
  cerr <<  "usage: " << filename << " [-k] [-av] [-method MethodName] [-o1 outputfile] [-o2 outputfile] -Pos0x val -Pos0y val -moveXx val -moveXx val -moveYx val -moveYy val -stepsX val -stepsY val \n" << flush;
  exit(-1);
}

int main(int argc, char *argv[])
{ 
int Elements=1,i,method=1,x,y,z;
ArrayBType sum,max,min,val,spotsize=1.0;
static int INPUTSizeX=32;  // These is the standart size, if raw data is used
static int INPUTSizeY=32;  // 256
static int INPUTSizeZ=32;  // 22

int kflag=0, average=0;

string IFileName, O1FileName, O2FileName, O3FileName;

char ** parg= & argv[1];
argc=0;  // to prevent warning

 while (* parg)
  {
   if (readArg("-k",parg)) {kflag=1;continue;}
   if (readArg("-i",  IFileName, parg)) continue;
   if (readArg("-o1",  O1FileName, parg)) continue;  // projection
   if (readArg("-o2",  O2FileName, parg)) continue;  // distance file
   if (readArg("-o3",  O3FileName, parg)) continue;  // distance file
   if (readArg("-IX",& INPUTSizeX, parg)) continue;
   if (readArg("-IY",& INPUTSizeY,parg)) continue;
   if (readArg("-IZ",& INPUTSizeZ,parg)) continue;
   if (readArg("-method", & method, parg)) continue;  // 1 : sum , 2 : avg, 3 : mip, 4 : max- min, 5: max+min-2avg, 6: confocal max, 7: confocal gauss, 8, confocal reassigned, 9: qudrature, 10: scaled subtraction (with gauss-confocal weights)
   if (readArg("-av",parg)) {average=1;continue;}
   if (readArg("-pos0x",& Pos0x, parg)) continue;
   if (readArg("-pos0y",& Pos0y, parg)) continue;
   if (readArg("-spdistXx",& spdistXx, parg)) continue;   // spot distance 
   if (readArg("-spdistXy",& spdistXy, parg)) continue;
   if (readArg("-spdistYx",& spdistYx, parg)) continue;
   if (readArg("-spdistYy",& spdistYy, parg)) continue;
   if (readArg("-stepsx",& stepsX, parg)) continue;
   if (readArg("-stepsy",& stepsY, parg)) continue;
   if (readArg("-spotsize",& spotsize, parg)) continue;
   if (readArg("-refac",& refac, parg)) continue;
    usage(argv[0]);
  }

  lenX=sqrt(spdistXx*spdistXx+spdistXy*spdistXy);
  lenY=sqrt(spdistYx*spdistYx+spdistYy*spdistYy);
  moveXx=spdistXx / float(stepsX); // will eventually be negative, when stepsX is negative
  moveXy=spdistXy / float(stepsX);
  moveYx=spdistYx / float(stepsY);
  moveYy=spdistYy / float(stepsY);
  if (stepsX < 0) stepsX = - stepsX;
  if (stepsY < 0) stepsY = - stepsY;

 if (average == 1) method = 2; // force the method to average for compatibility reasons

 switch (method) {
 case 1:
   cout << "Projection Method is SUM\n"; break;
 case 2:
   cout << "Projection Method is AVERAGE\n"; break;
 case 3:
   cout << "Projection Method is MAX\n"; break;
 case 4:   cout << "Projection Method is MAX-MIN\n"; break;
 case 5:
   cout << "Projection Method is MAX+MIN-2AVG\n"; break;
 case 6:
   cout << "Projection Method is pseudo confocal (nearest spot)\n"; break;
 case 7:
   cout << "Projection Method is pseudo confocal (Gauss shape of nearest spot)\n"; break;
 case 8:
   cout << "Projection Method is pseudo confocal (Sheppard's pixel assignment)\n"; break;
 case 9:
   cout << "Projection Method is Quadrature sqrt(Sum[(I_n-I_(n-1))^2])\n"; break;
 case 10:
   cout << "Projection Method is pseudo confocal (Gauss shape illumination assumed) with scaled subtraction (fixed)\n"; break;
 case 11:
   cout << "Projection Method is pseudo confocal (Gauss shape illumination assumed) with scaled subtraction (variable beta)\n"; break;
 }

 if (IFileName=="") usage(argv[0]);

 ofstream to1(O1FileName.c_str());
 if (O1FileName!="")
     if (! to1 )
       {
	 cerr << "Couldn't open file " << O1FileName << " for writing !!\n" << flush;
	 exit(-1);
       }
 ofstream to2(O2FileName.c_str());
 if (O2FileName!="")
     if (! to2 )
       {
	 cerr << "Couldn't open file " << O2FileName << " for writing !!\n" << flush;
	 exit(-1);
       }
 ofstream to3(O3FileName.c_str());
 if (O3FileName!="")
     if (! to3 )
       {
	 cerr << "Couldn't open file " << O3FileName << " for writing !!\n" << flush;
	 exit(-1);
       }

 float divisor = 1.0;
      
  for (i=0;i<Elements;i++)
  {

    Elements=InputImg.DLoad(kflag,IFileName.c_str(),"Float",
			  & INPUTSizeX,& INPUTSizeY,& INPUTSizeZ,i);

    if (i==0)
      {
	O1Img.Resize(INPUTSizeX,INPUTSizeY);
	O2Img.Resize(INPUTSizeX,INPUTSizeY,4);
	O3Img.Resize((int(INPUTSizeX / lenX)+4)*stepsX,(int(INPUTSizeX / lenY)+4)*stepsY);
	cout << "Move-Grid is:" << (int(INPUTSizeX / lenX)+4)*stepsX << " x " <<(int(INPUTSizeX / lenY)+4)*stepsY << " in size.\n";
      }

    divisor=1.0/INPUTSizeZ;

    double dx,dy,mdx,mdy,maxz,confMax,minSqrDist,confGauss,relPosX,relPosY,qsum=0.0,lastI=0.0,val0=0,weight=1.0, confOffGauss, sumMask, sumOffMask, sumMask2;

    for (y=0;y<INPUTSizeY;y++)
      for (x=0;x<INPUTSizeX;x++)
	{
	  //cout << "x: " << x << ",  y: " << y << "\n" << flush;
	  //cout << "sx: " << INPUTSizeX << ",  sy: " << INPUTSizeY << ", " << INPUTSizeZ << "\n" << flush;
	  val=InputImg.Value(x,y,0); 
	  sum=val;
	  max=val;
	  min=val;
	  maxz=0;
	  qsum=0;
	  z=0;
	  GetNearestSpot(dx,dy,x,y,0,relPosX,relPosY);  // calculates the neares spot distance
	  mdx=dx;mdy=dy;  // save these
	  confMax=val;
	  minSqrDist=dx*dx+dy*dy;
	  weight=GaussWeight(minSqrDist,spotsize);
	  confGauss=val*weight;
	  confOffGauss=val*(1.0-weight);
	  sumMask=weight;
	  sumOffMask=(1.0-weight);
	  sumMask2=weight*weight;
          // sum the weigthed value up into an image with pixel ontop of the scan positions
	  // cout << "\n(" << int(relPosX+0.5) << "," << int(relPosY+0.5) << ": " << val << ")   ";
          O3Img.SetValue(int(relPosX+0.5)*stepsX+(z % stepsX),int(relPosY+0.5)*stepsY+(z/stepsX),
			 O3Img.Value(int(relPosX+0.5)*stepsX+(z % stepsX),int(relPosY+0.5)*stepsY+(z/ stepsX))
			 +weight*val);
	  if (method == 8)
	    InterpolateToReassigned(val*weight,x,y,0);
	  lastI=val;
	  val0=val;

 	  for (z=1;z<INPUTSizeZ;z++)  // iterates over different spot positions
	    {
	      val = InputImg.Value(x,y,z);
	      sum+=val;
	      GetNearestSpot(dx,dy,x,y,z,relPosX,relPosY);  // calculates the neares spot distance

	      if (val > max) 
		{
		  max = val;
		  maxz=z;
		  mdx=dx;mdy=dy;
		}
	      if (val < min) min = val;

	      weight=GaussWeight(dx*dx+dy*dy,spotsize);
	      confGauss+=val*weight;
	      confOffGauss+=val*(1.0-weight);
	      sumMask+=weight;
	      sumOffMask+=(1.0-weight);
	      sumMask2+=weight*weight;
	      if (dx*dx+dy*dy < minSqrDist)   // just takes the value at the minimum square distance
		{
		  confMax=val;
		  minSqrDist = dx*dx+dy*dy;
		}
              // sum the weigthed value up into an image with pixel ontop of the scan positions
	      // cout << "  (" << int(relPosX+0.5) << "," << int(relPosY+0.5) << ": " << val <<")   ";
	      O3Img.SetValue(int(relPosX+0.5)*stepsX+(z % stepsX),int(relPosY+0.5)*stepsY+(z/stepsX),
			     O3Img.Value(int(relPosX+0.5)*stepsX+(z % stepsX),int(relPosY+0.5)*stepsY+(z/stepsX))
			     +weight*val);
              // now calculate Sheppard's scheme assigning to a pixel at half the distance
	      if (method == 8)
		InterpolateToReassigned(val*weight,x,y,z);
	      // InterpolateToReassigned(val,x,y,z);
	      qsum += (val-lastI)*(val-lastI);
	      lastI=val;
	    }
          qsum += (val0-lastI)*(val0-lastI); // close the cycle for Quadrature method
	  
	  O2Img.SetValue(x,y,0,mdx);
	  O2Img.SetValue(x,y,1,mdy);
	  O2Img.SetValue(x,y,2,sqrt(mdx*mdx+mdy*mdy));
	  O2Img.SetValue(x,y,3,float(maxz));

	  switch (method) {
	  case 1:
	    O1Img.SetValue(x,y,sum); break;
	  case 2:
	    O1Img.SetValue(x,y,sum*divisor); break;
	  case 3:
	    O1Img.SetValue(x,y,max); break;
	  case 4:
	    O1Img.SetValue(x,y,max-min); break;
	  case 5:
	    O1Img.SetValue(x,y,max+min-2*sum*divisor); break;
	  case 6:
	    O1Img.SetValue(x,y,confMax); break;
	  case 7:
	    O1Img.SetValue(x,y,confGauss); break;
	  case 8:
	    break;
	  case 9:
	    O1Img.SetValue(x,y,sqrt(qsum)); break;
	    break;
	  case 10:
	    O1Img.SetValue(x,y,confGauss/sumMask - confOffGauss/sumOffMask); break;
	    break;
	  case 11:
	    double beta = (INPUTSizeZ * sumMask - sumMask*sumMask)/(INPUTSizeZ*sumMask2-sumMask*sumMask);
	    O1Img.SetValue(x,y,beta*(confGauss/sumMask - confOffGauss/sumOffMask)); break;
	  }
	}

    if (i==0)
      {
	if (kflag)
	  {
	    if (to1 && kflag) WriteKhorosHeader(& to1,"Generated by MaxProjDist 2003","Float",INPUTSizeX,INPUTSizeY,1,Elements);
	    cerr << "writing file " << O1FileName << " \n" << flush;
	    if (to2 && kflag) WriteKhorosHeader(& to2,"Generated by MaxProjDist 2003","Float",INPUTSizeX,INPUTSizeY,4,Elements);
	    cerr << "writing file " << O1FileName << " \n" << flush;
	    if (to3 && kflag) WriteKhorosHeader(& to3,"Generated by MaxProjDist 2003","Float",O3Img.GetSize(0),O3Img.GetSize(1),1,Elements);
	    cerr << "writing file " << O3FileName << " \n" << flush;
	  }
	// else nothing
      }

    if (to1) O1Img.Write(& to1);
    if (to2) O2Img.Write(& to2);
    if (to3) O3Img.Write(& to3);
  }
  if (to1) to1.close();
  if (to2) to2.close();
  if (to3) to2.close();
}
