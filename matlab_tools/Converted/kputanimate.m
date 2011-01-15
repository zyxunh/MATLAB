%kputanimate 'Non-Interactive Animation of Image Sequence'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros putanimate.pane file
%
% Parameters: 
% InputFile: i 'Input File', required: 'File containing image sequence'
% InputFile: cmap 'Input Colormap ', optional: 'File containing alternate colormap filename'
% InputFile: clip 'Input Clip Gate', optional: 'File containing clip mask'
% Integer: x 'X Placement', default: -1: 'X location for GUI autoplacement'
% Integer: width 'Window Width ', default: 256: 'Window width'
% Integer: y 'Y Placement', default: -1: 'Y location for GUI autoplacement'
% Integer: height 'Window Height', default: 256: 'Window height'
% Double: update 'Update time', default: 2: 'How often to check input file for modification'
%
% Example: kputanimate({i, cmap, clip}, {'i','';'cmap','';'clip','';'x',-1;'width',256;'y',-1;'height',256;'update',2})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% putanimate - Non-Interactive Animation of Image Sequence
%
%  DESCRIPTION
% Putanimate is a visualization program that displays animated
% sequences of data.  It is expected that the input data has multiple
% frames organized in the Khoros Polymorphic Data Model along either
% depth, time, or elements.
% 
% The input file containing the data to be animated is monitored by 
% default; the file is checked every 2 seconds for change, and if it has 
% been modified, the visualization display is updated accordingly.  The
% interval at which the input file is checked for modification may be 
% specified using the [-update] argument.
% 
% A clip mask may be used to dictate the portion of the data that is
% displayed in the animation using the [-clip] argument.
% 
% An alternate input color map may be used to change the current color map
% using the [-cmap] argument.
% 
% An animate direction value may be provided which specifies the direction
% in which images are sequenced using the [-dir] argument.  There are five 
% different direction values which are as follows:
% 
%  "" 5
% 1  -  "<<" Causes the animation to sequence in a backward direction.
% 2  -  "<"  Advances a single frame in a backwards direction (frame N to N-1).
% 3  -  "Stop"  Causes the animation to stop.
% 4  -  ">"  Advances a single frame in a forward direction (frame N to N+1)
% 5  -  ">>"  Causes the animation to sequence in a forward direction.
% 
% An animate control value may be provided which controls how animation
% sequencing is performed when the animation is in motion using the [-control]
% argument.  Animation is considered "in motion" when the animation direction is 
% sequencing forward or backward.  The animation may be performed once 
% completely, repeated indefinitely, or performed in one direction then reversed 
% and repeated in the other direction.  There are three different control values 
% which are as follows:
% 
%  "" 5
% 1  -  "Single" Does a single complete sequence of the animation in the
% current direction, and then stops.
% 2  -  "Loop"  Does a full sequence through the animation in the current
% animation direction.  As soon as the sequence is finished, it is started
% again, so that the animation is put into a loop.  This procedure will 
% repeat until the animation is stopped.
% 3  -  "Autoreverse"  Does a single complete sequence of the animation, in the 
% current animation direction, then reverses the direction and sequences back.
% This procedure will repeat until the animation is stopped.
% 
% An animation speed value may be provided which controls how fast the frames
% in the image are to be sequenced using the [-speed] argument.  The speed is a  
% value in seconds ranging between 0 and 5, where 0.0 is the fastest possible 
% on a given machine, and 5.0 is very slow.  Note that 1/60 sec (0.016 sec) 
% corresponds to the normal frame rate for television.  It is "NOT" 
% recommended that the frame speed be set to 0.0 for most situations since this 
% is an intensive operation that may make it difficult to re-gain control of 
% the graphical user interface.
% 
% By default, the visualization display will share its colormap will all
% other applications running at the same time; that is, it does not not use a
% .I private colormap,
% but rather makes use of the
% .I default colormap.
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
% .I  Read Only
% or
% .I Read Write
% using the [-alloc] argument.  When set to
% .I read only,
% once a color cell has been allocated, it can have its color set only once;
% from then on, the color cell can be shared by multiple applications, but
% not changed.  If the visualization display requires the color displayed
% to change, it must re-allocate the color cell, forcing a re-display of
% data.  This can be an expensive procedure.  In contrast, after a
% .I read/write
% color cell is allocated, it can have its color changed at any time
% without re-allocation; the data being displayed does not need to be
% redisplayed, and the color update process is much more efficient.
% However, the colors used in the visualization display cannot be shared by
% other applications.
% 
% On creation, the animation display window may be placed manually (the
% default method), or placed automatically.  For automatic placement of the 
% animation display window, specify the desired location in device (screen)
% coordinates, using the [-x] and [-y] arguments.
% 
% While the animation display window should be created with a default size 
% that is appropriate to display the data, a width and height for the window
% can be specified explicitly using the [-width] and [-height] arguments.
% Note that interactive resizing of the animate window using the window manager
% is currently NOT supported.
%
%  
%
%  EXAMPLES
% % putanimate -i sequence:baby
% % putanimate -i sequence:bushes
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


function varargout = kputanimate(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kputanimate(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'cmap', '__input';'clip', '__input';'x', -1;'width', 256;'y', -1;'height', 256;'update', 2};
maxval={0,1,1,1000,1000,1000,1000,1};
minval={0,1,1,-1,-1,-1,-1,1};
istoggle=[0,1,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','InputFile','InputFile','Integer','Integer','Integer','Integer','Double'};
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
callKhoros([w 'putdata"  -animate'],Inputs,narglist);
