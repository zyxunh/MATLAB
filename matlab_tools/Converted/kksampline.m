%kksampline 'Sample a data object along an arbitrary line'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros ksampline.pane file
%
% Parameters: 
% InputFile: i 'Input ', required: 'input data object'
% Integer: n 'Number of samples (including endpoints)', default: 1000: 'number of samples (including endpoints)'
% Integer: nc 'Minimum required neighbor count', default: 0: 'minimum required neighbor count'
% OutputFile: o 'Output', required: 'output data object'
%
% Example: o = kksampline(i, {'i','';'n',1000;'nc',0;'o',''})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% ksampline - Sample a data object along an arbitrary line
%
%  DESCRIPTION
% .I ksampline
% is used to sample the data in an object along an arbitrary line and at
% arbitrary intervals. The value at each sample point is obtained by
% an inverse distance weighting scheme.
% 
% The first sample point is precisely at the starting coordinate and
% the final sample is precisely at the ending coordinate.
% 
% The line may traverse any portion of the 5D data space. If a particular
% sample on the line lies outside the data space then the values will be 
% interpolated using a padding value of zero.
% 
% The output object will be of the same data type as the input object. If
% a map is present in the input object, then the value data is sent through the
% map before processing. The output data will thus have no map.
% 
% Mask data, if present, is used to help control the interpolation.
% Value points with a corresponding mask value of zero will not be included
% in the interpolated value. However, a minimum number of neighboring
% values with a valid mask are required in order to produce a valid output
% value; non-valid output values are marked by a zero mask. If the mask
% segment is not present, then all value points in the source object are assumed 
% to be valid.
% 
% The actual minimum
% required neighbor count is determined by the setting of the "nc" argument.
% If nc is zero, then the minimum required neighbor count will be computed from
% the dimensionality of the source data set. For nc=0, the minimum required
% neighbor count is 0.5*(2^dim)+1 where dim is the dimensionality of
% the source object (1 for a line, 2 for a plane, 3 for a volume, etc). 
% If nc is non-zero, then the minimum required neighbor count is simply nc.
% Beware of non-intuitive results when interpolating across mask wise non-convex
% parts of the data object. The default minimum required neighbor count
% gives "reasonable" answers in these cases. Reducing the minimum required
% neighbor count can provide answers that are less and less meaningful.
% 
% Note that ksampline samples the data as if it were using a delta function.
% This implies that you may get significantly different
% results depending on the position of each sample location. You may wish to
% lowpass the source data before sampling with ksampline to avoid aliasing.
% This can be particularly important when dealing with "holey data" or when
% the sampling involves degenerate geometry (such as sampling a plane object
% with a sampling line that does not lie in the plane).
% 
% ksampline is implemented using "point\fR data access. A point data access
% is done for each sample in the line. This implies that a large number of samples
% may require quite some time to compute, particularly if operating on a
% higher dimension data set.
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
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kksampline(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kksampline(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'n', 1000;'nc', 0;'o', '__output'};
maxval={0,0,32,0};
minval={0,0,0,0};
istoggle=[0,1,1,0];
was_set=istoggle * 0;
paramtype={'InputFile','Integer','Integer','OutputFile'};
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
[varargout{:}]=callKhoros([w 'ksampline"  '],Inputs,narglist);
