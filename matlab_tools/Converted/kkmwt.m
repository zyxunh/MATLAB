%kkmwt '5D multlevel wavelet transform'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros kmwt.pane file
%
% Parameters: 
% InputFile: i 'Input Object ', required: 'Input object filename '
% InputFile: fh 'Highpass', required: 'Input highpass filter coefficients'
% InputFile: fl 'Lowpass ', required: 'Input lowpass filter coefficients'
% OutputFile: o 'Output Object ', required: 'Output object filename'
% Toggle: w 'Width', default: 0: 'filter in the WIDTH direction'
% Toggle: h 'Height', default: 0: 'filter in the HEIGHT direction'
% Toggle: d 'Depth', default: 0: 'filter in the DEPTH direction'
% Toggle: t 'Time', default: 0: 'filter in the TIME direction'
% Toggle: e 'Elements', default: 0: 'filter in the ELEMENTS direction'
% MultiChoice: dir 'Transform Selection', default: 1: 'Transform direction selection'
%    Choices are:
%   1: 'Direct'
%   2: 'Inverse'
% Integer: l 'Levels ', default: 1: 'Number of levels for decomposition'
% Toggle: tinv 'Total Inverse (for wavelet objects only)', default: 1: 'Select transform direction to total'
%
% Example: o = kkmwt({i, fh, fl}, {'i','';'fh','';'fl','';'o','';'w',0;'h',0;'d',0;'t',0;'e',0;'dir',1;'l',1;'tinv',1})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% kmwt - Performs multlevel wavelet transforms
%
%  DESCRIPTION
% \flkmwt" performs wavelet decomposition of the input object defined
% by \fBInput" in any dimension or combination of the 5 dimensions, and
% with a number of layers defined by the user.  The filters for both
% transform directions (forward and inverse) are defined by
% \fBHighpass" for the highpass filter and \fBLowpass\fP for the
% lowpass filter.  These filter must be defined acordlingly to the
% transform direction.  The output object of "kmwt" corresponds to
% the coefficients of the wavelet expansion.  Default values are: width
% and height dimensions, transform direction forward and number of layers
% equal to one.  If the direct transform is carried out by "kmwt" the
% inverse transform can be performed by using the flag Total Inverse.  In
% this case the user do not need to define the number of layers. 
% 
% The "kmwt" routine uses tensorial product to perform the multidimensional
% wavelet transform in each level.  That is, this wavelet
% transform routine assumes separability (decoupling) in the multidimensional 
% case.
% 
%  "Data Type" 5
% The "kmwt" routine accepts any kind of data type for the input
% object, except complex.  Internally "kmwt" casts the data of
% input object to double before processing and changes the
% destination object data type (output) accordingly.  The data is
% processed using double data type despite the data type of any source 
% object.  Note that data is not casted to a lower type for processing.
% 
%  "Map Data" 5
% If any source object contains map data as well as value data, then
% "kmwt" removes the map.  The destination object is always unmapped.
% 
%  "Mask, Time and Location Segments" 5
% If any source object contains a mask, time or location segment, then an
% error message is printed out.  Mask, time and location segments have to
% be removed before processing.
%
%  
%
%  EXAMPLES
% 2D forward wavelet transform of a 2D object using daub_2_f_h (highpass
% Daubechies filter, order 2, forward direction) as a highpass filter and
% daub_2_f_l (lowpass Daubechies filter, order 2, forward direction) as a
% lowpass filter and number of levels equal to 3.
% kmwt -i image_input -w -h -fh daub_2_f_h -fl daub_2_f_l -dir 1 -o image_output -l 3
% 2D inverse wavelet transform of a 2D object using daub_2_i_h (highpass
% Daubechies filter, order 2, inverse direction) as a highpass filter and
% daub_2_i_l (lowpass Daubechies filter, order 2, inverse direction) as a
% lowpass filter and number of levels equal to 3.
% kmwt -i image_input -w -h -fh daub_2_i_h -fl daub_2_i_l -dir 2 -o image_output -l 3
%
%  "SEE ALSO"
% kwt
%
%  RESTRICTIONS 
% Dimension of data record must be a power of 2.
%
%  REFERENCES 
% 1) WAVELETS ANALYSIS AND ITS APPLICATIONS, Vol. I, II and III, edited by
% Charles K. Chui, Academis Press, 1992.
% 
% 2) ADAPTED WAVELET ANALYSIS FROM THEORY TO SOFTWARE,
% Mladen Victor Wickerhauser, A K Peters, 1994.
% 
% 3) TEN LECTURES ON WAVELETS, I. Daubechies, Siam, 1992.
% 
% 4) DIFFERENT PERSPECTIVAS ON WAVELETS, Proceedings of Symposia in
% Applied Mathematics, 1993.
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc.  All rights reserved.
% 


function varargout = kkmwt(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kkmwt(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'fh', '__input';'fl', '__input';'o', '__output';'w', 0;'h', 0;'d', 0;'t', 0;'e', 0;'dir', 1;'l', 1;'tinv', 1};
maxval={0,0,0,0,0,0,0,0,0,0,2,0};
minval={0,0,0,0,0,0,0,0,0,0,2,0};
istoggle=[0,0,0,0,1,1,1,1,1,0,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','InputFile','InputFile','OutputFile','Toggle','Toggle','Toggle','Toggle','Toggle','MultiChoice','Integer','Toggle'};
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
[varargout{:}]=callKhoros([w 'kmwt"  '],Inputs,narglist);
