%kvspeckle 'Reduce Speckle Noise Using the Crimmins Algorithm (K1)'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros vspeckle.pane file
%
% Parameters: 
% InputFile: i 'Input Image ', required: 'input image'
% Integer: n 'Number of Iterations', default: 1: 'Iterations'
% OutputFile: o 'Output Image ', required: 'output image'
%
% Example: o = kvspeckle(i, {'i','';'n',1;'o',''})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% vspeckle - Reduce Speckle Noise Using the Crimmins Algorithm  (K1)
%
%  DESCRIPTION
% .I vspeckle
% reduces the "speckle" noise from an image.  It uses 
% the "eight hull algorithm" developed by T. R. Crimmins to perform
% this reduction.  
% 
% The function takes one argument: "n" which determines how
% many times the image is to be sent through the speckle reducing filter.
% This filter uses the complementary hulling
% technique to reduce the speckle index of an image. 
% 
% Each pixel in the image is compared with all eight of its surrounding
% pixels.  The pixels above and below the pixel are the N-S pair, the
% pixels on either side are the E-W pair, those on the diagonals are the
% NW-SE and NE-SW pair. 
% The image and a pair of pixels 
% are sent to the symmetric hull function which in turn sends the image to
% the positive hull function 
% and to the negative hull function.  The positive and negative hull functions
% are called twice; the first time the neighboring pair of pixels is sent and
% the second time the complement of the pixels is sent.
% The positive hull function replaces each "middle pixel" with the 
% result of a several comparisons.  These comparison are a combination of
% maximums and minimums.  The final comparison is a maximum for the positive
% hull algorithm.
% The image is then sent to the negative hull function
% where the middle pixel is replaced with the result of more comparisons.
% The final comparison for the negative hull algorithm is a minimum.
% The result of all these replacements has the effect of reducing the undesired
% speckle noise while preserving the edges of the original image.
% The Geometric filter for speckle reduction is described in "Applied
% Optics\fR, Vol. 24, No. 10, 15 May 1985, "Geometric fileter for
% speckle reduction\fR, by Thomas R Crimmins. Another reference is
% Optical Engineering, May 1986 p653.
%
%  
%
%  EXAMPLES
% vspeckle -i image1 -o image2 -n 2
% 
% This command sends the image through the geometric filter twice.  
% Most of the speckle noise is removed from image1 and the result is
% stored in image2.
%
%  "SEE ALSO"
% lvspeckle(3)
%
%  RESTRICTIONS 
% .I vspeckle
% accepts only BYTE images.
% The number of iterations is limited to 20.
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kvspeckle(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kvspeckle(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'n', 1;'o', '__output'};
maxval={0,20,0};
minval={0,1,0};
istoggle=[0,1,0];
was_set=istoggle * 0;
paramtype={'InputFile','Integer','OutputFile'};
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
[varargout{:}]=callKhoros([w 'vspeckle"  '],Inputs,narglist);
