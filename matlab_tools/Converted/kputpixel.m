%kputpixel 'Display Pixel Values Associated with Region of Image'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros putpixel.pane file
%
% Parameters: 
% InputFile: i 'Input File', required: 'File containing pixels to display'
% Integer: valuewidth 'Width of Pixel Value Display ', default: 7: 'Specifies the number of pixel values along width'
% Integer: valueheight 'Height of Pixel Value Display', default: 7: 'Specifies the number of pixel values along height'
% Integer: x 'X Placement', default: -1: 'X location for GUI autoplacement'
% Integer: width 'Window Width ', default: 256: 'Window width'
% Integer: y 'Y Placement', default: -1: 'Y location for GUI autoplacement'
% Integer: height 'Window Height', default: 256: 'Window height'
% Double: update 'Update time', default: 2: 'How often to check input file for modification'
%
% Example: kputpixel(i, {'i','';'valuewidth',7;'valueheight',7;'x',-1;'width',256;'y',-1;'height',256;'update',2})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% putpixel - Display Pixel Values Associated with Region of Image
%
%  DESCRIPTION
% Putpixel is a visualization program that displays value data as
% a grid of values.  These value data points may be pixels in an image.
% 
% The number of map pixel values that are displayed along width and height
% can be specified using the [-valuewidth] and [-valueheight] arguments.  These
% options control the number of pixel values that are displayed in
% the horizontal and vertical directions of the display.
% 
% It is possible to specify the map pixel background color using the
% [-showcolormap] argument.  When set to "TRUE", the pixel under the
% pointer will be displayed as the background color for the label object in
% which the map values are displayed.  When set to "FALSE", the background
% color is displayed as black.
% 
% By default, the visualization display will share its colormap will all
% other applications running at the same time; that is, it does not not use a
% .I "private colormap",
% but rather makes use of the
% .I "default colormap".
% It is possible to specify that the visualization display allocate its
% own private colormap or "grab" all available colors for its own use.
% This is done using the [-priv] argument.  When [-priv] is specified,
% moving the mouse pointer into the display window will cause the display
% to have its private colormap installed; moving the pointer out of the
% display window will cause the private colormap to be de-installed.  This
% results in the "technoflashing" phenomenon characteristic of private
% colormap installation.
% 
% Color allocation can also be controlled and set to either
% .I "read-only"
% or
% .I "read/write"
% using the [-alloc] argument.  When set to
% .I "read-only",
% once a color cell has been allocated, it can have its color set only once;
% from then on, the color cell can be shared by multiple applications, but
% not changed.  If the visualization display requires the color displayed
% to change, it must re-allocate the color cell, forcing a re-display of
% data.  This can be an expensive procedure.  In contrast, after a
% .I "read/write"
% color cell is allocated, it can have its color changed at any time
% without re-allocation; the data being displayed does not need to be
% redisplayed, and the color update process is much more efficient.
% However, the colors used in the visualization display cannot be shared by
% other applications.
% 
% The input file containing the data values to be displayed is monitored
% by default; the file is checked every 2 seconds for change, and if it
% has been modified, the displayed values are updated accordingly.  The 
% interval at which the input file is checked for modification may be
% specified using the [-update] argument.
% 
% On creation, the window which displays the value data may be placed
% manually (the default method), or placed automatically.  For automatic
% placement of the window which displays the value data, specify the 
% desired location in device (screen) coordinates using the [-x] and
% [-y] arguments.
% 
% While the display window should be created with a default size that is
% appropriate to display the data, a width and height for the window can
% be specified explicitly using the [-width] and [-height] arguments.  
% Alternatively, you may allow the display window to size itself initially,
% and then use the window manager to interactively modify its size as desired.
%
%  
%
%  EXAMPLES
% % putpixel -i image:mandril
% % putpixel -i image:ball
%
%  "SEE ALSO"
% putdata(1)
%
%  RESTRICTIONS 
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kputpixel(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kputpixel(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'valuewidth', 7;'valueheight', 7;'x', -1;'width', 256;'y', -1;'height', 256;'update', 2};
maxval={0,1,1,1000,1000,1000,1000,1};
minval={0,1,1,-1,-1,-1,-1,1};
istoggle=[0,1,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','Integer','Integer','Integer','Integer','Integer','Integer','Double'};
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
  varargout = cell(0);
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
callKhoros([w 'putdata"  -pixel'],Inputs,narglist);
