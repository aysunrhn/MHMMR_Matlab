function show_MHMMR_results(x,y, MHMMR, yaxislim)
%

if size(x,1)~=1
    x = x'; %y=y';
end
set(0,'defaultaxesfontsize',14);
%colors = {'b','g','r','c','m','k','y'};
colors = {[0.8 0 0],[0 0 0.8],[0 0.8 0],'m','c','k','y',[0.8 0 0],[0 0 0.8],[0 0.8 0],'m','c','k','y',[0.8 0 0],[0 0 0.8],[0 0.8 0]};
style =  {'r.','b.','g.','m.','c.','k.','y.','r.','b.','g.','m.','c.','k.','y.','r.','b.','g.'};

if (nargin<4)||isempty(yaxislim)
    yaxislim = [min(min(y))-2*mean(std(y)), max(max(y))+2*mean(std(y))];
end
[~, K] = size(MHMMR.stats.tau_tk);

%% predicted time series and predicted regime probabilities
scrsz = get(0,'ScreenSize');
figr = figure('Position',[0 scrsz(4)/2 560 scrsz(4)/1.4]);
axes1 = axes('Parent',figr,'Position',[0.1 0.45 0.8 0.48],'FontSize',14);
box(axes1,'on'); hold(axes1,'all');
title('Time series, HMMR regimes, and process probabilites')
plot(x,y,'Color',[0.5 0.5 0.5],'linewidth',2);%black')%
hold on,
plot(x,MHMMR.stats.predicted,'r','linewidth',1.5);
title('Original and predicted HMMR time series')
ylabel('y');
ylim(yaxislim);
xlim([x(1), x(end)])
% prediction probabilities of the hidden process (segmentation)
axes2 = axes('Parent',figr,'Position',[0.1 0.06 0.8 0.33],'FontSize',14);
box(axes2,'on'); hold(axes2,'all');
for k=1:K
    plot(x,MHMMR.stats.predict_prob(:,k),'Color', colors{k},'linewidth',1.5);
    hold on
end
set(gca,'ytick',[0:0.2:1]);
title('prediction probabilities');
xlabel('t');
ylabel('Prob');%Post Probs: Pr(Z_{t}=k|y_1,\ldots,y_{t-1})

%% filtered time series and filtering regime probabilities
scrsz = get(0,'ScreenSize');
figr = figure('Position',[scrsz(4)/4 scrsz(4)/2 560 scrsz(4)/1.4]);
axes1 = axes('Parent',figr,'Position',[0.1 0.45 0.8 0.48],'FontSize',14);
box(axes1,'on'); hold(axes1,'all');
plot(x,y,'Color',[0.5 0.5 0.5],'linewidth',2);%black')%
hold on,
plot(x,MHMMR.stats.filtered,'r','linewidth',1.5);
title('Original and filtered HMMR time series')
ylabel('y');
ylim(yaxislim);
xlim([x(1), x(end)])
% filtering probabilities of the hidden process (segmentation)
axes2 = axes('Parent',figr,'Position',[0.1 0.06 0.8 0.33],'FontSize',14);
box(axes2,'on'); hold(axes2,'all');
for k=1:K
    plot(x,MHMMR.stats.filter_prob(:,k),'Color', colors{k},'linewidth',1.5);
    hold on
end
set(gca,'ytick',[0:0.2:1]);
title('filtering probabilities');
xlabel('t');
ylabel('Prob');%Post Probs: Pr(Z_{t}=k|y_1,\ldots,y_t)


%% data, regressors, and segmentation
scrsz = get(0,'ScreenSize');
figr = figure('Position',[scrsz(4)/2.5 scrsz(4)/2 560 scrsz(4)/1.4]);
axes1 = axes('Parent',figr,'Position',[0.1 0.45 0.8 0.48],'FontSize',14);
box(axes1,'on'); hold(axes1,'all');
title('Time series, MHMMR regimes, and smoothing probabilites')
plot(x,y,'Color',[0.5 0.5 0.5], 'linewidth',2);%black')%
[~, K] = size(MHMMR.stats.tau_tk);
for k=1:K
    model_k = MHMMR.stats.regressors(:,:,k);
    
    active_model_k = model_k(MHMMR.stats.klas==k,:);%prob_model_k >= prob);
    active_period_model_k = x(MHMMR.stats.klas==k);%prob_model_k >= prob);
    
    inactive_model_k = model_k(MHMMR.stats.klas ~= k,:);%prob_model_k >= prob);
    inactive_period_model_k = x(MHMMR.stats.klas ~= k);%prob_model_k >= prob);
    % clf
    % plot(model_k(HMMR.stats.klas ~= k))
    % pause
    %plot(x,HMMR.stats.regressors(HMMR.param.piik >= prob),'linewidth',3);
    if (~isempty(active_model_k))
        hold on,
        plot(inactive_period_model_k,inactive_model_k,style{k},'markersize',0.001);
        hold on,
        plot(active_period_model_k, active_model_k,'Color', colors{k},'linewidth',3.5);
    end
end
ylabel('y');
ylim(yaxislim);
xlim([x(1), x(end)])

% Probablities of the hidden process (segmentation)
axes2 = axes('Parent',figr,'Position',[0.1 0.06 0.8 0.33],'FontSize',14);
box(axes2,'on'); hold(axes2,'all');
%subplot(212),
for k=1:K
    plot(x,MHMMR.stats.tau_tk(:,k),'Color', colors{k},'linewidth',1.5);
    hold on
end
set(gca,'ytick',[0:0.2:1]);
title('smoothing probabilities');
xlabel('t');
ylabel('Prob');%Post Probs: Pr(Z_{t}=k|y_1,\ldots,y_n)

%% data, regression model, and segmentation
scrsz = get(0,'ScreenSize');
figr = figure('Position',[scrsz(4) scrsz(4)/2 560 scrsz(4)/1.4]);
axes1 = axes('Parent',figr,'Position',[0.1 0.45 0.8 0.48],'FontSize',14);
box(axes1,'on'); hold(axes1,'all');
title('Original and smoothed HMMR time series, and segmentation')
ylabel('y');
plot(x,y,'Color',[0.5 0.5 0.8]);%black'%
hold on, plot(x,MHMMR.stats.smoothed,'r','linewidth',2);

% transition time points
tk = find(diff(MHMMR.stats.klas)~=0);
hold on, plot([x(tk); x(tk)], [ones(length(tk),1)*[min(min(y))-2*mean(std(y)) max(max(y))+2*mean(std(y))]]','--','color','k','linewidth',1.5);
ylabel('y');
ylim(yaxislim);
xlim([x(1), x(end)])

% Probablities of the hidden process (segmentation)
axes2 = axes('Parent',figr,'Position',[0.1 0.06 0.8 0.35],'FontSize',14);
box(axes2,'on'); hold(axes2,'all');
plot(x,MHMMR.stats.klas,'k.','linewidth',1.5);

xlabel('t');
ylabel('Estimated class labels');

%% %% model log-likelihood during EM
% %
% figure,
% plot(HMMR.stats.stored_loglik,'-','linewidth',1.5)
% xlabel('EM iteration number')
% ylabel('log-likelihood')
end
