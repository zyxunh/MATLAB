%kLabel 'labels an image using a fixed threshhold '
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros Label.pane file
%
% Parameters: 
% Double: t 'Threshhold', default: 0.3: 'threshhold value'
% Toggle: m 'subtract minimum', default: 0: 'subtract minimum before evaluation'
% Double: at 'Absolute Threshhold', default: 100: 'threshhold at which to clip'
% Toggle: nsc 'No Enhanced COI', default: 0: 'Do not subtract Clipping Value before calculating COI'
% Integer: MV 'Min Volume', default: 2: 'minimal volume in voxels for spot'
% Double: MB 'Minimal Border Distance', default: 0: 'minimal distance to image borders in nm'
% Double: MI 'Min. Intensity', default: 0: 'minimal integrated intensity of spot to be counted'
% Toggle: labelFirst 'Only First Element for Labeling', default: 0: 'if selected, only the first element is used for the labelling, the others will be evaluated inside the labelled region'
% InputFile: i 'Input ', required: 'First Input data object'
% OutputFile: lo 'LabelOutput', required: 'Resulting output data object'
% OutputFile: ao 'AsciiOutput', optional: 'Ascii output data object'
% OutputFile: vo 'Binary Vector Output', optional: 'Binary output data object'
%
% Example: [lo, ao, vo] = kLabel(i, {'t',0.3;'m',0;'at',100;'nsc',0;'MV',2;'MB',0;'MI',0;'labelFirst',0;'i','';'lo','';'ao','';'vo',''})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% Label - labels an image using a fixed threshhold
%
%  DESCRIPTION
% This program labels and image by detecting connected regions.
% The connectivity rule is 6-connectivity in 3D. This means
% only pixels along the three coordinate axes are considered neighbours.
% The label output image has a 1:1 correspondence to the labels in the
% vector file and the ascii output.
%
%  
%
%  EXAMPLES
% Measuring the FRET efficiency of excocytotic vesicles on membrane patches.
% This can be done by using a "mask" as the first element and activating
% "only first element for labeling".
%
%  "SEE ALSO"
%
%  RESTRICTIONS 
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1996-2003, Rainer Heintzmann,  All rights reserved.
% 


function varargout = kLabel(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kLabel(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'t', 0.3;'m', 0;'at', 100;'nsc', 0;'MV', 2;'MB', 0;'MI', 0;'labelFirst', 0;'i', '__input';'lo', '__output';'ao', '__output';'vo', '__output'};
maxval={1,0,0,0,0,0,0,0,0,0,1,1};
minval={0,0,0,0,0,0,0,0,0,0,1,1};
istoggle=[0,1,1,1,0,0,0,1,0,0,1,1];
was_set=istoggle * 0;
paramtype={'Double','Toggle','Double','Toggle','Integer','Double','Double','Toggle','InputFile','OutputFile','OutputFile','OutputFile'};
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
[varargout{:}]=callKhoros([w 'label"  -k'],Inputs,narglist);
