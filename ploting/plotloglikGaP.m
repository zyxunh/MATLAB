% function plotLoglikGaP(Wres, Hres, pointlogWall, pointlogHall, x1, x2,
% x1in, x2in, Winit, Hinit, p, peval.filenamebase)
if savethis
    writedata([],[],peval,['param_eval'])
    writedata([],[],p,['param_simul'])
end

if exist('Wres','var')
res.cxcy=Wres;
end
if exist('Hres','var')
res.hvec=Hres;
end
    
if savethis
%     saveresults(res,peval,p, [peval.filenamebase '-results-' Winit Hinit]);
    saveresults(res,peval,p, [peval.filenamebase '-results']);
end

% showimage=1;
if ~exist('showimage','var')
    showimage=1;
end

if showimage    
    ca
    dipshow(1,sum(dpixc,3))
    hold on
    if ~isempty(p)
        
        scatter(p.x_vec, p.y_vec)
    end
    for ii=1:peval.ncomp
        scatter(res.cxcy(:,end-peval.ncomp-ii+1), res.cxcy(:,end-ii+1),'gx')
        if exist('x2in', 'var')
            scatter(x2in(:,end-peval.ncomp-ii+1), x2in(:,end-ii+1),'rx')
        end
        if exist('x_mu', 'var')
            scatter(x_mu-1, y_mu-1,'rx')
        end
    end
    
    % scatter(Wres(end-3:end-2), Wres(end-1:end),'x')
    % scatter(x2in(1:2), x2in(3:4),'xr')
    if savethis > 1
%         SaveImageFULL([peval.filenamebase '-sumcxcy-init-' Winit Hinit])
        SaveImageFULL([peval.filenamebase '-sumcxcy'])
    end
    margin=.1
    if exist ('pointlogWall','var');
    figure(2)
    hold on
    colvec=[1:size(pointlogWall,1)];
    if ~isempty(p)
    scatter(p.x_vec, p.y_vec)
    end
    set(gca,'YDir','reverse')
    for ii=1:peval.ncomp
        scatter(pointlogWall(:,end-peval.ncomp-ii+1), pointlogWall(:,end-ii+1),[20],colvec,'x')
        scatter(res.cxcy(:,end-peval.ncomp-ii+1), res.cxcy(:,end-ii+1),'dr')
    end
    % scatter(pointlogWall(:,end-2), pointlogWall(:,end),[20],colvec,'d')
    % scatter(pointlogWall(:,end-3), pointlogWall(:,end-1),[20],colvec,'x')
    % scatter(Wres(end-2), Wres(end),'dr')
    % scatter(Wres(end-3), Wres(end-1),'xr')
    grid on
    c=colorbar;
    ylabel(c,'#iterations')
    xlabel('x [pixels]')
    ylabel('y [pixels]')
    
    if ~isempty(p)
    l=max(p.x_vec)-min(p.x_vec)+2*margin;
    xlim([min(p.x_vec)-margin max(p.x_vec)+margin])
    ylim([mean(p.y_vec)-l/2 mean(p.y_vec)+l/2])
    end
    if savethis > 1
%         SaveImageFULL([peval.filenamebase '-cxcytrace-init-' Winit Hinit])
        SaveImageFULL([peval.filenamebase '-cxcytrace'])
    end
    end
    
    if exist('flog','var')
    figure
    semilogx(-flog)
    grid on
    xlabel('# iterations')
    ylabel ('log(lik)')
    if savethis > 1
%         SaveImageFULL([peval.filenamebase '-loglik-init-' Winit Hinit])
        SaveImageFULL([peval.filenamebase '-loglik'])
    end
    end
end %if showimage

% figure
% semilogx(sum(abs(exp(pointlogHall(:,1:end-4))-(repmat(x1,size(pointlogHall,1),1))),2))
% grid on
% xlabel('# iterations')
% ylabel ('sum(abs(blinkmat-x))')
% if savethis
%     SaveImageFULL([peval.filenamebase '-diff-blinkmat_x-init-' Winit Hinit])
%
% end