%kkreal2cmplx 'Output = Input 1 + j(Input 2)'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros kreal2cmplx.pane file
%
% Parameters: 
% OutputFile: o 'Output', required: 'Resulting output data object'
% InputFile: i1 'Real Input ', optional: 'Input to be used as real component'
% InputFile: i2 'Imaginary Input', optional: 'Input to be used as imaginary component'
%
% Example: o = kkreal2cmplx({i1, i2}, {'o','';'i1','';'i2',''})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% kreal2cmplx - Output = Input 1 + j(Input 2)
%
%  DESCRIPTION
% The "Real to Complex" operator (kreal2cmplx) generates a complex 
% Output object (o) containing complex data compiled from the supplied
% source object(s), Real Input (i1) and Imaginary Input (i2). The data 
% type of the output, which will be complex or double complex, is 
% determined from the highest of the source data types.  
% Only one source object must be specified.
% 
%  "Single Source Object:" 
% If only one source object is specified, the other component
% of the complex pair will be the Real Constant (real) or Imaginary 
% Constant (imag).  If the source object has map data, the
% operation will be performed on the map only.  For the single source 
% case, location, time, and mask data are not needed or modified.
% 
%  "Two Source Objects"
% If both real and imaginary source objects are specified, and both contain 
% map data and no value data the operation is performed directly on the map,
% and the output object will contain a map.  For this case of two sources
% that have no value data, location, time, and mask data are not modified, 
% but are transferred to the output.
% If either source object contains both map and value data, then both objects 
% must have value data, and the data will be mapped before processing.  The 
% output object will have value data and no map data.
% If the source objects are the same size, then location and time data 
% can be ignored.
% If the source objects are different sizes, then location and time data 
% are checked, and if they exist, the real to complex conversion will only 
% continue if the grid type is uniform.  The destination size will be the 
% maximum of both source sizes.  If padding is required by the Real Input 
% object, it will be padded with the Real Constant.  If padding is required
% by the Imaginary Input, it will be padded with the Imaginary Constant.
% 
%  "Validity Mask"
% If either source object has a validity mask, the destination object will 
% get a mask.  If both source objects have masks, the masks will be 
% combined (logical AND) after processing.  
% 
%  "Failure Modes"
% Real to complex conversion will fail if neither source object is
% supplied; if the source objects do not contain at least value
% or map data; or if either source object is already complex.
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


function varargout = kkreal2cmplx(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kkreal2cmplx(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'o', '__output';'i1', '__input';'i2', '__input'};
maxval={0,1,1};
minval={0,1,1};
istoggle=[0,1,1];
was_set=istoggle * 0;
paramtype={'OutputFile','InputFile','InputFile'};
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
[varargout{:}]=callKhoros([w 'kreal2cmplx"  '],Inputs,narglist);
