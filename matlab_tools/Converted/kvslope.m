%kvslope 'Compute Slope and Aspect Images from Elevation Data (K1)'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros vslope.pane file
%
% Parameters: 
% InputFile: i 'Input Image ', required: 'input image'
% MultiChoice: so 'Slope Options (select one):', default: 1: 'slope options'
%    Choices are:
%   1: 'Degrees'
%   2: 'Radians'
%   3: 'Percent Rise'
% MultiChoice: to 'Aspect Options (select one):', default: 1: 'aspect options'
%    Choices are:
%   1: 'Degrees'
%   2: 'Radians'
%   3: 'Quadrants'
% Double: z 'Value for Regions With no Aspect (flat) ', default: 0: 'Value for Regions With no Aspect (flat)'
% OutputFile: s 'Slope Image ', optional: 'output slope image'
% OutputFile: t 'Aspect Image', optional: 'output aspect image'
%
% Example: [s, t] = kvslope(i, {'i','';'so',1;'to',1;'z',0;'s','';'t',''})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% vslope - Compute Slope and Aspect Images from Elevation Data  (K1)
%
%  DESCRIPTION
% .I vslope
% computes the slope and aspect images from an input elevation data.
% 
% The slope is always calculated as a positive number and
% represents the slope in the direction of the gradient at that point.
% The direction in which the slope is calculated depends only on the
% direction of the steepest gradient at the point.  The slope may be
% computed in three forms: degrees, radians, and percent rise.  Degrees
% and radians are used to measure the angle between a tangent to the
% surface at the point the slope is being calculated and a horizontal
% reference plane.  Percent rise is a measure of how much the tangent
% rises with respect to the horizontal distance.  For instance, if the
% tangent at a point rises 50 meters for every 100 meters horizontally,
% the slope is 50 percent.  The form used for the output slopes is selected
% using the command line argument '-so'.
% 
%         The aspect of the elevation image tells which direction the
% slope is facing.  The aspect is reported in the direction of
% the increasing slope.  The aspect may also be calculated in three
% forms: degrees, radians, and quadrants.  Degrees and radians give
% the clockwise angle between the positive x-axis (right to left on the
% image and east in geographical terms) and the direction the slope is
% facing.  For instance, if the slope is facing the top of the image (north)
% then the aspect will be 90 degrees or pi/2 radians.  When reported in
% quadrants, the aspect is given a value that depends on the range the
% direction it faces.  The circle is divided into 24 regions of 15 degrees
% each, and the region that the aspect falls in determines the value that will be 
% assigned to it.  North is always assumed to be at the top of the
% image, and East is always to the right.  A table of the quadrant
% values is given below:
% 
% 
% 
%     Aspect Value  Range in Degrees  Description
%          1           353 -   7     east facing
%          2             8 -  22     15 degrees north of east
%          3            23 -  37     degrees north of east
%          4            38 -  52     northeast facing
%          5            53 -  67     30 degrees east of north
%          6            68 -  82     15 degrees east of north
%          7            83 -  97     north facing
%          8            98 - 112     15 degrees west of north
%          9           113 - 127     30 degrees west of north
%         10           128 - 142     northwest facing
%         11           143 - 157     30 degrees north of west
%         12           158 - 172     15 degrees north of west
%         13           173 - 187     west facing
%         14           188 - 202     15 degrees south of west
%         15           203 - 217     30 degrees south of west
%         16           218 - 232     southwest facing
%         17           233 - 247     30 degrees west of south
%         18           248 - 262     15 degrees west of south
%         19           263 - 277     south facing
%         20           278 - 292     15 degrees east of south
%         21           293 - 307     30 degrees east of south
%         22           308 - 322     southeast facing
%         23           323 - 337     30 degrees south of east
%         24           338 - 352     15 degrees south of east
%         25        no aspect (flat)
% 
% 
% The form of the output aspect is selected using the '-to' command line
% argument.  When the surface has no slope, the aspect is undefined.  The
% value that will be assigned for an undefined aspect is set using the '-z'
% option on the command line.
% 
%         The input elevation file must be in viff format, and may be of
% type byte (VFF_TYP_1_BYTE), short (VFF_TYP_2_BYTE), int (VFF_TYP_4_BYTE),
% or float (VFF_TYP_FLOAT).  The input data will automatically be converted
% to float, and both the slope and aspect output files will always be
% type float regardless of the input data type.  Any type of map that is
% not forced (VFF_MAP_FORCE) is allowed on the input file, and the map will
% be transferred as is to the output.  Explicit location data is not allowed
% in the input file, and will result in an error.  The pixels in the input
% file are assumed to be evenly sampled where the sampling interval is given
% in the 'pixsizx' and 'pixsizy' fields in the viff header.  The units used
% for the sampling interval are arbitrary but must be the same units that
% the elevations in the file use.  The sampling interval is not allowed to
% be zero.  Finally, the input file is restricted to a single image.
%
%  
%
%  EXAMPLES
% vslope -i elevation.image -s slope.image -so 2 -t aspect.image -to 2
% 
% This command computes both the slope and the aspect images from the
% input elevation image.  "Elevation.image" is a float type image that
% is evenly sampled.  "Slope.image" is the output slope image.  It is
% type float, and the -so 2 option specifies that the slopes will be given
% in radians.  "Aspect.image" is the output aspect image.  It is also
% type float, and the -to 2 option specifies that the aspects will be given
% in radians.
%
%  "SEE ALSO"
% vsurf(1)
%
%  RESTRICTIONS 
% .I vslope
% works on input images with data types byte (VFF_TYP_1_BYTE), short
% (VFF_TYP_2_BYTE), int (VFF_TYP_4_BYTE), and float (VFF_TYP_FLOAT),
% but the type of the output image will always be float regardless of
% the input type.  Maps on the input image will be transferred directly
% to the output image, but forced maps (VFF_MAP_FORCE) are not accepted.
% Explicit location data is not accepted.  The input image is restricted
% to one image per file.
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kvslope(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kvslope(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'so', 1;'to', 1;'z', 0;'s', '__output';'t', '__output'};
maxval={0,0,0,0,1,1};
minval={0,0,0,0,1,1};
istoggle=[0,0,0,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','MultiChoice','MultiChoice','Double','OutputFile','OutputFile'};
% identify the input arrays and assign them to the arguments as stated by the user
if ~iscell(Inputs)
Inputs = {Inputs};
end
NumReqOutputs=0; nextinput=1; nextoutput=1;
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
[varargout{:}]=callKhoros([w 'vslope"  '],Inputs,narglist);
