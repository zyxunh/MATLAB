%kconductor 'Generates code for the GUI of an xvroutine.'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros conductor.pane file
%
% Parameters: 
% String: tb 'Toolbox Name ', default: ' ': 'toolbox name'
% String: oname 'Program Object Name', default: ' ': 'program object name'
% Toggle: force 'Force Over-Write', default: 0: 'force output?'
% Toggle: debug 'Add Debug Code', default: 0: 'add debug code?'
%
% Example: kconductor( {'tb',' ';'oname',' ';'force',0;'debug',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% conductor - Generates code for the GUI of an xvroutine.
%
%  DESCRIPTION
% 
% "Conductor" is a code-generating tool which is used with xvroutines.  
% The purpose of "conductor" is to generate GUI drivers for xvroutines, 
% plus the code necessary to mediate between the application program and its
% GUI (defined in the *.form file).
% 
% The current values of the selections on the GUI of an xvroutine are stored 
% in the GUI Information structure.  The GUI Information structure is 
% generated by "conductor" in the "form_info.h" file.
% "Conductor" also generates the code to initialize the GUI Information 
% structure in the "form_init.c" file.  The code to extract information from 
% the GUI during runtime is generated by "conductor" in the "form_info.c"
% file.
% 
% Another important function of "conductor" is to generate the GUI drivers
% that will direct the software control flow of your xvroutine as the user
% interacts with its GUI.  As an extension, it also generates the skeletons of
% the functions to which the software control flow will be directed; it is in
% these functions that you add the functionality to your xvroutine.
% 
% The GUI of an xvroutine is hierarchical; it may contain a maximum of three
% levels in its hierarchy, where the highest possible level is a master
% form, the middle level is a subform, and the lowest level is a pane.
% The simplest GUI is a single pane on a single subform; this design can be
% thought of as uni-level.  Subforms with guidepanes offer the user a choice
% of several panes;  these subforms are considered bi-level.  Only GUI's which
% utilize a master form are truly tri-level.  The master form is at the top,
% offering access to mid-level subforms;  the subforms in turn control
% subordinate panes.
% 
% In reflection of the tri-level hierarchy of the Khoros GUI (master form /
% subform / pane), most of the code generated by "conductor" is also
% designed in a three part hierarchy.  The GUI Info structure is a
% tri-level data structure, and three levels of GUI drivers and subdrivers
% will direct the software control flow of your xvroutine.  As mentioned above,
% not all xvroutines use all three levels;  in such cases, portions of the
% GUI Info structure and GUI drivers corresponding to the unused higher
% levels will be minimized, but not eliminated.
% 
% The arguments to "conductor" is as follows:
% 
%  [-tb {toolbox name}]:
% The [-tb] flag specifies the name of the toolbox in which the xvroutine
% is installed;  "conductor" needs to know which toolbox your xvroutine
% is installed in so that it can find the files associated with the xvroutine.
% If "conductor" is run when the local directory is in the directory 
% structure of the toolbox in question, the [-tb] option can be left off, as 
% the toolbox can be extrapolated from the current directory location.
% 
%  [-oname {object name}]:
% The [-oname] flag specifies the name of the xvroutine on which
% "conductor" is to be run.  If \fHconductor\fP is run when the
% local directory is the src/ directory of the xvroutine in question,
% the [-oname] option can be left off, as the program object name can be 
% extrapolated from the directory location.
% 
%  [-force]:
% Setting this flag to TRUE will force over-write of files;  that is, it will
% suppress prompting before a file is over-written.
% 
%  [-debug]:
% Generally used only by members of the Khoros programming staff, providing
% a value of TRUE (1) for [-debug] will cause "conductor" to put kfprintf()
% statements in the GUI drivers of the xvroutine, so that values set by the
% user on the GUI are printed out when control flow is returned to the xvroutine.
%
%  
%
%  EXAMPLES
% % conductor -tb envision -oname xprism -force
%
%  "SEE ALSO"
% ghostwriter(1)
%
%  RESTRICTIONS 
%
%  REFERENCES 
% Chapter 6 of the Toolbox Programming Manual.
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kconductor(varargin)
Inputs={};
if nargin ==0
  arglist={'',''};
elseif nargin ==1
  arglist=varargin{1};
else error('Usage: [out1,..] = kconductor(arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'tb', ' ';'oname', ' ';'force', 0;'debug', 0};
maxval={0,0,0,0};
minval={0,0,0,0};
istoggle=[1,1,1,1];
was_set=istoggle * 0;
paramtype={'String','String','Toggle','Toggle'};
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
callKhoros([w 'conductor"  '],Inputs,narglist);
