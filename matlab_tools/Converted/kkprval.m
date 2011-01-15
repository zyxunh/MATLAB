%kkprval 'Print Data Value to Parser and/or Concatenate to File'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros kprval.pane file
%
% Parameters: 
% InputFile: i 'Input ', required: 'Input data object'
% Integer: woff 'Width ', default: 0: 'offset of point along width dimension'
% Integer: hoff 'Height ', default: 0: 'offset of point along height dimension'
% Integer: doff 'Depth ', default: 0: 'offset of point along depth dimension'
% Integer: toff 'Time ', default: 0: 'offset of point along time dimension'
% Integer: eoff 'Elements ', default: 0: 'offset of point along elements dimension'
% String: var 'Variable Name ', default: ' ': 'Name of variable to which output value is assigned'
% OutputFile: o 'Output File', optional: 'Output ASCII in which to append data value'
% Toggle: val 'Value Data', default: 0: 'operate on value data'
% Toggle: map 'Map Data', default: 0: 'operate on map data'
% Toggle: mask 'Mask Data', default: 0: 'operate on mask data'
% Toggle: time 'Time Data', default: 0: 'operate on time data'
% Toggle: loc 'Location Data', default: 0: 'operate on location data'
% Integer: dimoff 'Dimension Offset (Location only)', default: 0: 'offset of point along location dimension'
%
% Example: o = kkprval(i, {'i','';'woff',0;'hoff',0;'doff',0;'toff',0;'eoff',0;'var',' ';'o','';'val',0;'map',0;'mask',0;'time',0;'loc',0;'dimoff',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% kprval - Print Data Value to Parser and/or Concatenate to File
%
%  DESCRIPTION
% The \fBPrint Value" operator (kprval) extracts a single data value 
% from the Input data object (i).   The location of the value is based upon 
% the user indicated position within the specified data segment (Value, Map, 
% Mask, Location, or Time).  The extracted data value can be assigned to a 
% Variable Name (var) via the parser.  This is useful for variable assignment 
% within "cantata", and can be used in any valid expression.
% The extracted value can also be appended to an output file (o), which may 
% be useful for purposes such as tracking data during processing.  If neither 
% the variable name nor the the output file is specified, the value will be 
% printed to standard out (kstdout).
% 
% The user can select which component of the polymorphic data model the
% value will be extracted from.  The components are Value Data (val), Map 
% Data (map), Mask Data (mask), Time Data (time), and Location Data (loc).  
% If Value Data is selected, and a map exists in the data object, the user can
% specify whether the data should be mapped before the value is extracted.
% 
% The position of the data point can be specified by the offset values 
% Width (woff), Height (hoff), Depth (doff), Time (toff), and Elements (eoff).
% If a Time Data point is being extracted, only the Time offset needs to 
% be specified.
% If Location Data is selected, the Width, Height, and Depth offsets 
% can be specified, as well as a Dimension offset (dimoff).
% The default position is the first point in the data set, located at position
% 0.
% 
% If the input object contains complex data, the real component of the
% complex pair is returned.
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


function varargout = kkprval(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kkprval(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'woff', 0;'hoff', 0;'doff', 0;'toff', 0;'eoff', 0;'var', ' ';'o', '__output';'val', 0;'map', 0;'mask', 0;'time', 0;'loc', 0;'dimoff', 0};
maxval={0,1,1,1,1,1,0,1,0,0,0,0,0,1};
minval={0,1,1,1,1,1,0,1,0,0,0,0,0,1};
istoggle=[0,1,1,1,1,1,1,1,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','Integer','Integer','Integer','Integer','Integer','String','OutputFile','Toggle','Toggle','Toggle','Toggle','Toggle','Integer'};
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
[varargout{:}]=callKhoros([w 'kprval"  '],Inputs,narglist);
