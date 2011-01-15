%kgextents 'Generate Geometry Representing Extents Around Data'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros gextents.pane file
%
% Parameters: 
% InputFile: i 'Input Data Object', required: 'input data object'
% OutputFile: o 'Output Geometry Object', required: 'output geometry object'
% MultiChoice: color 'Colors', default: 2: 'If 1, the lines will be colored white, else they will use the red, green, cyan color scheme described above'
%    Choices are:
% MultiChoice: type 'Box Type', default: 2: 'Select between one of the two box types'
%    Choices are:
% String: name 'Name ', default: 'extents box': 'The name selected here will identify the extents object in the renderer'
%
% Example: o = kgextents(i, {'i','';'o','';'color',2;'type',2;'name','extents box'})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% gextents - Generate Geometry Representing Extents Around Data
%
%  DESCRIPTION
% The gextents module is used to create a geometry object depicting the
% bounds of the space occupied in R3 of the input data.
% 
% If present, the location segment of the input data must be in R3
% (i.e., have X, Y and Z components), while the value portion of the
% input data may be of an arbitrary dimension.  In the instance when
% input data is provided which has no location segment, the coordinates
% used are the indeces into the (w,h,d) portion of the value segment.
% In other words, if the input data set has a value segment of size
% width=32, height=48, depth=24, elements=3, and time=N, and no location
% data is present, the resulting box would have it's two corners
% positioned at (0,0,0) and (31,47,23).
% 
% Two different box types may be selected by the user.  The first type
% always results in a rectangular shaped box, regardless of the location
% data.  This box type is called a "min/max" box.  The maximum extents
% of the location (either from the explicit location data or from the
% scheme outlined above) of the data are computed, and a box is
% constructed with two corners at those locations.  The other box type
% may result in a non-rectangular box, depending upon the behavior of
% the explicit location data.
% 
% The user may elect to have a "colored" box or a white box.  If we
% consider the three dimensions of the data to correspond to the logical
% variables (u,v,w), then the box will be colored so that red lines
% indicate constant (v,w); green lines indicate constant (u,w) and cyan
% lines indicate constant (u,v).
% 
% The user also has the option to show the "sides" of the box as grids,
% by setting one or more of the "axis Min" and "axis Max" toggles to
% True.  For example, setting Vaxis Min to True would display the side
% of the box where v = 0.  While viewing the sides of the box, it may be
% helpful to set the "Show Bounding Box" toggle to False, which will
% remove the overall bounding box and show only the geometry for the
% sides that are currently selected.
% 
% Additionally, the user may provide an explicit name (text string) for
% the resulting geometry object.  This name may be available to assist
% in object identification and manipulation in a downstream renderer,
% depending upon which one is being used.
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
% Copyright (C) 1996,1997 , The Regents of the University of California.  All rights reserved.
% 


function varargout = kgextents(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kgextents(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'o', '__output';'color', 2;'type', 2;'name', 'extents box'};
maxval={0,0,0,0,0};
minval={0,0,0,0,0};
istoggle=[0,0,0,0,1];
was_set=istoggle * 0;
paramtype={'InputFile','OutputFile','MultiChoice','MultiChoice','String'};
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
[varargout{:}]=callKhoros([w 'gextents"  '],Inputs,narglist);
