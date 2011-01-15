%kghostwriter 'Generates code & doc for all software objects.'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros ghostwriter.pane file
%
% Parameters: 
% String: tb 'Toolbox Name ', default: ' ': 'toolbox name'
% String: oname 'Object Name ', default: ' ': 'object name'
% Toggle: force 'Force Output', default: 0: 'force output?'
% Toggle: debug 'Generate Debug Statements', default: 0: 'generate debug stmts?'
%
% Example: kghostwriter( {'tb',' ';'oname',' ';'force',0;'debug',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% ghostwriter - Generates code & doc for all software objects.
%
%  DESCRIPTION
% 
% Ghostwriter is a code and documentation generation tool which is used to 
% maintain all software objects in the Khoros system.  
% 
% When used with a program object, "ghostwriter" generates the main, the 
% code to obtain command line arguments, the usage routine, and skeleton 
% documentation for the program.  When used with a library object,
% "ghostwriter" generates man pages for each of the public routines in the
% library as well as a man page for the library as a whole.  It also registers
% a program or library as an object within a toolbox, and maintains the database
% files associated with a software object that maintain crucial information such
% as the location of files and values of software object attributes.
% 
% Ghostwriter is executed by "composer" when a software object is created; 
% it is also executed when you click on the "Generate Code" button on 
% "composer"'s main form.  If desired, you may run ghostwriter directory 
% from the command line, either by executing it in the src/ directory of the 
% software object for which you want to generate code and documentation, or by 
% specifying the software object using the [-tb] and [-oname] arguments.
% 
% Issues concerning documentation and code generated by ghostwriter are covered
% in Chapter 6 of the Toolbox Programmer's Manual;  please see this chapter for
% more information.
% 
%  tb: 10
% The [-tb] flag specifies the name of the toolbox in which the software object
% is installed;  "ghostwriter" needs to know which toolbox your software
% object is installed in so that it can find the files associated with the 
% software object.  If "ghostwriter" is run when the local directory is
% in the directory structure of the toolbox in question, the [-tb] option can
% be left off, as the toolbox can be extrapolated from the current directory
% location.
% 
%  oname: 10
% The [-oname] flag specifies the name of the software object on which 
% "ghostwriter" is to be run.  If \fHghostwriter\fP is run when the 
% local directory is the src/ directory of the software object in question, 
% the [-oname] option can be left off, as the software object can be extrapolated 
% from the directory location.
% 
%  force: 10
% Setting this flag to TRUE will force over-write of files;  that is, it will
% suppress prompting before a file is over-written.
% 
%  debug:
% Generally used only by members of the Khoros programming staff, providing
% a value of TRUE (1) for [-debug] will cause "ghostwriter" to put kfprintf()
% statements in the main() of the generated program, so that values provided
% on the user on the command line are printed out.
%
%  
%
%  EXAMPLES
% % ghostwriter -tb datamanip -oname karith1
%
%  "SEE ALSO"
% Craftsman, composer.
%
%  RESTRICTIONS 
% Ghostwriter is restricted to the generation of C code.  Support for other
% programming languages and scripting languages may be added some time in the
% future.  Resultingly, ghostwriter is unable to generate code to implement
% a standardized command line user interface for script objects.
%
%  REFERENCES 
% Chapter 6 of the Khoros Toolbox Programming Manual.
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kghostwriter(varargin)
Inputs={};
if nargin ==0
  arglist={'',''};
elseif nargin ==1
  arglist=varargin{1};
else error('Usage: [out1,..] = kghostwriter(arglist).');
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
callKhoros([w 'ghostwriter"  '],Inputs,narglist);
