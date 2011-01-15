%kcktoRGBNTSC 'convert from other color coordinate systems to RGB NTSC '
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros cktoRGBNTSC.pane file
%
% Parameters: 
% InputFile: i 'Input ', required: 'First Input data object'
% OutputFile: o 'Output RGB', required: 'Resulting output RGB data object'
% Toggle: rgbcie 'RGB CIE', default: 0: 'if specified will convert to RGB CIE color coordinate system'
% Toggle: retinalcone 'Retinal Cone', default: 0: 'if specified will convert to Retinal Cone color coordinate system'
% Toggle: sowstar 'S0W*', default: 0: 'if specified will convert to S0W* color coordinate system'
% Toggle: rgbsmpte 'RGB SMPTE', default: 0: 'if specified will convert to RGB SMPTE color coordinate system'
% Toggle: uvy 'uvY', default: 0: 'if specified will convert to uvY color coordinate system'
% Toggle: ihs 'IHS', default: 0: 'if specified will convert to IHS color coordinate system'
% Toggle: xyz 'XYZ', default: 0: 'if specified will convert to XYZ color coordinate system'
% Toggle: xyy 'xyY', default: 0: 'if specified will convert to xyY color coordinate system'
% Toggle: hsv 'HSV', default: 0: 'if specified will convert to HSV color coordinate system'
% Toggle: uvw 'UVW', default: 0: 'if specified will convert to UVW color coordinate system'
% Toggle: uvwstar 'U*V*W*', default: 0: 'if specified will convert to U*V*W* color coordinate system'
% Toggle: hls 'HLS', default: 0: 'if specified will convert to HLS color coordinate system'
% Toggle: yiq 'YIQ', default: 0: 'if specified will convert to YIQ color coordinate system'
% Toggle: labstar 'L*a*b*', default: 0: 'if specified will convert to L*a*b* color coordinate system'
% Toggle: cmy 'CMY', default: 0: 'if specified will convert to CMY color coordinate system'
% Toggle: yuv 'YUV', default: 0: 'if specified will convert to YUV color coordinate system'
% Toggle: luvstar 'L*u*v*', default: 0: 'if specified will convert to L*u*v* color coordinate system'
% Toggle: cmyk 'CMYK', default: 0: 'if specified will convert to CMYK color coordinate system'
% Toggle: i1i2i3 'I1I2I3', default: 0: 'if specified will convert to I1I2I3 color coordinate system'
% Toggle: lhcstar 'L*Ho*C*', default: 0: 'if specified will convert to L*Ho*C* color coordinate system'
%
% Example: o = kcktoRGBNTSC(i, {'i','';'o','';'rgbcie',0;'retinalcone',0;'sowstar',0;'rgbsmpte',0;'uvy',0;'ihs',0;'xyz',0;'xyy',0;'hsv',0;'uvw',0;'uvwstar',0;'hls',0;'yiq',0;'labstar',0;'cmy',0;'yuv',0;'luvstar',0;'cmyk',0;'i1i2i3',0;'lhcstar',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% cktoRGBNTSC - convert from other color coordinate systems to RGB NTSC
%
%  DESCRIPTION
% Convert from several different color coordinate systems to RGB NTSC (the "normal" RGB images used in computers). The supported input color coordinate systems are:
% RGB CIE - The 1931 CIE standard primary reference system
% RGB SMPTE - The Society of Motion Picture and Television
% Engineers receiver primary system
% XYZ - System where the tristimulus required to match a color
% are always positive
% UVW - Uniform Chromaticity Scale tristimulus system
% YIQ - NTSC Transmission color system
% YUV - PAL/SECAM Transmission color system
% Retinal Cone - Approximation of the human retinal responses
% uvY - based on u,v chromaticity coordinates (UCS)
% xyY - based on x,y chromaticity coordinates 
% U*V*W* - Perceptually uniform extension of UVW
% L*a*b* - Simple system that almost matches Munsell color
% system
% L*Ho*C* - The polar representation of L*a*b*
% L*u*v* - Evolved from L*a*b* and U*V*W*
% S0W* - The polar representation of U*V*W*
% IHS - Intensity, Hue, Saturation system
% HSV - Hue, Saturation, Value system
% CMY - The subtractive Cyan, Magenta, Yellow system
% CMYK - The subtractive Cyan, Magenta, Yellow and Black
% I1I2I3 - The I1,I2,I3 system based on R,G,B
%
%  
%
%  EXAMPLES
%
%  "SEE ALSO"
%
%  RESTRICTIONS 
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1997 Rafael Santos. Khoros (C) Khoral Research, Inc.
% 


function varargout = kcktoRGBNTSC(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kcktoRGBNTSC(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'o', '__output';'rgbcie', 0;'retinalcone', 0;'sowstar', 0;'rgbsmpte', 0;'uvy', 0;'ihs', 0;'xyz', 0;'xyy', 0;'hsv', 0;'uvw', 0;'uvwstar', 0;'hls', 0;'yiq', 0;'labstar', 0;'cmy', 0;'yuv', 0;'luvstar', 0;'cmyk', 0;'i1i2i3', 0;'lhcstar', 0};
maxval={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
minval={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
istoggle=[0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','OutputFile','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle'};
% identify the input arrays and assign them to the arguments as stated by the user
if ~iscell(Inputs)
Inputs = {Inputs};
end
NumReqOutputs=1; nextinput=1; nextoutput=1;
  for ii=1:size(arglist,1)
  wasmatched=0;
  for jj=1:size(narglist,1)
   if strcmp(arglist{ii,1},narglist{jj,1})  % a given argument was matched to the possible arguments
     wasmatched = 1;
     was_set(jj) = 1;
     if strcmp(narglist{jj,2}, '__input')
      if (nextinput > length(Inputs)) 
        error(['Input ' narglist{jj,1} ' has no corresponding input!']); 
      end
      narglist{jj,2} = 'OK_in';
      nextinput = nextinput + 1;
     elseif strcmp(narglist{jj,2}, '__output')
      if (nextoutput > nargout) 
        error(['Output nr. ' narglist{jj,1} ' is not present in the assignment list of outputs !']); 
      end
      if (isempty(arglist{ii,2}))
        narglist{jj,2} = 'OK_out';
      else
        narglist{jj,2} = arglist{ii,2};
      end

      nextoutput = nextoutput + 1;
      if (minval{jj} == 0)  
         NumReqOutputs = NumReqOutputs - 1;
      end
     elseif isstr(arglist{ii,2})
      narglist{jj,2} = arglist{ii,2};
     else
        if strcmp(paramtype{jj}, 'Integer') & (round(arglist{ii,2}) ~= arglist{ii,2})
            error(['Argument ' arglist{ii,1} ' is of integer type but non-integer number ' arglist{ii,2} ' was supplied']);
        end
        if (minval{jj} ~= 0 | maxval{jj} ~= 0)
          if (minval{jj} == 1 & maxval{jj} == 1 & arglist{ii,2} < 0)
            error(['Argument ' arglist{ii,1} ' must be bigger or equal to zero!']);
          elseif (minval{jj} == -1 & maxval{jj} == -1 & arglist{ii,2} > 0)
            error(['Argument ' arglist{ii,1} ' must be smaller or equal to zero!']);
          elseif (minval{jj} == 2 & maxval{jj} == 2 & arglist{ii,2} <= 0)
            error(['Argument ' arglist{ii,1} ' must be bigger than zero!']);
          elseif (minval{jj} == -2 & maxval{jj} == -2 & arglist{ii,2} >= 0)
            error(['Argument ' arglist{ii,1} ' must be smaller than zero!']);
          elseif (minval{jj} ~= maxval{jj} & arglist{ii,2} < minval{jj})
            error(['Argument ' arglist{ii,1} ' must be bigger than ' num2str(minval{jj})]);
          elseif (minval{jj} ~= maxval{jj} & arglist{ii,2} > maxval{jj})
            error(['Argument ' arglist{ii,1} ' must be smaller than ' num2str(maxval{jj})]);
          end
        end
     end
     if ~strcmp(narglist{jj,2},'OK_out') &  ~strcmp(narglist{jj,2},'OK_in') 
       narglist{jj,2} = arglist{ii,2};
     end
   end
   end
   if (wasmatched == 0 & ~strcmp(arglist{ii,1},''))
        error(['Argument ' arglist{ii,1} ' is not a valid argument for this function']);
   end
end
% match the remaining inputs/outputs to the unused arguments and test for missing required inputs
 for jj=1:size(narglist,1)
     if  strcmp(paramtype{jj}, 'Toggle')
        if (narglist{jj,2} ==0)
          narglist{jj,1} = ''; 
        end;
        narglist{jj,2} = ''; 
     end;
     if  ~strcmp(narglist{jj,2},'__input') && ~strcmp(narglist{jj,2},'__output') && istoggle(jj) && ~ was_set(jj)
          narglist{jj,1} = ''; 
          narglist{jj,2} = ''; 
     end;
     if strcmp(narglist{jj,2}, '__input')
      if (minval{jj} == 0)  % meaning this input is required
        if (nextinput > size(Inputs)) 
           error(['Required input ' narglist{jj,1} ' has no corresponding input in the list!']); 
        else
          narglist{jj,2} = 'OK_in';
          nextinput = nextinput + 1;
        end
      else  % this is an optional input
        if (nextinput <= length(Inputs)) 
          narglist{jj,2} = 'OK_in';
          nextinput = nextinput + 1;
        else 
          narglist{jj,1} = '';
          narglist{jj,2} = '';
        end;
      end;
     else 
     if strcmp(narglist{jj,2}, '__output')
      if (minval{jj} == 0) % this is a required output
        if (nextoutput > nargout & nargout > 1) 
           error(['Required output ' narglist{jj,1} ' is not stated in the assignment list!']); 
        else
          narglist{jj,2} = 'OK_out';
          nextoutput = nextoutput + 1;
          NumReqOutputs = NumReqOutputs-1;
        end
      else % this is an optional output
        if (nargout - nextoutput >= NumReqOutputs) 
          narglist{jj,2} = 'OK_out';
          nextoutput = nextoutput + 1;
        else 
          narglist{jj,1} = '';
          narglist{jj,2} = '';
        end;
      end
     end
  end
end
if nargout
   varargout = cell(1,nargout);
else
  varargout = cell(1,1);
end
global KhorosRoot
if exist('KhorosRoot') && ~isempty(KhorosRoot)
w=['"' KhorosRoot];
else
if ispc
  w='"C:\Program Files\dip\khorosBin\';
else
[s,w] = system('which cantata');
w=['"' w(1:end-8)];
end
end
[varargout{:}]=callKhoros([w 'cktoRGBNTSC"  '],Inputs,narglist);
