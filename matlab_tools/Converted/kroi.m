%kroi 'Extract ROI'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros roi.pane file
%
% Parameters: 
% OutputFile: o 'Output Displayed ROI', required: 'extract ROI file'
% MultiChoice: shape 'ROI Shape:', default: 1: 'specifies desired shape for ROI'
%    Choices are:
%   1: 'Rectangle'
%   2: 'Polyline'
%   3: 'Circle'
%   4: 'Ellipse'
%   5: 'Line'
%   6: 'Freehand'
% MultiChoice: mode 'Extraction Mode:', default: 1: 'How to extract'
%    Choices are:
% Integer: line_x1 'Begin X ', default: 0: ' '
% Integer: circle_x 'Center X ', default: 0: ' '
% Integer: ellipse_x 'Center X ', default: 0: ' '
% Integer: rect_x 'Upper Left X ', default: 0: ' '
% Integer: line_x2 'End X', default: 0: ' '
% Integer: circle_radius 'Radius ', default: 0: ' '
% Integer: ellipse_a 'A', default: 0: ' '
% Integer: rect_width 'Width ', default: 0: ' '
% Integer: line_y1 'Begin Y ', default: 0: ' '
% Integer: circle_y 'Center Y ', default: 0: ' '
% Integer: ellipse_y 'Center Y ', default: 0: ' '
% Integer: rect_y 'Upper Left Y ', default: 0: ' '
% Integer: line_y2 'End Y', default: 0: ' '
% Integer: ellipse_b 'B', default: 0: ' '
% Integer: rect_height 'Height ', default: 0: ' '
%
% Example: o = kroi( {'o','';'shape',1;'mode',1;'line_x1',0;'circle_x',0;'ellipse_x',0;'rect_x',0;'line_x2',0;'circle_radius',0;'ellipse_a',0;'rect_width',0;'line_y1',0;'circle_y',0;'ellipse_y',0;'rect_y',0;'line_y2',0;'ellipse_b',0;'rect_height',0})
%
% Khoros helpfile follows below:


function varargout = kroi(varargin)
Inputs={};
if nargin ==0
  arglist={'',''};
elseif nargin ==1
  arglist=varargin{1};
else error('Usage: [out1,..] = kroi(arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'o', '__output';'shape', 1;'mode', 1;'line_x1', 0;'circle_x', 0;'ellipse_x', 0;'rect_x', 0;'line_x2', 0;'circle_radius', 0;'ellipse_a', 0;'rect_width', 0;'line_y1', 0;'circle_y', 0;'ellipse_y', 0;'rect_y', 0;'line_y2', 0;'ellipse_b', 0;'rect_height', 0};
maxval={0,0,0,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999};
minval={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
istoggle=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
was_set=istoggle * 0;
paramtype={'OutputFile','MultiChoice','MultiChoice','Integer','Integer','Integer','Integer','Integer','Integer','Integer','Integer','Integer','Integer','Integer','Integer','Integer','Integer','Integer'};
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
[varargout{:}]=callKhoros([w 'roi" '],Inputs,narglist);
