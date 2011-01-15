#ifndef MAPPR_h
#define MAPPR_h

/*   This file is part of a software package written by 
     Rainer Heintzmann
     No garantee, whatsoever is given about functionality and  savety.
     No warranty is taken for any kind of damage it may cause.
     No support for it is provided !

     THIS IS NOT FREE SOFTWARE. All rights are reserved, and the software is only
     given to a limited number of persons for evaluation purpose !
     Please do not modify and/or redistribute this file or any other files, libraries
     object files or executables of this software package !
*/

// This file contains mathematic functions to be applied during the 
// maximum a posteriori likelihood poisson noise, good's roughness reconstruction

// the result is always stored in this array
template<class BaseType>
class MAPPRArray : public TFFTArray<BaseType> { 

  typedef BaseType MArrayBaseType;
 public:
  MAPPRArray(int SizeX,int SizeY=1,int SizeZ=1) : TFFTArray<MArrayBaseType> (SizeX,SizeY,SizeZ) {}
  MAPPRArray() : TFFTArray<MArrayBaseType> () {}

  // These have to work in complex space as well !!
  void Mul(double a) {TFFTArray<MArrayBaseType>::Mul(a);} 
  void Mul(MAPPRArray * a) {TFFTArray<MArrayBaseType>::Mul(a);} 
  void Mul(MAPPRArray & a, MAPPRArray & b)  // = a*b, overwriting the contens
    {
      transform(a.TheArray.begin(),a.TheArray.end(),b.TheArray.begin(),TFFTArray<BaseType>::TheArray.begin(),
		multiplies<MArrayBaseType>()); 
    }

  int  GetLogicSize(int dim) {return TFFTArray<BaseType>::GetLogicSize(dim);}

  void ComputeOneMinDiv(MAPPRArray & g,float backgr)  // reconPrj = 1 - g / (Hx2 + b)
    {
      float tmp;
      int DimX=GetLogicSize(0);  // Do not calculate for unused x positions
      int DimY=GetLogicSize(1);
      int DimZ=GetLogicSize(2);
      for (int z=0;z<DimZ;z++)
	for (int y=0;y<DimY;y++)
	  for (int x=0;x<DimX;x++)
	    {
	      tmp=TFFTArray<BaseType>::Value(x,y,z) + backgr;

	      if (tmp == 0.0)
		{
		  cerr << "WARNING: Division by zero! tmp is " << tmp << " at " << x << " " << y << "  " << z << "  " << "\n";
		  tmp= 1e-06;
		}
	      
	      TFFTArray<BaseType>::SetValue(x,y,z, 1.0 - g.Value(x,y,z) / tmp);
	    }
    }

// reconPrj should contain Ht convolved with 1 - g/(Hx2+b), self is Hxd, where the result should be added to
void ComputeDPsiSumSqrNoLaplace(MAPPRArray & reconPrj,MAPPRArray & X,double weight)  // DeltaPsi will be added to in Hxd
  {
    int DimX=GetLogicSize(0);  // Do not calculate for unused x positions
    int DimY=GetLogicSize(1);
    int DimZ=GetLogicSize(2);
    for (int z=0;z<DimZ;z++)
      for (int y=0;y<DimY;y++)
	for (int x=0;x<DimX;x++)
	  {
	    TFFTArray<BaseType>::SetValue(x,y,z, TFFTArray<BaseType>::Value(x,y,z) + weight*2.0*X.Value(x,y,z) * reconPrj.Value(x,y,z));
	  }
    return;
  }

// On the last run though the array the laplacian is also added to nablaPsi and the norm of the result
// Polak Ribiere: ...,double gamma, double & rrold,double weight) 
double ComputeDPsiSumSqr(MAPPRArray & preadded,MAPPRArray & reconPrj,MAPPRArray & X,double gamma, double weight)  // DeltaPsi will be added to in Hxd, sumsqr will be returned to calculate beta
  {
    int DimX=GetLogicSize(0);
    int DimY=GetLogicSize(1);
    int DimZ=GetLogicSize(2);
    int dx1,dx2,dy1,dy2,dz1,dz2;
    float vx=0, tmp, sumsqr=0;
    // For Polak-Ribiere:
    // rrold = 0;

    for (int z=0;z<DimZ;z++)
      {
	dz1=1, dz2=1;
	if (z==0) dz1=0;
	if (z==DimZ-1) dz2=0;

	for (int y=0;y<DimY;y++)
	  {
	    dy1=1, dy2=1;
	    if (y==0) dy1=0;
	    if (y==DimY-1) dy2=0;

	    for (int x=0;x<DimX;x++)
	      {
		dx1=1, dx2=1;
		if (x==0) dx1=0;
		if (x==DimX-1) dx2=0;

		vx = X.Value(x,y,z); 

		// For the computation of the laplacian, the sampling intervall is ignored.
		// This is maybe justified, by the fact, that different directions should have different
		// smoothness in the panalty term !
		// The previvously computed component are included, saved and the norm of the total is taken
		tmp = preadded.Value(x,y,z) + weight*2.0*vx * reconPrj.Value(x,y,z)  
		    - 8.0* gamma * ( -6*vx // this term is d=3 dimensions * -2x(u) =-6 + vx
		    + X.Value(x-dx1,y,z) + X.Value(x+dx2,y,z) +  X.Value(x,y-dy1,z) + X.Value(x,y+dy2,z) 
		    + X.Value(x,y,z-dz1) + X.Value(x,y,z+dz2)) ;
		sumsqr += tmp*tmp;
		// The calculation below is only for Polak-Ribiere
		// rrold += Value(x,y,z)*tmp;  // compute scalar product r_(i+1)  * r_i  for Polak-Ribiere
		TFFTArray<BaseType>::SetValue(x,y,z,tmp);  // in self (NablaPsi) which is abused at the moment to temporarily store namblaH
	      }
	  }
      }
    return sumsqr;
  }


void ComputeSteepest(MAPPRArray & DeltaPsi)  // dk = - DeltaPsi; this is also correct for multiple elements , self is dk-1 to become dk
  {
    int DimX=GetLogicSize(0);  // Do not calculate for unused x positions
    int DimY=GetLogicSize(1);
    int DimZ=GetLogicSize(2);
    for (int z=0;z<DimZ;z++)
      for (int y=0;y<DimY;y++)
	for (int x=0;x<DimX;x++)
	  {
	    // self is old d(k-1)
	    TFFTArray<BaseType>::SetValue(x,y,z, - DeltaPsi.Value(x,y,z));
	  }
  }

void ComputeDK(double betha,MAPPRArray & DeltaPsi)  // dk = bk * d(k-1) - DeltaPsi; this is also correct for multiple elements , self is dk-1 to become dk
  {
    int DimX=GetLogicSize(0);  // Do not calculate for unused x positions
    int DimY=GetLogicSize(1);
    int DimZ=GetLogicSize(2);
    for (int z=0;z<DimZ;z++)
      for (int y=0;y<DimY;y++)
	for (int x=0;x<DimX;x++)
	  {
	    // self is old d(k-1)
	    TFFTArray<BaseType>::SetValue(x,y,z, betha * TFFTArray<BaseType>::Value(x,y,z) - DeltaPsi.Value(x,y,z));
	  }
  }

double ComputeLfabsX(double alpha,MAPPRArray & d)  // recompute the laplacian for d * L fabs(x_k + alpha * d)
   {
    int DimX=TFFTArray<BaseType>::GetLogicSize(0); int DimY=TFFTArray<BaseType>::GetLogicSize(1); int DimZ=TFFTArray<BaseType>::GetLogicSize(2);
    int dx1,dx2,dy1,dy2,dz1,dz2;
    double Result=0.0;
    for (int z=0;z<DimZ;z++)
      {
	dz1=1, dz2=1;
	if (z==0) dz1=0;
	if (z==DimZ-1) dz2=0;

	for (int y=0;y<DimY;y++)
	  {
	    dy1=1, dy2=1;
	    if (y==0) dy1=0;
	    if (y==DimY-1) dy2=0;

	    for (int x=0;x<DimX;x++)
	      {
		dx1=1, dx2=1;
		if (x==0) dx1=0;
		if (x==DimX-1) dx2=0;

		// calculate the Laplacian product d * Laplace(fabs(x_k + alpha + d) 
		Result +=  d.Value(x,y,z) * (-6.0* fabs(TFFTArray<BaseType>::Value(x,y,z) + alpha*d.Value(x,y,z))
				 + fabs(TFFTArray<BaseType>::Value(x-dx1,y,z) + alpha*d.Value(x-dx1,y,z))
				 + fabs(TFFTArray<BaseType>::Value(x+dx2,y,z) + alpha*d.Value(x+dx2,y,z))
				 + fabs(TFFTArray<BaseType>::Value(x,y-dy1,z) + alpha*d.Value(x,y-dy1,z))
				 + fabs(TFFTArray<BaseType>::Value(x,y+dy2,z) + alpha*d.Value(x,y+dy2,z))
				 + fabs(TFFTArray<BaseType>::Value(x,y,z-dz1) + alpha*d.Value(x,y,z-dz1))
				 + fabs(TFFTArray<BaseType>::Value(x,y,z+dz2) + alpha*d.Value(x,y,z+dz2)));
	      }
	  }
      }
    return Result;
  }

// self should contain d for the function below, dLx is actually computed as xLd, to speed it up. 
void Compute_dLx_dLd(MAPPRArray & X, double & dLx, double & dLd, double & minalpha, double & maxalpha)  // computes the sum over laplacians: d * L * x , and d * L * d
  {
    int DimX=GetLogicSize(0);
    int DimY=GetLogicSize(1);
    int DimZ=GetLogicSize(2);
    int dx1,dx2,dy1,dy2,dz1,dz2;
    double vx,vd;  // variables to store the local value of the fields
    double Ld;
    maxalpha=1e30;  // maximal positive alpha to not cause negative values in (x+alpha d) which invalidates L(x+alpha d)
    minalpha=-1e30; // minimal negative alpha to not cause negative values in (x+alpha d) which invalidates L(x+alpha d)

    dLx=0;
    dLd=0;
    
    for (int z=0;z<DimZ;z++)
      {
	dz1=1, dz2=1;
	if (z==0) dz1=0;
	if (z==DimZ-1) dz2=0;

	for (int y=0;y<DimY;y++)
	  {
	    dy1=1, dy2=1;
	    if (y==0) dy1=0;
	    if (y==DimY-1) dy2=0;

	    for (int x=0;x<DimX;x++)
	      {
		dx1=1, dx2=1;
		if (x==0) dx1=0;
		if (x==DimX-1) dx2=0;

		vx = X.Value(x,y,z); 
		vd = TFFTArray<BaseType>::Value(x,y,z);   // d is stored in self
		// calculate the Laplacian for x and d for this voxel
		Ld = -6.0*vd + TFFTArray<BaseType>::Value(x-dx1,y,z) + TFFTArray<BaseType>::Value(x+dx2,y,z) +  TFFTArray<BaseType>::Value(x,y-dy1,z) + TFFTArray<BaseType>::Value(x,y+dy2,z) 
		     + TFFTArray<BaseType>::Value(x,y,z-dz1) + TFFTArray<BaseType>::Value(x,y,z+dz2);  // self is d
		dLd += vd * Ld;
		// Lx does not need to be calculated since : dt * L * x == xt * L * d
		dLx += vx * Ld;

		// if (vx < 0.0) cout << "error : vx < 0 at ("<<x<<","<<y<<","<<z<<")\n";

		if (vd > 0.0)
		  {
		    if (- vx/vd > minalpha)
		      minalpha = - vx/vd;
		  }
		else
		  {
		    if (- vx/vd < maxalpha)
		      maxalpha = - vx/vd;
		  }
	      }
	  }
      }
    cout << "alpha boundaries: ("<<minalpha<<" to "<<maxalpha<<") for non-negativity in (x + alpha * d) \n";
  }


// Even if x is fabs(x + alpha d) the formula below should work, since Hx2 is the same with or without clipping
/// Will write Hx2 into self, while computing it from  Hx^2 = Hx2 + 2*alpha*Hxd + alpha^2*Hd2  
 void ComputeHx2(float alpha, MAPPRArray & Hx2,MAPPRArray & Hxd,MAPPRArray & Hd2)  // will be called for a specific element
 {
   float alpha2 = alpha*alpha;
   float alpham2 = 2*alpha;
   int DimX=GetLogicSize(0);  // Do not calculate for unused x positions
   int DimY=GetLogicSize(1);
   int DimZ=GetLogicSize(2);
   for (int z=0;z<DimZ;z++)
     for (int y=0;y<DimY;y++)
       for (int x=0;x<DimX;x++)
	 {
	    // self is old d(k-1)
	    TFFTArray<BaseType>::SetValue(x,y,z, Hx2.Value(x,y,z) + alpham2*Hxd.Value(x,y,z) + alpha2*Hd2.Value(x,y,z));
	 }
 }

// self should contain reconImg == xk
 void NewtonIter(double & alpha,double minalpha, double maxalpha,int Elements,MAPPRArray & d,
		 MAPPRArray g[],MAPPRArray Hxd[],MAPPRArray Hd2[], MAPPRArray Hx2[], 
		 double dLx, double dLd, double gamma, double * backgr, 
		 double weights[], int iternum=3)  // Hx2,Hxd,Hd2,d,gamma   -> alpha
  {
    int DimX=GetLogicSize(0);
    int DimY=GetLogicSize(1);
    int DimZ=GetLogicSize(2);
    double Dpsi,D2psi;
    double LaplaceTerm =dLx + alpha * dLd; // include the global penalty functions

    float vx,vd,vhxd, vhx2, vhd2, vg,tmp1,tmp2,tmp3;  // variables to store the local value of the fields
    float alpha2, alphaOld;
    cout << "Starting alpha iteration : alpha = "<< alpha << "\n";

    for (int i=0;i< iternum;i++)
      {
	alpha2=alpha*alpha;  // squared alpha
	Dpsi=0.0;   // This is the derivative of Psi with respect to alpha
	D2psi=0.0;  // This is the 2nd derivative of Psi with respect to alpha

	for (int z=0;z<DimZ;z++)
	  for (int y=0;y<DimY;y++)
	    for (int x=0;x<DimX;x++)
	      {
		vx = TFFTArray<BaseType>::Value(x,y,z); // self is the actual guess xk
		vd = d.Value(x,y,z); 
		for (int elem=0;elem < Elements;elem++)
		  {
		    vhxd = Hxd[elem].Value(x,y,z);
		    vhx2 = Hx2[elem].Value(x,y,z);  
		    vhd2 = Hd2[elem].Value(x,y,z);
		    vg = g[elem].Value(x,y,z); 
	    
		    // pre compute some terms
		    tmp1= vhx2 + 2.0*alpha*vhxd + alpha2*vhd2 + backgr[elem];
		    tmp2= 2.0*(1.0- vg / tmp1);
		    // Now the derivatives d psi / d alpha and d2 psi / d alpha2
		    Dpsi += weights[elem]* tmp2 * (vhxd+alpha*vhd2); 
		    tmp3 = (vhxd + alpha* vhd2) / tmp1;
		    tmp3 *= tmp3;
		    D2psi += weights[elem]* (tmp2 * vhd2 + 4.0 * vg * tmp3);
		  }
	      }

	alphaOld=alpha; // remember alpha

	Dpsi -= 8.0 * gamma * LaplaceTerm; // L(fabs(dLx + alpha * dLd)); // include the global penalty functions
	D2psi -= 8.0 * gamma * dLd; 
	if (D2psi == 0.0)
	  {
	    cerr << "D2Psi == 0 during Newton iteration !! alpha set to one\n";
	    alpha=1.0;
	  }
	else
	  alpha -= Dpsi /D2psi;   // Newton iteration

	if ((alpha < minalpha) || (alpha > maxalpha))
	  {
	    cout << "WARNING ! alpha has exceeded its boundaries ("<<minalpha<<" to "<<maxalpha<<") for non-negativity in (x + alpha * d) !\n";
	    cout << "Recomputing correct Laplace term\n";
	    // Go back and reestimate the Laplaceterm, D2psi is still OK
	    Dpsi += 8.0 * gamma * LaplaceTerm;  // compensate
	    LaplaceTerm=ComputeLfabsX(alphaOld,d);
	    Dpsi -= 8.0 * gamma * LaplaceTerm;  // this should be correct
	    alpha = alphaOld - Dpsi /D2psi;   // Newton iteration
	    cout << "d*Laplace(fabs(x+alpha*d) is " << LaplaceTerm << " instead of " << dLx + alpha * dLd << "\n";
	  }
        else 
	  LaplaceTerm =dLx + alpha * dLd; // no need to recompute the laplacian

	cout << "Iterating alpha :  "<< i <<"  " << alpha << "\n";
      }
  }

void UpdateXk(MAPPRArray & correctionImg,double alpha) // xk+1 = xk + alpha dk,  xk is self
  {
   int DimX=GetLogicSize(0);  // Do not calculate for unused x positions
   int DimY=GetLogicSize(1);
   int DimZ=GetLogicSize(2);
   for (int z=0;z<DimZ;z++)
     for (int y=0;y<DimY;y++)
       for (int x=0;x<DimX;x++)
	 {
	  // pdk is correctionImg
	  // make sure that all xk are positive, otherwise the laplacian might get confused
	    TFFTArray<BaseType>::SetValue(x,y,z, fabs(TFFTArray<BaseType>::Value(x,y,z) + alpha*correctionImg.Value(x,y,z)));
	    //  SetValue(x,y,z, Value(x,y,z) + alpha*correctionImg.Value(x,y,z));
	}
  }
};

template <class ArrayType1,class BaseType>
void Copy(ArrayType1 * arr1,MAPPRArray<BaseType> * arr2) // copy part of array centered
{
  // cout << "specialized copy normal->MAPPR called\n";
  Copy<ArrayType1,BaseType >(arr1,(TFFTArray<BaseType> *) arr2);  // This will call exactly the versions of the underlying TFFTArray
}

template <class BaseType>
void Copy(MAPPRArray<BaseType> * arr1,MAPPRArray<BaseType> * arr2) // specialization between this array type
{
  // cout << "specialized copy MAPPR->MAPPR called\n";
  Copy<BaseType ,BaseType>((TFFTArray<BaseType> *)arr1,(TFFTArray<BaseType> *)arr2); // This will call exactly the versions of the underlying TFFTArray
}

#endif
