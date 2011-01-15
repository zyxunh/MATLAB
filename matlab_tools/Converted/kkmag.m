%kkmag 'Output is a Function of the Magnitude of the Input'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros kmag.pane file
%
% Parameters: 
% InputFile: i 'Input ', required: 'Input data object'
% OutputFile: om 'Output', optional: 'Output data object containing magnitude of input'
% Toggle: mag 'Magnitude', default: 0: 'Magnitude = sqrt(real*real + imag*imag)'
% Toggle: magsq 'Magnitude Squared', default: 0: 'Magnitude Squared = real*real + imag*imag'
% Toggle: logmag1 'Log (Magnitude + 1)', default: 0: 'Log (Magnitude + 1) = log(sqrt(real*real + imag*imag)+1)'
% Toggle: logmagsq1 'Log (Magnitude Squared + 1)', default: 0: 'Log (Magnitude Squared + 1) = log(real*real+imag*imag+1)'
% Toggle: logmag 'Log (Magnitude)', default: 0: 'Log (Magnitude) = log(sqrt(real*real + imag*imag))'
% Toggle: logmagsq 'Log (Magnitude Squared)', default: 0: 'Log (Magnitude): log(real*real + imag*imag)'
%
% Example: om = kkmag(i, {'i','';'om','';'mag',0;'magsq',0;'logmag1',0;'logmagsq1',0;'logmag',0;'logmagsq',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% kmag - Output is a Function of the Magnitude of the Input
%
%  DESCRIPTION
% The "Magnitudes" operator returns the selected calculation of 
% the magnitude of each data point in the input data object, \fBInput".  
% The user can specify one of six methods for calculating the magnitude output,
% where "Log" is the logarithm, base 10.  (If the input data is not
% complex, the imaginary component is assumed to be zero.)
% 	
% 	(mag)
% 	Magnitude = sqrt(real * real + imaginary * imaginary)
% 	(logmag1)
% 	Log (Magnitude + 1)
% 	(logmag)
% 	Log (Magnitude)
% 	(magsq)
% 	Magnitude Squared
% 	(logmagsq1)
% 	Log (Magnitude Squared + 1)
% 	(logmagsq)
% 	Log (Magnitude Squared)
% 
% 
% The output object data type will be the same as the
% input (regarding single or double floats).
% 
%  "Map Data" 5
% .cI $DATAMANIP/repos/shared/man/sections/map_1input
% 
%  "Validity Mask" 5
% .cI $DATAMANIP/repos/shared/man/sections/mask_1input
% 
%  "Explicit Location and Time Data" 5
% .cI $DATAMANIP/repos/shared/man/sections/loc_and_time_1input
% 
%  "Failure Modes"
% .cI $DATAMANIP/repos/shared/man/sections/fail_1input
% 
% Executing "Magnitudes" runs the program \fIkcmplx2real\fP with the -om
% output option.
%
%  
%
%  EXAMPLES
%
%  "SEE ALSO"
% DATAMANIP::kcmplx2real, DATAMANIP::kcmplx, DATAMANIP::kreal2cmplx
%
%  RESTRICTIONS 
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kkmag(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kkmag(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'om', '__output';'mag', 0;'magsq', 0;'logmag1', 0;'logmagsq1', 0;'logmag', 0;'logmagsq', 0};
maxval={0,1,0,0,0,0,0,0};
minval={0,1,0,0,0,0,0,0};
istoggle=[0,1,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','OutputFile','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle'};
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
[varargout{:}]=callKhoros([w 'kcmplx2real"  '],Inputs,narglist);
