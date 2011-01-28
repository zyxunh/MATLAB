%kknormal 'Normalize Data Regions Using Minimum & Maximum of Each Region'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros knormal.pane file
%
% Parameters: 
% InputFile: i 'Input ', required: 'Input data object'
% OutputFile: o 'Output', required: 'resulting data object'
% Toggle: whole 'Whole Data Set', default: 0: 'normalize whole data set at one time'
% Toggle: w 'Width', default: 0: 'include width in normalization unit'
% Toggle: h 'Height', default: 0: 'include height in normalization unit'
% Toggle: d 'Depth', default: 0: 'include depth in normalization unit'
% Toggle: t 'Time', default: 0: 'include time in normalization unit'
% Toggle: e 'Elements', default: 0: 'include elements in normalization unit'
%
% Example: o = kknormal(i, {'i','';'o','';'whole',0;'w',0;'h',0;'d',0;'t',0;'e',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% knormal - Normalize Data Regions Using Minimum & Maximum of Each Region
%
%  DESCRIPTION
% The "Normalize Data" operator (knormal) normalizes all data within 
% each specified region so that the minimum data value in that region will 
% be equal to the Lower Value (lval) provided by the user, and the maximum 
% data value in the region will be equal to the Upper Value (uval).  If 
% Predetermined Data Minimum (dmin) and Maximum (dmax) values are specified,
% these values will be used instead of scanning the data for minimum and 
% maximum values.   This eliminates an otherwise required pass through the
% data before the normalization operation.
% 
% Regions are defined by the settings of the Processing Unit options, which
% can be either the Whole Data Set (whole), or any combination of Width (w), 
% Height (h), Depth (d), Time (t), and Elements (e).  If none of these flags 
% are supplied, then the default will be the whole data set.
% 
% If the source object contains value data and no map, normalization is 
% performed on the value data.  Likewise, if the source object contains map
% data and no value data, normalization is performed on the map.  If the 
% source object has both map and value data, certain region conditions must 
% be met for the operation to succeed.
% 	
% 	
%  1.
% 	The first condition is that the normalization region must be defined 
% 	by at least width and height.
% 	
%  2. 
% 	If the map depth, time, and elements dimensions are all one, the 
% 	normalization region must be the entire data set.
% 	
%  3.  
% 	If the map depth, time, or elements dimensions are greater than 1, the 
% 	corresponding dimension does not have to be part of the normalization
% 	region.
% 
% 
%  "Output Data Type" 5
% The Output Object Data Type (type) can also be specified.
% If "Propagate Input Type" is selected, the output data type
% will be the same as the input.  If a different data type is 
% selected, data is cast to that type after the transformation is calculated.
% Warning - casting to an unsigned type might result in wrap-around.
% All internal processing is performed in double.
% 
%  "Validity Mask" 5
% Currently, the validity mask is only transferred from the source to 
% the destination object.  The Masked Value Presentation attribute is
% used, so valid values can be substituted for invalid data (to explicitly 
% set this attribute, use the "Set Data Attribute" (ksetdattr) operator
% in the Datamanip toolbox
% As a future enhancement, invalid data will not be figured into the 
% normalization calculations.
% 
%  "Explicit Location and Time Data" 5
% .cI $DATAMANIP/repos/shared/man/sections/loc_and_time_1input
% 
%  "Failure Modes"
% .cI $DATAMANIP/repos/shared/man/sections/fail_1input
%
%  
%
%  EXAMPLES
%
%  "SEE ALSO"
% kconvert
%
%  RESTRICTIONS 
% Does not support complex input data types yet.
% 
% The validity mask is simply transferred from the 
% input object to the output object.  Invalid data will be
% included in the normalization calculations.
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kknormal(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kknormal(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'o', '__output';'whole', 0;'w', 0;'h', 0;'d', 0;'t', 0;'e', 0};
maxval={0,0,0,0,0,0,0,0};
minval={0,0,0,0,0,0,0,0};
istoggle=[0,0,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','OutputFile','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle'};
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
[varargout{:}]=callKhoros([w 'knormal"  '],Inputs,narglist);