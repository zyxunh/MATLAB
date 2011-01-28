%kdbcnvrt 'Convert from a pre-Khoros 2.0 kdbm file to a 2.0 kdbm file'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros dbcnvrt.pane file
%
% Parameters: 
% Toggle: rm 'Remove Old DB files', default: 0: 'Remove the original unconverted DB files'
% InputFile: i 'Input ', optional: 'Input database file'
% OutputFile: o 'Output', optional: 'Output Database Filename'
% String: tb 'Toolbox ', default: ' ': 'Change the cms databases for a whole toolbox'
%
% Example: o = kdbcnvrt(i, {'rm',0;'i','';'o','';'tb',' '})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% dbcnvrt - Convert from a pre-Khoros 2.0 kdbm file to a 2.0 kdbm file
%
%  DESCRIPTION
% This program is used to update kdbm files that were created before the
% public release of Khoros 2.0.
% .I dbcnvrt
% has two modes of operation.
% 
% In the first mode, it takes an input and output filename and does a
% direct conversion of a kdbm file.  This mode of operation is used
% to convert kdbm files one at a time, and is the only way to convert
% the Khoros 2.0 pre-release VIFF data files.
% 
% In the second mode, it takes a toolbox name as an argument.  With this
% toolbox argument, it searches all the files in the toolbox for kcms
% database files.  This search includes the "cantata" object cache, the
% manpage database file, the library function database files and all the
% cms functions.  It doesn't search for VIFF files, because these are not
% located in standard places.
%
%  
%
%  EXAMPLES
% \s-1
% \f(CW
% 
% % kdbmcat -dbm old.dbm
% 
% Toolbox: SUPPORT
% Program: kdbmcat
% Library: kutils
% Routine: read_header
% This dbm file \'old.dbm\' is in a pre-Khoros 2.0 form, please run
% the \'dbcnvrt\' program on it.
% 
% kdbmcat:  Failed to open database
% \'old.dbm\'
% 
% % dbcnvrt -i old.dbm -o new.dbm
% 
% % kdbmcat -dbm new.dbm
% \'MY_KEY1\': My data 1
% 
% \'MY_KEY2\': My data 2
% 
% %
% 
% "
% \s+1
%
%  "SEE ALSO"
% kdbmcat(1), kcms(3), klibdb(3)
%
%  RESTRICTIONS 
% The kdbm code was updated to fix bugs on the CRAY Architecture, hence
% this program cannot update old kdbm files on a CRAY.
%
%  REFERENCES 
% Migration Toolbox Manual
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kdbcnvrt(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kdbcnvrt(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'rm', 0;'i', '__input';'o', '__output';'tb', ' '};
maxval={0,1,1,0};
minval={0,1,1,0};
istoggle=[1,1,1,1];
was_set=istoggle * 0;
paramtype={'Toggle','InputFile','OutputFile','String'};
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
[varargout{:}]=callKhoros([w 'dbcnvrt"  '],Inputs,narglist);