%kkgsin 'Generate Object Containing Sinusoidal Value Data'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros kgsin.pane file
%
% Parameters: 
% Integer: wsize 'Width ', default: 512: 'Width size of sinusoidal value data'
% Integer: hsize 'Height ', default: 512: 'Height size of sinusoidal value data'
% Integer: dsize 'Depth ', default: 1: 'Depth size of sinusoidal value data'
% Integer: tsize 'Time ', default: 1: 'Time size of sinusoidal value data'
% Integer: esize 'Elements ', default: 1: 'Elements dimension size of sinusoidal value data'
% OutputFile: o 'Output', required: 'Output file containing sinusoidal value data'
% Toggle: sin1 'sin(w+h+d+t+e)', default: 0: 'Apply sine function to the sum of coordinates at a point'
% Toggle: sin5 'sin(w)+sin(h)+sin(d)+sin(t)+sin(e)', default: 0: 'Apply sine to each coordinate and sum up the result'
%
% Example: o = kkgsin( {'wsize',512;'hsize',512;'dsize',1;'tsize',1;'esize',1;'o','';'sin1',0;'sin5',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% kgsin - Generate Object Containing Sinusoidal Value Data
%
%  DESCRIPTION
% .I kgsin
% creates a data object with sinusoidal values of dimension
% Width * Height * Depth * Time * Elements.
% The data type of the value segment can be
% \fBbit, byte, unsigned byte, short, unsigned short, integer, unsigned integer,
% long, unsigned long, float, double, complex" and \fBdouble complex\fP. When 
% the desired data type is complex, the generated function is cos(w+h+d..) + j*sin(angle).
% 
% The sine wave generated can be either a sum of sine functions along all 
% five dimensions(-sin5) or the sine of the sum of the coordinates at a point
% (-sin1). When the sum of sine functions is specified the output is generated 
% using the expression:
% 
% sin(w) + sin(h) + sin(d) + sin(t) + sin(e)
% 
% For the sine of sum option the function used for generating the output looks 
% like:
% 
% sin(w + h + d + t +e)
% 
% The number of sine waves and phase offset for each of the five dimensions can 
% be specified.  The number of cycles along each dimension represents the number 
% of sine waves that will appear along each dimension. The phase offset
% is specified in degrees. wnum sine cycles and a phase offset of wp
% changes the argument to the sine generating function as follows:
% 
% sin(2*PI*wnum*w/width + wp) where width denotes the size of the width dimension.
% 
% The amplitude of the sinusoidal function can also be specified. It represents 
% the maximum value that each sine wave can take. In the case when a sum of sine
% waves is being generated the amplitude along each dimension has to be specified.
% The generated expression looks like:
% 
% ampl*sin(angle) or wampl*sin(wnum*w/width+ wp) + hampl*sin(angle) + ...
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


function varargout = kkgsin(varargin)
Inputs={};
if nargin ==0
  arglist={'',''};
elseif nargin ==1
  arglist=varargin{1};
else error('Usage: [out1,..] = kkgsin(arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'wsize', 512;'hsize', 512;'dsize', 1;'tsize', 1;'esize', 1;'o', '__output';'sin1', 0;'sin5', 0};
maxval={2,2,2,2,2,0,0,0};
minval={2,2,2,2,2,0,0,0};
istoggle=[1,1,1,1,1,0,1,1];
was_set=istoggle * 0;
paramtype={'Integer','Integer','Integer','Integer','Integer','OutputFile','Toggle','Toggle'};
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
[varargout{:}]=callKhoros([w 'kgsin"  '],Inputs,narglist);
