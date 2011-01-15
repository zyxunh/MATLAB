function  plotmap_all(pathres, sep, offset, zvec, scalecont)
% cd ~project/data/qdots/S53
% sep=[10 20 50];
% offset=[100 1000];
cd (pathres)
% sufix = {'avg1', 'avg2', 'avg10', 'avg50' 'avg0'};
sufix = {'avg1', 'avg10', 'avg50' 'avg0'};
for is=1:size(sep,2)
    limvec1=[1:15];
    limvec2=[1:15];
    if sep(is)>=0.5
        limvec1=[1:13];
        limvec2=[1:13];
    end
   
    for io=1:size(offset,2) 
        for ii=1:size(sufix,2)
            namebase=['S44_sep_' num2str(100*sep(is)) 'offset_' num2str(offset(io))];
            nameload=[namebase '/' namebase '_DdviMap_' sufix{ii} '.mat'];
            load (nameload)
%             plotmap(res.X1,res.X2,log(res.dh),[namebase '/dh_' sufix{ii}],zvec,limvec1,limvec2,scalecont,'on')
            minval=min(res.mhd(:));
            plotmap(res.X1,res.X2,log(res.mhd-minval+0.01),[namebase '/dh_' sufix{ii}],1,limvec1,limvec2,scalecont,'on');
        end
    end
end