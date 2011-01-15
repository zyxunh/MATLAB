%kguise 'Direct manipulation GUI design tool'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros guise.pane file
%
% Parameters: 
% Toggle: force 'Force Over-Write?', default: 0: 'force output'
% OutputFile: o 'Output UIS File', optional: 'output UIS file'
% InputFile: i 'Initial UIS File', optional: 'initial UIS file'
% String: tb 'Toolbox', default: ' ': 'toolbox'
% String: oname 'Object Name', default: ' ': 'object name'
% String: uis 'UIS file', default: ' ': 'UIS file to edit (do not include path)'
%
% Example: o = kguise(i, {'force',0;'o','';'i','';'tb',' ';'oname',' ';'uis',' '})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% guise - Direct manipulation GUI design tool
%
%  DESCRIPTION
% "Guise" is explained in detail in Chapter 4 of the Khoros Toolbox
% Programmer's Manual; the information given there will not be repeated here,
% so you are referred to that document.  For reference purposes, a detailed
% explanation of each argument to "guise" is as follows:
% 
%  "[-i {UIS file}] OR [-tb], [-oname] and [-uis]"
% When started without the [-i] and without the [-tb], [-oname] and [-uis]
% arguments, "guise" begins by creating an empty pane.  When started with
% the [-i] option specifying an input UIS file, guise displays the GUI defined
% by that UIS file, and allows you to modify it;  the output filename is taken
% from the input file unless otherwise specified.   When started with the [-tb],
% [-oname], and [-uis] arguments, guise will open the specified program object
% in the specified toolbox, and will look for the *.pane, *.form, or *.cmd file
% as implied by the [-uis] option.  Assuming the implied UIS file is found,
% guise displays the GUI defined by that UIS file, and allows you to modify it;
% the output filename is taken from the input file unless otherwise specified.
% The only difference between using the [-i] argument and the [-tb], [-oname],
% and [-uis] arguments is that in the former case you must know the path to the
% desired UIS file, while in the latter case, you must know the toolbox and
% program with which the UIS file is associated.
% 
%  "[-o {UIS file}]"
% The [-o] argument specifies the name of the output UIS file. When the [-i] or
% [-tb], [-oname], and [-uis] options are used to specify an input UIS file, the
% output filename is taken to be the same as the input unless otherwise specified.
% Therefore, either the [-o] argument should be used or care should be taken to
% change the output filename if the input file is not to be affected by changes
% made using guise.
% 
%  "[-force]"
% The [-force] option may be used to suppress prompting before the output file
% is clobbered.  Alternatively, the "Force Over-Write?" logical selection on the
% master form of guise may be used for the same reason.
%
%  
%
%  EXAMPLES
% % guise -i spectrum.form
% OR
% % guise -i tb envision -oname spectrum -uis form
%
%  "SEE ALSO"
% preview(1)
%
%  RESTRICTIONS 
%
%  REFERENCES 
% Guise is covered in Chapter 4 of the Khoros Toolbox Programmer's Manual.
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kguise(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kguise(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'force', 0;'o', '__output';'i', '__input';'tb', ' ';'oname', ' ';'uis', ' '};
maxval={0,1,1,0,0,0};
minval={0,1,1,0,0,0};
istoggle=[1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'Toggle','OutputFile','InputFile','String','String','String'};
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
[varargout{:}]=callKhoros([w 'guise"  '],Inputs,narglist);
