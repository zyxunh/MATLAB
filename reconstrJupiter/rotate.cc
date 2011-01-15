// #define DEBUG_SAVE

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
#include <time.h>
#include "vec.h"
#include "fftarray.h"
#include "tarrayclipf.h"
#include "khoros.h"

#include "projector.h"
#include "projectorlp.h"

#include "projection.h"
#include "parseargs.h"
#include "veccalc.h"
#include "matrix.h"

typedef float          ArrayBType;

typedef Dyn1dArray(ArrayBType,ClipperatorNoClip) TVecArray;
typedef Dyn3dArray(ArrayBType,ClipperatorNeighbClip)  TPrjArray;   // Measured Size (CYCLIC, to avoid strange edge effects)
typedef Dyn3dArray(ArrayBType,ClipperatorNeighbClip)  TImgArray;   // Recon Size (CYCLIC, to avoid strange edge effects)
typedef ProjectorLp<TImgArray>                        TProjector;  // without zoom-function
typedef Image<TImgArray,TProjector>                   TImage;
typedef Projection<TPrjArray,TImage,TProjector>    TProjection; // pretends to be talking to a TImagePrj

// Reference Points position used for determination of Turn-algebra

static Vector P1(3),P1a(3), P2(3),P2a(3), P3(3),P3a(3);

// Values below are needed for shearingcorrection

static Vector MXFI(1,0,0);  // Forward-Projection-Vectors
static Vector MYFI(0,1,0);
static Vector MZFI(0,0,1);
static Vector POSFI(0,0,0);
static Matrix MyTurn(3,3); // 3x3 matrices

static Vector MXBI(1,0,0);  // Backward-Prj-Vectors
static Vector MYBI(0,1,0);
static Vector MZBI(0,0,1);
static Vector POSBI(0,0,0);
static Vector MXF(3),MYF(3),MZF(3),POSF(3),MXB(3),MYB(3),MZB(3),POSB(3);

static double tx=0.0,ty=0.0,tz=0.0; // stores the shifts
static double ShiftX=0.0,ShiftY=0.0,ShiftZ=0.0;  // will be set after a few iterations

static TProjector    SmallPrj(3,0.5,0.5,0.5); // Width, Length, Depth
// Images needed
static   TImage Img;
static   TProjection rotPrj(& SmallPrj);

// Arrays for complex correlation
typedef complex<float> ArrayBCType;
typedef TFFTArray<ArrayBCType> TImgCArray;
// typedef Dyn3dArray(ArrayBCType,ClipperatorNoClip)  TImgCArray;

static   TImgCArray PrjArr,OtherArr,TmpArr;

void InitVecs(void)
{
  MXF=MXFI;
  MYF=MYFI;
  MZF=MZFI;
  POSF=POSFI;
  MXB=MXBI;
  MYB=MYBI;
  MZB=MZBI;
  POSB=POSBI;
}

void ReadVectors(string VFileName)
{
  InitVecs();

  if ( VFileName[0])
    {
      ifstream Input(VFileName.c_str());

      if (! Input) cerr << "error reading vector-file", exit(-1);

      P1.asciiread(& Input);
      P2.asciiread(& Input);
      P3.asciiread(& Input);
      P1a.asciiread(& Input);
      P2a.asciiread(& Input);
      P3a.asciiread(& Input);

      P1.show();
      P2.show();
      P3.show();
      P1a.show();
      P2a.show();
      P3a.show();
      cout << "\n";
      Input.close();
    }
  else
    {
      P1.ChangeComp(0,0.0); P1.ChangeComp(1,0.0); P1.ChangeComp(2,0.0);
      P2.ChangeComp(0,1.0); P2.ChangeComp(1,0.0); P2.ChangeComp(2,0.0);
      P3.ChangeComp(0,0.0); P3.ChangeComp(1,1.0); P3.ChangeComp(2,0.0);
    }
 
  cout << "Positions now : \n";
  CalcFromPos(P1,P2,P3,P1a,P2a,P3a,  // Input
	      POSB,MXB,MYB,MZB,POSF,MXF,MYF,MZF, // output
	      1,1,& MyTurn); // ZX Aspect
  MyTurn.Transp(); // because the forward turn is given !

  cout << "Vectors  :\n";
  MXB.show();
  MYB.show();
  MZB.show();
}

void SetProjector()  // updates the projetors for new geometry
{
  rotPrj.FirstPrj.SetPos(& POSB);                 // position of first pixel
  //  reconPrj.FirstPrj.SetPos(& Dir);                 // position of first pixel
  rotPrj.FirstPrj.TakeNewChangeVec(0,& MXB);     // change-directions for new confocal section
  rotPrj.FirstPrj.TakeNewChangeVec(1,& MYB);
  rotPrj.FirstPrj.TakeNewChangeVec(2,& MZB);
  // reconPrj.FirstSPrj.SetZoom(MXF[k],MYF[k],MZF[k]); // Hmm, wie macht man das ??
}

/// prepares Movement vectors and metrices for Projector
void PrepareProjector(double AngleX,double AngleY, double AngleZ, double XScale=1.0, double YScale=1.0, double ZScale=1.0) 
{
  Matrix tmp(3,3);
  Vector scale(1.0/XScale,1.0/YScale,1.0/ZScale);

  InitVecs();
  // This would be in image to match to !
  // MZB.Mul(1.0/ZScale);  // To change Z-Scaling do not move so much in image to project
  MyTurn.Generate3DTurn(M_PI/180.0*AngleX,0);
  tmp.Generate3DTurn(M_PI/180.0*AngleY,1);
  MyTurn.Mul(& tmp);
  tmp.Generate3DTurn(M_PI/180.0*AngleZ,2);
  MyTurn.Mul(& tmp);

  MyTurn.MulVec(& MXB);
  MyTurn.MulVec(& MYB);
  MyTurn.MulVec(& MZB);
  MXB.Mul(& scale);
  MYB.Mul(& scale);
  MZB.Mul(& scale);
  // cout << "Calculated vectors : \n"; MXB.show(); MYB.show(); MZB.show();
}

void AdjustCenter(double CenterX,double CenterY,double CenterZ,double XScale=1.0, double YScale=1.0, double ZScale=1.0) // Adjust movement-vectors to match center     
{
  Vector tmpf(CenterX,CenterY,CenterZ),  // This is the center in image to project
    tmpb(-CenterX,-CenterY,-CenterZ),           // This is the center in image to project into
    tmps(-ShiftX,-ShiftY,-ShiftZ),scale(1.0/XScale,1.0/YScale,1.0/ZScale);

  tmpb.Add(& tmps);   // shift the Center appropriately
  MyTurn.MulVec(& tmpb);
  tmpb.Mul(& scale);  // reduces the in result image backpointing coordinate in Z-direction using itp coordinates
  tmpf.Add(& tmpb);   // calculate shift between ma1 and mb1
  POSB.copy(& tmpf);  // write to POS
}

double AngleCorrel(double AngleX,double AngleY, double AngleZ, double XScale, double YScale, double ZScale,
		 double CenterX,double CenterY,double CenterZ,
		 double phase)
{
  double y;

  PrepareProjector(AngleX,AngleY,AngleZ,XScale, YScale, ZScale);
  cout << "Angles are "<< AngleX << ", " << AngleY << ", " << AngleZ 
	<< "   XScale : " << XScale 
	<< "   YScale : " << YScale 
	<< "   ZScale : " << ZScale << "\n";
  AdjustCenter(CenterX,CenterY,CenterZ,XScale,YScale, ZScale); // Try using shifts to avoid correlation
  SetProjector();
  
  rotPrj.Array.Clear(); 
  rotPrj.ProjectImage(& Img);  // runs through rotPrj and clips small regions in Img
  
  // rotPrj.Array.DSave(true,"/tmp/turned.kdf");

  // PrjArr.Clear();
  Copy(& rotPrj.Array,& PrjArr);
  PrjArr.FFTfwd();
  y=PrjArr.calcShift(&OtherArr,&TmpArr,1,1, phase, tx,ty,tz);
  cout << " Correl : " << y;
  // y /= XScale * YScale * ZScale;  // Normalized for the intensity changes in zooming
  cout << " normalized : " << y << "\n";
  // 1 steps, 1 range, ? % phase-enhance  // One step is sufficient, because iterative Center does reduce false matching
  return y;  // To correct for integral intensity enhancement 
}

void optimize(int dim,double & AngleX,double & AngleY, double & AngleZ, double & XScale, double & YScale, double & ZScale,
		 double CenterX,double CenterY,double CenterZ,
		 double phase, double width, int Steps)
{
  int j;
  double minAng,maxAng,bestAng,y2,y0,y1;
  double Angles[6]={AngleX,AngleY,AngleZ,XScale,YScale,ZScale};

  if (dim < 3)
    {
      minAng=Angles[dim]-width;
      maxAng=Angles[dim]+width;
    }
  else
    {
      minAng=Angles[dim]-0.1; // For Z-Scale changes
      maxAng=Angles[dim]+0.1;
    }

  Angles[dim]= minAng;
  y2=AngleCorrel(Angles[0],Angles[1],Angles[2],Angles[3],Angles[4],Angles[5],CenterX,CenterY,CenterZ,phase);
  Angles[dim]= maxAng;
  y1=AngleCorrel(Angles[0],Angles[1],Angles[2],Angles[3],Angles[4],Angles[5],CenterX,CenterY,CenterZ,phase);
  Angles[dim]= (maxAng+minAng)/2;
  
  j=0;
  do {
    y0=AngleCorrel(Angles[0],Angles[1],Angles[2],Angles[3],Angles[4],Angles[5],CenterX,CenterY,CenterZ,phase);

    bestAng =  Angles[dim]+(maxAng-minAng)/2.0*(y2-y1)/(2*y2+2*y1-4*y0);  // Fit of a parabola  points : x2-width,x0,x1+width (left to right)
    cout << "best Val : " << bestAng << "\n";

    if (y2 < y1)
      {
	y2=y0;
	minAng=Angles[dim];
      }
    else
      {
	y1=y0;
	maxAng=Angles[dim];
      }

    Angles[dim] = (minAng+maxAng)/2.0; // Position of the next one to calculate
    
  } while (++j < Steps);

  // Angles[dim] = bestAng; // Now take the parabolic fit !

  AngleX = Angles[0];
  AngleY = Angles[1];
  AngleZ = Angles[2];
  XScale = Angles[3];
  YScale = Angles[4];
  ZScale = Angles[5];

  ShiftX -=tx;  // Now the turning point is adjusted
  ShiftY -=ty;
  ShiftZ -=tz;

}

void usage(char * filename)
{
  cerr << "usage: " << filename << " [-k] [-mX X ...] [-i inputfile] [-o outputfile] \n" << flush;
  cerr << "-mX X -mY Y -mZ Z :  X,Y,Z == sizes of measured projection\n";
  cerr << "-aX angleX -aY angleY -aZ angleZ :  angles of rotation about axis x then y then z\n";
  cerr << "-cX centerX -cY centerY -cZ centerZ :  center of rotation\n";
  cerr << "-k : khoros data format flag\n";
  cerr << "-v file : file containing vector poits to match \nImage1 p1 x y z \np2 x y z \np3 x y z\nImage2 p1 x y z ...\n";
  exit(-1);
}


int main(int argc, char *argv[])
{
  int i,Elements=1,cx=0,cy=0,cz=0,sx=0,sy=0,sz=0,center=0,correl=0,Steps=3;
  double AngleX,AngleY,AngleZ,CenterX,CenterY,CenterZ;  // Measure Frequencies > 10% of max
 double XScale =1.0,YScale =1.0,ZScale =1.0;

  double Delta=0.4,phase=0.1,width=5; 

  bool kflag=false,onlyZ=false,xstretch=false,ystretch=false,zstretch=false,successive=false;

string IFileName,I2FileName,OFileName,VFileName,  // file for vector coordinates
        RAFileName,  // output of angles
        TAFileName;  // output of angles


  int MEASUREDSizeX=256; // 128
  int MEASUREDSizeY=256; // 128
  int MEASUREDSizeZ=32;  // 25

  printCall(argc,argv);


char ** parg= & argv[1];
argc = 0; // to prevent warning

 while (* parg)
  {
   if (readArg("-k",parg)) {kflag=true;continue;}
   if (readArg("-op",parg)) {onlyZ=true;continue;}
   if (readArg("-xstretch",parg)) {xstretch=true;continue;}
   if (readArg("-ystretch",parg)) {ystretch=true;continue;}
   if (readArg("-zstretch",parg)) {zstretch=true;continue;}
   if (readArg("-i", IFileName, parg)) continue;
   if (readArg("-icorrel", I2FileName, parg)) {correl=1;continue;}  // compute advanced cross corellation for some angles
   if (readArg("-successive", parg)) {successive=true;continue;}  // compute advanced cross corellation for some angles
   if (readArg("-o", OFileName, parg)) continue;
   if (readArg("-v", VFileName, parg)) continue;   // Vectors for points positions
   if (readArg("-rangle",RAFileName,parg)) {continue;}  // resulting angle
   if (readArg("-tangle",TAFileName,parg)) {continue;}  // Binary vector Input for turning angles [AngleX,AngleY,AngleZ]
   if (readArg("-mX",& MEASUREDSizeX, parg)) continue;
   if (readArg("-mY",& MEASUREDSizeY,parg)) continue;
   if (readArg("-mZ",& MEASUREDSizeZ,parg)) continue;
   if (readArg("-aX",& AngleX,parg)) continue;
   if (readArg("-aY",& AngleY,parg)) continue;
   if (readArg("-aZ",& AngleZ,parg)) continue;
   if (readArg("-cX",& CenterX,parg)) {cx=1;continue;}
   if (readArg("-cY",& CenterY,parg)) {cy=1;continue;}
   if (readArg("-cZ",& CenterZ,parg)) {cz=1;continue;}
   if (readArg("-sX",& XScale,parg)) {sx=1;continue;}
   if (readArg("-sY",& YScale,parg)) {sy=1;continue;}
   if (readArg("-sZ",& ZScale,parg)) {sz=1;continue;}
   if (readArg("-center",parg)) {center=1;continue;}
   if (readArg("-steps",& Steps,parg)) {continue;}  // Number od steps for optimization
   if (readArg("-delta",& Delta,parg)) {continue;}  // DeltaAngle between steps
   if (readArg("-phase",& phase,parg)) {continue;}  // Phase percentage for cross corellation
   if (readArg("-width",& width,parg)) {continue;}  // Starting width for iteration over angles

   usage(argv[0]);
  }

 if (IFileName=="") cerr << "No Input file given !\n",exit(-1); 
 if (OFileName=="") cerr << "No Output file given !\n",exit(-1);

 ofstream * to, * toraf=0;
 TVecArray rangle(12);
 
 Elements=1;
 int Elem2=1, tanElem=1;
 for (i=0;i<Elements;i++)
   {
     Elements=Img.Array.DLoad(kflag,IFileName.c_str(),"Float",& MEASUREDSizeX,& MEASUREDSizeY,& MEASUREDSizeZ,i);
     if (MEASUREDSizeX <= 1)
       xstretch =false;
     if (MEASUREDSizeY <= 1)
       ystretch =false;
     if (MEASUREDSizeZ <= 1)
       zstretch =false;
       
     if (i==0)
        {
          rotPrj.Array.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);

          if (! cx)   CenterX=MEASUREDSizeX/2.0;
          if (! cy)   CenterY=MEASUREDSizeY/2.0;
          if (! cz)   CenterZ=MEASUREDSizeZ/2.0;
        }  // if (i == 0)

      if (TAFileName!="" && (correl == 0 || Elem2 > i))
        {
            int x=12,y=1,z=1;
            TVecArray tangles;
            tanElem=tangles.DLoad(true,TAFileName.c_str(),"Float",&x ,&y ,&z,i % tanElem);
            if ((x != 12) || (y != 1) || (z != 1))
            cerr << " Error Turning Angle File had wrong size ! Wanted : 3x1x1 \n Sizes are :" <<x<<"x"<<y<<"x"<<z<<"\n", exit(-1);
            AngleX=tangles.Value(0);
            AngleY=tangles.Value(1);
            AngleZ=tangles.Value(2);
	    if (! center)
	    {
            if (! cx) CenterX=tangles.Value(3);
            if (! cy) CenterY=tangles.Value(4);
            if (! cz) CenterZ=tangles.Value(5);
            ShiftX=tangles.Value(9);  ShiftY=tangles.Value(10); ShiftZ=tangles.Value(11);
	    }
            XScale=tangles.Value(6);  YScale=tangles.Value(7); ZScale=tangles.Value(8);
            cout << " Read Angles from File : " << AngleX << ", " << AngleY << ", " << AngleZ << "\n";
            cout << " Read Center from File : " << CenterX << ", " << CenterY << ", " << CenterZ << "\n";
            cout << " Read Shifts From File : " << ShiftX << ", " << ShiftY << ", " << ShiftZ << "\n";
            cout << " Read Scaling from File : " << XScale << ", " << YScale << ", " << ZScale << "\n";
        }

     if (VFileName!="")
            ReadVectors(VFileName.c_str());
     else
          {
            PrepareProjector(AngleX,AngleY,AngleZ,XScale, YScale, ZScale);
            cout << "Angles are "<< AngleX << ", " << AngleY << ", " << AngleZ
            << "   XScale : " << XScale
            << "   YScale : " << YScale
            << "   ZScale : " << ZScale << "\n";
            AdjustCenter(CenterX,CenterY,CenterZ,XScale,YScale, ZScale); // Try using shifts to avoid correlation
            POSB.show();
          }
                     	 
     if (center)
          {
            AdjustCenter(CenterX,CenterY,CenterZ,XScale,YScale, ZScale); // Try using shifts to avoid correlation
    	    POSB.show();
          }

     SetProjector();

     if (correl==0 && ! successive)
       {
         rotPrj.Array.Clear();
         rotPrj.ProjectImage(& Img); 
       }
     else // correl != 0 || ! successive
       {
         if ((i == 0) || (Elem2 > i))
           {
             if (successive)
               {
                if (i == 0)
                  {
                    OtherArr.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);
                    rotPrj.ProjectImage(& Img);
                    Elem2 = Elements;
                  }
                Copy(& rotPrj.Array,& OtherArr);  // copy the last result into the reference array

                // OtherArr.Copy(& rotPrj.Array);
                }
             else
               Elem2=OtherArr.DLoad(kflag,I2FileName.c_str(),"Complex",& MEASUREDSizeX,& MEASUREDSizeY,& MEASUREDSizeZ,i);

             if (! OtherArr.SizesEqual(& Img.Array))
               {cerr << "Error: Size of correlation array has to match!\n"; exit(-1);}
         
             if (i==0)
             {
               TmpArr.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);
               PrjArr.Resize(MEASUREDSizeX,MEASUREDSizeY,MEASUREDSizeZ);
             }

             OtherArr.FFTfwd();
             OtherArr.Conjugate(); // Real Image is roominverted
     
            if (! onlyZ)
        	  {
        	    optimize (1,AngleX,AngleY,AngleZ,XScale, YScale, ZScale, CenterX,CenterY,CenterZ,phase,width,Steps+3);
        	    cout << "Step 1 : optimized AngleY "<< AngleY  << "\n";
        	  }

        	 optimize (2,AngleX,AngleY,AngleZ,XScale, YScale, ZScale,CenterX,CenterY,CenterZ,phase,width/2,Steps+2);
        	 cout << "Step 2 : optimized AngleZ "<< AngleZ  << "\n";

        	if (! onlyZ)
        	  {
        	    optimize (0,AngleX,AngleY,AngleZ,XScale, YScale, ZScale,CenterX,CenterY,CenterZ,phase,width/2,Steps+2);
        	    cout << "Step 3 : optimized AngleX "<< AngleX  << "\n";
        	  }

        	 if (zstretch)
        	   {
                 optimize (5,AngleX,AngleY,AngleZ,XScale, YScale, ZScale,                     // Try to adjust ZScaling
        		   CenterX,CenterY,CenterZ,phase,width/2,Steps+2);
                   cout << "Step 4 : optimized ZScaling "<< ZScale  << "\n";
               }

        	 if (xstretch)
        	   {
        	     optimize (3,AngleX,AngleY,AngleZ,XScale, YScale, ZScale,CenterX,CenterY,CenterZ,phase,width/2,Steps+2);
        	     cout << "Step 4x : optimized XScaling "<< XScale  << "\n";
        	   }

        	 if (ystretch)
        	   {
        	     optimize (4,AngleX,AngleY,AngleZ,XScale, YScale, ZScale,CenterX,CenterY,CenterZ,phase,width/2,Steps+2);
        	     cout << "Step 4y : optimized YScaling "<< YScale  << "\n";
        	   }

        	if (! onlyZ)
        	  {
        	    optimize (1,AngleX,AngleY,AngleZ,XScale, YScale, ZScale,CenterX,CenterY,CenterZ,phase,width/8,Steps+2);
        	    cout << "Step 5 : optimized AngleY "<< AngleY  << "\n";
        	  }

        	 optimize (2,AngleX,AngleY,AngleZ,XScale, YScale, ZScale,CenterX,CenterY,CenterZ,phase,width/3,Steps+3);
        	 cout << "Step 6 : optimized AngleZ "<< AngleZ  << "\n";

           	if (! onlyZ)
           	  {
           	    optimize (0,AngleX,AngleY,AngleZ,XScale, YScale, ZScale,CenterX,CenterY,CenterZ,phase,width/3,Steps+3);
           	    cout << "Step 7 : optimized AngleX "<< AngleX  << "\n";
           	  }

            cout << "\noptimized Angles are "<< AngleX << ", " << AngleY << ", " << AngleZ << "\n";
            cout << "optimized Scalings are "<< XScale << ", " << YScale << ", " << ZScale << "\n\n";
            PrjArr.FFTbwd();
            CopyCtoR(& PrjArr,& rotPrj.Array);
       	 } // if ((i == 0) || (Elem2 > i))
	 else
	  {
	    cout << "No second element given for correllation ! Aligning with same as element " << i << "\n";
	    cout << "Warning : No correlation used at all !\n";

        PrepareProjector(AngleX,AngleY,AngleZ,XScale, YScale, ZScale);
        cout << "Angles are "<< AngleX << ", " << AngleY << ", " << AngleZ
        << "   XScale : " << XScale
        << "   YScale : " << YScale
        << "   ZScale : " << ZScale << "\n";
 	    cout << "Center is: " << CenterX << ", " << CenterY << ", " << CenterZ << "\n";
        AdjustCenter(CenterX,CenterY,CenterZ,XScale,YScale, ZScale); // Try using shifts to avoid correlation
        SetProjector();

	    rotPrj.Array.Clear();
	    rotPrj.ProjectImage(& Img);
	  }
     } //      else // correl != 0


     if (i==0)
     {
       to=rotPrj.Array.DWOpen(kflag,OFileName.c_str(),Elements);
       if (RAFileName!="")
         toraf=rangle.DWOpen(kflag,RAFileName.c_str(),Elements);
     }
     
     rotPrj.Array.Write(to);

     if (RAFileName!="")
       {
         rangle.SetValue(0,AngleX);
         rangle.SetValue(1,AngleY);
         rangle.SetValue(2,AngleZ);
         rangle.SetValue(3,CenterX);
         rangle.SetValue(4,CenterY);
         rangle.SetValue(5,CenterZ);
         rangle.SetValue(6,XScale);
         rangle.SetValue(7,YScale);
         rangle.SetValue(8,ZScale);
         rangle.SetValue(9,ShiftX);
         rangle.SetValue(10,ShiftY);
         rangle.SetValue(11,ShiftZ);
	     cout << " Wrote in Center to File : " << CenterX << ", " << CenterY << ", " << CenterZ << "\n";
	     cout << " Wrote in Shift to File : " << ShiftX << ", " << ShiftY << ", " << ShiftZ << "\n";
         rangle.Write(toraf);
       }
   }  // for (i=0 ...  



 to->close();
 delete to;
 if (toraf)
   toraf->close();
 cout << " used CPU time is " << clock()/(double) CLOCKS_PER_SEC << "  \n" << flush;
 
 return 0;
}


