// This program parses mime-tags of a form and redirects the user

/*   This file is part of a software package written by 
     Rainer Heintzmann
     Institute of Applied Optics and Information Processing
     Albert Ueberle Strasse 3-5
     69120 Heidelberg
     Tel.: ++49 (0) 6221  549264
     Current Address : Max Planck Inst. for biophysical Chemistry, Am Fassberg 11, 37077 Goettingen, Germany
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
#include <fstream>
#include "mime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string>
using namespace std;


int main(void)
{
  int SizeX=64,SizeY=64,SizeZ=64,SizeE=1,userfile=0,filelength=0,maxsize= 512*512*128,Bits=8,Bytes=1;
  bool justload=false;
  string mimetag,content,tagname,SFile,TBFile,WLFile,NFFile, FileName,filename, emailnotify,Webpath,DataDir="data/";
  getline(cin,mimetag);

  while (1)
    {
      tagname=ReadMime(cin,mimetag,content,filename);
      // logline("Tag: "+tagname+"\nContentent:"+content+"\n");

      if (tagname.compare("eof") == 0) break;
      if (tagname.compare("JustLoad") == 0) {justload=true;}
      if (tagname.compare("SizeX") == 0) {SizeX = atoi(content.c_str());}
      if (tagname.compare("SizeY") == 0) {SizeY = atoi(content.c_str());}
      if (tagname.compare("SizeZ") == 0) {SizeZ = atoi(content.c_str());}
      if (tagname.compare("SizeE") == 0) {SizeE = atoi(content.c_str());}
      if (tagname.compare("Bytes") == 0) {Bytes = atoi(content.c_str());}
      if (tagname.compare("Bits") == 0) {Bits = atoi(content.c_str());}
      if (tagname.compare("EMailNotify") == 0) {emailnotify = content.substr(0,content.length()-2);}
      if (tagname.compare("DataDir") == 0) {DataDir = content.substr(0,content.length()-2);}
      if (tagname.compare("WebPath") == 0) {Webpath = content.substr(0,content.length()-2);}
      if (tagname.compare("MaxSize") == 0) {maxsize = atoi(content.c_str());}
      if (tagname.compare("Success") == 0) {SFile=content;}
      if (tagname.compare("ErrTooBig") == 0) {TBFile=content;}
      if (tagname.compare("ErrWrongLength") == 0) {WLFile=content;}
      if (tagname.compare("ErrNoFile") == 0) {NFFile=content;}
      if (tagname.compare("FileName") == 0) {FileName=content;}
      if (tagname.compare("ClearDataDir") == 0) {
	string clearcommand= "rm "+DataDir+"/* \n";
	logline(clearcommand);
	system(clearcommand.c_str());
	if (! SFile.length())
	   cout << "Location: Cleared.html\n\n" << flush;
	else
	   cout << "Location: "+SFile+"\n\n" << flush;
      }
      if (tagname.compare("userfile") == 0) 
	{
	  userfile=1;
	  if (! FileName.length())
	    FileName = filename;
	    // FileName ="upload.raw";
	  else
	  {
	    int spos = FileName.rfind("/");
	    if (spos < 0 || spos >= FileName.length()) spos=0;
	    FileName = FileName.substr(spos,FileName.length()-spos-2);
	  }
	  if (! justload)
	    {
	      system("rm -f upload/upload.raw");
	      system("rm -f upload/upload.sx");
	      system("rm -f upload/upload.sy");
	      system("rm -f upload/upload.sz");
	    }

	  ofstream of((DataDir+FileName).c_str());
	  if (! of) cerr << "Cannot open file !\n";
	  int clen = content.length();
	  content=content.substr(2,clen-4);
	  // cout << content;
	  of << content;    // writes everthing to the file
	  of.close();

	  filelength = content.length();
	}
    }
      
  // cout << "Content-type: text/html\n\n";  // not necessary -> nph-script

  if (userfile && filelength != 0)
    {

      if (filelength > maxsize)
	{
	  if (! TBFile.length())
	    cout << "Location: toobig.html\n\n" << flush;
	  else
	    cout << "Location: " << TBFile << "\n\n" << flush;
	}
      else
      {
	int rbytes = Bytes;
	if (Bytes <= 0)
	  rbytes = 4;

	if ((! justload) && filelength != SizeX*SizeY*SizeZ*SizeE*rbytes)
	{
	  if (! WLFile.length())
	  cout << "Location: wronglength.html\n\n" << flush;
	  else
	  cout << "Location: " << WLFile << "\n\n" << flush;
	  
	  ofstream of("upload/wronglength");
	  if (! of) cerr << "Can not open file wronglength!\n";
	  of << filelength << "\n";
	  of.close();
	}
	else    {
	  if (justload)
	  {
	    if (! SFile.length())
	    cout << "Location: justloaded.html\n\n" << flush;
	    else
	    cout << "Location: " << SFile << "\n\n" << flush;
	  }
	  else
	  {
	    ofstream of("upload/upload.sx");
	    if (! of) cerr << "Cannot open file upload.sx!\n";
	    of << SizeX << "\n";
	    of.close();
	    of.open("upload/upload.sy");
	    if (! of) cerr << "Cannot open file upload.sy!\n";
	    of << SizeY << "\n";
	    of.close();
	    of.open("upload/upload.sz");
	    if (! of) cerr << "Cannot open file upload.sz!\n";
	    of << SizeZ << "\n";
	    of.close();
	    of.open("upload/upload.se");
	    if (! of) cerr << "Cannot open file upload.se!\n";
	    of << SizeZ << "\n";
	    of.close();

	    ifstream inf("upload/part1");
	    if (of) 
	    {
	      char tmpstr;
	      of.open("upload/Display.html");
	      if (! of) cerr << "Cannot open file upload.se!\n";
	      do {
	      tmpstr=inf.get();  // copy input file to output file until EOF
	      if (! inf.eof())
	      of << tmpstr;
	      } while (! inf.eof());
	      
	      of << "<param name=file value=" << FileName <<">\n";
	      of << "<param name=sizex value=" << SizeX << ">\n";
	      of << "<param name=sizey value=" << SizeY << ">\n";
	      of << "<param name=sizez value=" << SizeZ << ">\n";
	      of << "<param name=bytes value=" << Bytes << ">\n";
	      of << "<param name=bits value=" << Bits << ">\n";
	      of << "<param name=elements value=" << SizeE << ">\n";
	      inf.close();
	      inf.open("upload/part2");
	      if (! of) cerr << "Cannot open part2 file!\n";
	      do {
	      tmpstr=inf.get();  // copy input file to output file until EOF
	      if (! inf.eof())
	      of << tmpstr;
	      } while (! inf.eof());
	      of.close();
	    }


	    if (! SFile.length())
	    cout << "Location: success.html\n\n" << flush;
	    else
	    cout << "Location: " << SFile << "\n\n" << flush;

	  }
	  
	  if (emailnotify != "")
	    {
	      string notification= "echo \"Subject: data uploaded\nA user uploaded a file named: "+Webpath+DataDir+FileName+"\n\n\nTo clear the data directory click: "+Webpath+"ClearDataDir.html \" | mail "+emailnotify+"\n";
	      // logline(notification);
	      system(notification.c_str());
	    }
	}
      }
    }
  else
    {
      if (! NFFile.length())
	cout << "Location: nofile.html\n\n" << flush;
      else
	cout << "Location: " << NFFile << "\n\n" << flush;
    }


  // logline(string("closefile"));
  // cout << ReadMime(cin,content) << "\n";
} 
