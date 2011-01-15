function varargout=testNMFS41(varargin)
% function [X1,X2,dh,minX]=testNMF2
% function [X1,X2,dh,minX]=testNMF2(w,h,p)
v=varargin{1};
w=varargin{2};
h=varargin{3};
hinit=varargin{4};
h_dovec=varargin{5};
p=varargin{end};

[n,m]=size(w*h);
npix = p.nx*p.ny;
wbg = (1/npix)*ones(npix,1);
p.maxh=10000;
checkvec = [10, 100, 500 10000 p.maxh]; %where the values are recorded
% p.maxh=12;


% xtrue = [15 15+p.separ(1)];
% % nsteps  =
% [X1, X2] = meshgrid(14.5:0.1:16.5, 14.5:0.1:16.5);
% [X1, X2] = meshgrid(14.9:0.05:15.2, 14.9:0.05:15.2);

% [X1, X2] = meshgrid(14.8:0.1:15.1, 15.0:0.1:15.2);

%[X1, X2] = meshgrid(14.8:0.05:15.6, 14.8:0.05:15.6);
% [X1, X2] = meshgrid(15.0, 15.1);
% [X1, X2] = meshgrid(15.0, 15+p.separ(1));
[X1, X2] = meshgrid(15.05, 15.05);
% p.maxh=100;

% xmat = [15 15 15+p.separ(1) 15;
%     15+p.separ(1) 15 15 15;
%     15+p.separ(1)/2 15 15+p.separ(1)/2 15;
%     15 15 16 15;
%     15 15 15+p.separ(1) 16];
for ixmat=1:size(X1,1)
    for jxmat=1:size(X1,2)
        x=[X1(ixmat, jxmat), 15, X2(ixmat, jxmat), 15];
        wg = makegauss(x, p.s, [p.nx p.ny]);
        w = [reshape(wg, p.nx*p.ny,size(wg,3)), wbg];
        % normalization of all w:
        sumw = sum(w,1);
        w = w./repmat(sumw,n,1); %normalization of each component
        h = h.*repmat(sumw',1,m); %to keep the multiplication equal
        
        x1=repmat(sum(w,1)',1,m);
        %%%%%test
        h=hinit;
        htrace(:,:,1)=h;
        iih=1;
        zxmat = 1;
        etha = 10;
        for ih = 1: p.maxh
            y1=w'*(v./(w*h));
            h(h_dovec,:)=h(h_dovec,:).*(y1(h_dovec,:))./x1(h_dovec,:);
            %new updates:
            % % %             h(h_dovec,:)=h(h_dovec,:) + etha*(y1(h_dovec,:) -1);
            h=max(h,eps); % adjust small values to avoid undeflow
            d(ih) = ddivergence(v, w*h);
            %             %%%testing
            % %             dh(ixmat,iih)=d(k);
            % %             iih=iih+1;
            %             %%%testing
            %
            %             dd(k) = abs(d(k)-d(k-1));
            %             fprintf('[%g] Ddivergence %g\n',k, d(k))
            %             k=k+1;
            htrace(:,:,ih+1)=h;
            if sum(ih==checkvec)
                dh(ixmat,jxmat,zxmat)=ddivergence(v, w*h);
                htr(zxmat,:,:) = h;
                %[xc, lags] = xcov(squeeze(htr(zxmat,1,:)), squeeze(htr(zxmat,2,:)), 'none');
                %xcovpeak(ixmat,jxmat,zxmat)=xc(find(lags==0)); %value in zero
                %meanabsxc(ixmat,jxmat,zxmat)=mean(abs(xc));
                zxmat = zxmat+1;
                
            end
        end
        mhd(ixmat,jxmat,:,:)=mean(htr,3); %4dimension: [x,y,z,components]
        %         dh(ixmat,jxmat)=ddivergence(v, w*h);
        fprintf('[%g\t%g]\tDdivergence %g\n',X1(ixmat,jxmat), X2(ixmat,jxmat), dh(ixmat,jxmat, end))
    end
    
end
for ii=1:zxmat-1
    imtmp = dh(:,:,ii);
    miXval(ii) = min(imtmp(:));
    [mx(ii),my(ii)]=find(miXval(ii)==imtmp);
    minX(ii,:)=[X1(mx(ii),my(ii)), X2(mx(ii),my(ii))]
end
varargout{1}=X1;
varargout{2}=X2;
varargout{3}=dh;
varargout{4}=minX;
varargout{5}=miXval;
varargout{6}=mhd;
varargout{7}=htrace;
varargout{8}=p;

% function varargout=assignvalues(varargin)
% v=varargin{1};
% w=varargin{2};
% h=varargin{3};
% ixmat=varargin{4};
% jxmat=varargin{5};
% zxmat=varargin{6};
%
% dh(ixmat,jxmat,zxmat)=ddivergence(v, w*h);
% htr(zxmat,:,:) = h;
% varargout{1}=dh;
% varargout{2}=htr;
% end