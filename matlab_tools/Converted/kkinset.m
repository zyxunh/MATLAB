%kkinset 'Inset Object 2 into Object 1'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros kinset.pane file
%
% Parameters: 
% InputFile: i1 'Input 1', required: 'Base input image'
% InputFile: i2 'Input 2', required: 'Second (inset) input image'
% OutputFile: o 'Output', required: 'Resulting output object'
% Toggle: attr 'Use Input 2 Sub-Object Position (unless overridden below)', default: 0: 'Insert at i2 subobject position (attribute) - w,h,d,t,e will override if specified'
% Integer: woff 'Width Coordinate ', default: 0: 'Insert region beginning at this width coordinate'
% Integer: hoff 'Height Coordinate ', default: 0: 'Insert region beginning at this height coordinate'
% Integer: doff 'Depth Coordinate ', default: 0: 'Insert region beginning at this depth coordinate'
% Integer: toff 'Time Coordinate ', default: 0: 'Insert region beginning at this time coordinate'
% Integer: eoff 'Element Coordinate', default: 0: 'Insert region beginning at this element coordinate'
%
% Example: o = kkinset({i1, i2}, {'i1','';'i2','';'o','';'attr',0;'woff',0;'hoff',0;'doff',0;'toff',0;'eoff',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% kinset - Inset Object 2 into Object 1
%
%  DESCRIPTION
% The Inset operator, kinset, insets data from "Input 2" (i2) into 
% "Input 1" (i1) at the specified position, replacing the data in
% "Input 1".  The resulting \fIOutput\fP object (o) size will be at 
% least the size of Input 1, and may be larger, depending on the specified 
% position values and the size of Input 2.
% 
% If Input 2 has a mask, an "Only Inset VALID Data" (insetvalid) 
% parameter can be set to define whether only data from Input 2 
% that is marked as valid by the validity mask is inset into Input 1.  
% If this parameter is set to FALSE (-insetvalid 0), all value 
% data and the mask from Input 2 are inset into Input 1.  If the 
% parameter is TRUE (-insetvalid 1), for each point in Input 2, 
% the mask is checked, and only valid points are inset into
% Input 1.  In this case, the mask from Input 2 is not propagated 
% to the output.
% 
% The inset operation is based on implicit indexing.  This means
% that if location or time data exist, the inset
% operation is not done in terms an interpretation of
% the location/time data values, but in terms of the
% implicit indexing of these data (which is specified
% by the Width, Height, Depth, Time, Elements indices
% of the polymorphic data model).  
% 
% The position in Input 1 where the origin of Input 2 will be placed
% can be determined from the Sub-Object Position attribute
% that is stored in Input 2, or it can be specified explicitly 
% by providing Width, Height, Depth, Time and Element Coordinates (w,h,d,t,e).  
% The subobject position attribute is automatically set by programs
% such as the Extract operator (kextract).  
% It is legal to specify a subset of coordinates, and let the subobject 
% position attribute define the rest of the coordinates.
% 
% In some instances, padding is necessary to
% maintain the integrity of the polymorphic data model -
% for example when the final size of the Output
% object is larger than that of Input 1.  The Real 
% and Imaginary Pad Values (real, imag) define the values that
% will be used when padding.
% 
% If padding occurs, and the option to "Identify padded data added 
% by this program as Valid" is selected (valid TRUE), all padded data 
% is considered valid and, if either input object contains a validity mask,
% the output object will have a mask, and the mask value for the padded
% data will be 1.  The output object will not contain a mask if 
% neither input object has a mask.  If padded data is to 
% be identified as Invalid (valid FALSE), the padded data will be 
% masked as invalid (0).  In this case, even if neither input object has
% a validity mask, the output object will have one.
% 
%  "Map Data" 5
% When either of the input objects has map data, the treatment of the 
% maps, and how the data is represented in the output object, depends on 
% the mapping option (mapping) specified by the user.  Possible mapping 
% options are:  (0) Map Data Thru Maps and (1) Use First Map Only. If 
% neither input object has a map, the mapping option is ignored.  If 
% there are doubts about which mapping option to use, the safest bet 
% is to map the data thru the maps.
% 	
% 	
%  "Map Data Thru Maps:" 5
% 	All data will be mapped before the data objects are combined.  The 
% 	output object will not have a map.
% 	
%  "Use First Map Only:" 5
% 	In this case, the map data and color attributes of the
% 	first input object that has a map are directly transferred
% 	to the output object.  Note that by selecting this
% 	mapping option, you are assuming that the value segments
% 	of both objects have valid indices into that map.
% 
% 
%  "Data Type" 5
% .cI $DATAMANIP/repos/shared/man/sections/value_type_2input
% 
%  "Location & Time Data" 5
% .cI $DATAMANIP/repos/shared/man/sections/loc_and_time_2input
% 
%  "Failure Modes" 5
% This program will fail if either input object lacks value data.
%
%  
%
%  EXAMPLES
%
%  "SEE ALSO"
% DATAMANIP::kappend
% DATAMANIP::kextract
%
%  RESTRICTIONS 
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kkinset(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kkinset(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i1', '__input';'i2', '__input';'o', '__output';'attr', 0;'woff', 0;'hoff', 0;'doff', 0;'toff', 0;'eoff', 0};
maxval={0,0,0,0,0,0,0,0,0};
minval={0,0,0,0,0,0,0,0,0};
istoggle=[0,0,0,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','InputFile','OutputFile','Toggle','Integer','Integer','Integer','Integer','Integer'};
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
[varargout{:}]=callKhoros([w 'kinset"  '],Inputs,narglist);
