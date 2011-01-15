%kktextu 'Compute "texture" extracted from the surface surroundings '
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros ktextu.pane file
%
% Parameters: 
% InputFile: i1 '3D Data', required: 'Input scene (gray or binary scene)'
% InputFile: i2 'Coordinates', required: 'Coordinates at z-buffer distance (surface)'
% OutputFile: o '"Texture"', required: '"Texture" information which can be incorporated on shading'
% Double: step 'increment step', default: 1: 'Increment step during "texture" computation'
% Toggle: ave_type 'average value', default: 0: 'Meaning of "texture" is the average of voxel values'
% Toggle: wei_type 'weighted average value', default: 0: 'Meaning of "texture" is the weighted average of voxel values'
% Toggle: max_type 'maximum value', default: 0: 'Meaning of "texture" is the maximum voxel value'
% Toggle: min_type 'minimum value', default: 0: 'Meaning of "texture" is the minimum voxel value'
% Toggle: thi_type 'thickness (specify threshold)', default: 0: 'Meaning of "texture" is the length traced while below threshold'
% Toggle: norm_dir 'normal direction', default: 0: 'Follows the normal direction to extract "texture" information'
% InputFile: i3 'Normal Vectors', optional: 'Surface normal vectors'
% Toggle: view_dir 'view direction', default: 0: 'follows the viewer (projection) direction to extract "texture" information'
% Double: alpha 'alpha', default: 0: 'View plane rotation angle around Z axis'
% Double: beta 'beta ', default: 0: 'View plane rotation angle around X axis'
% Double: out_range 'outside surface', default: 0: 'Length of the region outside the surface where to compute "texture"'
% Double: in_range 'inside surface ', default: 10: 'Length of the region inside the surface where to compute "texture"'
% Double: thres_range 'threshold >=', default: 0: 'Threshold value which determines the region inside the surface where to compute "texture"'
%
% Example: o = kktextu({i1, i2, i3}, {'i1','';'i2','';'o','';'step',1;'ave_type',0;'wei_type',0;'max_type',0;'min_type',0;'thi_type',0;'norm_dir',0;'i3','';'view_dir',0;'alpha',0;'beta',0;'out_range',0;'in_range',10;'thres_range',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% ktextu - Compute texture information for each point lying on the visible surface
%
%  DESCRIPTION
% 
% creates an image file based on volumetric information of a 3D object. This
% information can be of several types and is called here TEXTURE. It can can be
% obtained specifying the walk direction, the range of walking around the object
% surface and the type of texture. The output image is of type KFLOAT.
% 
% This operator requires as inputs the volume (3D object) file, and the
% coordinate file, which is an object w x h x 1 x 1 x 3
% that can be generated optionally by the operator kzbuff, containing the
% coordinates X, Y and Z of each point of the object surface.
% 
% The "ktextu" simulates that, for each point of the object's surface, 
% there is a
% ray going inside the object in the specified direction. Then it walks (visits
% voxels) in that ray in the given range and gets the information according
% to the texture type.
% 
% There are two options for the direction of "texture" extraction: Normal 
% direction, which
% corresponds to the directions of the normal vectors to the object's surface,
% and View direction, which corresponds to the view direction of the z-buffer.
% The first option requires the input file of normal vectors, which is an
% object w x h x 1 x 1 x 3 that can be generated optionally by the operators
% kvsnorm or kisnorm,
% containing the X, Y and Z components of the vectors, stored with inverted
% signals (vectors pointing to inside the object).  The second option requires
% the angles alpha and beta, used to obtain the z-buffer.
% 
% There are two options for the range of "texture" extraction: along a region 
% around the
% surface, specified as how many steps to walk backwards (outside the object)
% and forwards (inside the object); and
% along the thickness, which is determined by the specified threshold. The
% later option requires the direction of "texture" extraction to be the normal 
% direction.
% 
% The increment step can be specified and represents the sampling step while
% extracting the "texture". An increment step equal to 1 visits the voxels one 
% by one.
% 
% There are five types of texture: 1) the voxels' average value, 2) the voxels'
% weighted average value, 3) the voxels' maximal value, 4) the voxels' minimal
% value and 5) the thickness.
% 
% The first option calculates the average value of all the visited voxels. The
% second option is still not implemented. The third option calculates the
% maximal voxel value of all the visited voxels. The forth option calculates
% the minimal voxel value of all the visited voxels. Finally, the last option
% estimate the thickness of the surface based on the length of the ray within
% the object. This last option requires the direction of extraction to be the 
% normal direction and the range of extraction to be given by the threshold.
% 
% The images generated by "ktextu" are useful for analysis by themselves,
% or can be used as input to the operator
% kshad, to compose a shaded image based not only on the object surface form,
% but also on its volumetric structure information.
%
%  
%
%  EXAMPLES
% ktextu -i1 volume.viff -i2 coord.viff -o texture.viff -step 1.0 -norm_dir
%        -i3 normal.viff -out_range 10.0 -in_range 10.0 -max_type
% 
% This example will create a texture file texture.viff from the volume file
% volume.viff and the coordinate file coord.viff by walking 10 steps
% backwards (outside the object) and 10 steps forwards (inside the object)
% around the surface, in the normal direction
% (which is defined by the normal vector file normal.viff), with a sampling 
% step
% equal to 1. The specified texture type is the voxels' maximal value.
% 
% ktextu -i1 volume.viff -i2 coord.viff -o texture.viff -step 2.0 -view_dir
%        -alpha 90.0 -beta 15.0 -out_range 10.0 -in_range 10.0 -ave_type 
% 
% This example will create a texture file texture.viff from the volume file
% volume.viff and the coodinate file coord.viff by walking 10 steps
% backwards and 10 steps forwards around the surface, in the view direction
% (which is a plane rotated 90 degrees in alpha and 15 degrees in beta), with a
% sampling step equal to 2. The specified texture type is the voxels' average
% value.
% 
% ktextu -i1 volume.viff -i2 coord.viff -o texture.viff -step 1.0 -norm_dir
%        -i3 normal.viff -thres 70 -thi_type
% 
% This example will create a texture file texture.viff from the volume file
% volume.viff and the coodinate file coord.viff by walking 
% in the normal direction (which is defined by the normal vector
% file normal.viff), with a sampling step equal to 1. The specified texture type is the thickness, while the threshold is less than 70.
%
%  "SEE ALSO"
% kzbuff, kshad, kisnorm, kvsnorm, kvoxext
%
%  RESTRICTIONS 
% The input objects must have only the value segment. 
% 
% The 
% input object scene can not have dimention e > 1. The input objects coord and
% norm must have dimention e=3.
% 
% The input object scene can not be of data types KCOMPLEX and KDCOMPLEX. The 
% input object coord can not be of data types KBIT, KFLOAT, KDOUBLE, KCOMPLEX
% and KDCOMPLEX. The input object scene can not be of data types KBIT, KCOMPLEX 
% and KDCOMPLEX.
% 
% The input objects coord and norm must match in their dimentions w and h.
% 
% In case of t > 1 in the input objects, the operator will be applied to the time
% t=0 only.
% 
% None of the input and output objects are referenced, therefore some attributes
% may change, as the VALUE_POSITION, for example.
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1993, 1994, 1995 UNICAMP, R A Lotufo,  All rights reserved.
% 


function varargout = kktextu(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kktextu(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i1', '__input';'i2', '__input';'o', '__output';'step', 1;'ave_type', 0;'wei_type', 0;'max_type', 0;'min_type', 0;'thi_type', 0;'norm_dir', 0;'i3', '__input';'view_dir', 0;'alpha', 0;'beta', 0;'out_range', 0;'in_range', 10;'thres_range', 0};
maxval={0,0,0,2,0,0,0,0,0,0,1,0,0,0,1,1,0};
minval={0,0,0,2,0,0,0,0,0,0,1,0,0,0,1,1,0};
istoggle=[0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','InputFile','OutputFile','Double','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle','InputFile','Toggle','Double','Double','Double','Double','Double'};
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
[varargout{:}]=callKhoros([w 'ktextu"  '],Inputs,narglist);
