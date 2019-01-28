%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mhmmr =  init_mhmmr(X, y, K, type_variance, EM_try)
% function mhmmr =  init_mhmmr(X, y, K, type_variance, EM_try)
% init_mhmmr initialize the parameters of a Multivriate Hidden Markov Model
% Regression (MHMMR) model
%
% Inputs :
%
%           X: [nx(p+1)] regression desing matrix
%           y: [nxd] multivariate time series
%           K : Number of polynomial regression components (regimes)
%          	type_variance: hoskedastoc or heteroskedastic
%           EM_try: number of the current EM run
%
% Outputs :
%
%         mhmmr: the initial MHMMR model. a structure composed of:
%
%         prior: [Kx1]: prior(k) = Pr(z_1=k), k=1...K
%         trans_mat: [KxK], trans_mat(\ell,k) = Pr(z_t = k|z_{t-1}=\ell)
%         reg_param: the paramters of the regressors:
%                 betak: regression coefficients
%                 sigma2k (or sigma2) : the covariance matrices(s). sigma2k(k) = cov[y(t)|z(t)=k]
%         and some stats: like the the posterior probs, the loglikelihood,
%         etc
%
% Faicel Chamroukhi, first version in November 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(type_variance,'homoskedastic')
    homoskedastic = 1;
else
    homoskedastic = 0;
end
m = length(y);
%% Tnitialisation en tenant compte de la contrainte:

% Initialisation de la matrice des transitions
Mask = .5*eye(K);%masque d'ordre 1
for k=1:K-1
    ind = find(Mask(k,:) ~= 0);
    Mask(k,ind+1) = .5;
end
mhmmr.trans_mat = Mask;

% Initialisation de la loi initiale de la variable cachee
mhmmr.prior = [1;zeros(K-1,1)];
mhmmr.stats.Mask = Mask;
%  Initialisation des coeffecients de regression et des variances.
mhmmr_reg = init_mhmmr_regressors(X, y, K, homoskedastic, EM_try);

mhmmr.reg_param = mhmmr_reg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mhmmr_reg_param = init_mhmmr_regressors(X, y, K, homoskedastic, EM_try)


[m, P] = size(X);
%[m, d] = length(y);


if  EM_try ==1% uniform segmentation into K contiguous segments, and then a regression
    zi = round(m/K)-1;
    
    s=0;%if homoskedastic
    for k=1:K
        yk = y((k-1)*zi+1:k*zi, :);
        Xk = X((k-1)*zi+1:k*zi, :);
        
        mhmmr_reg_param.betak(:, :,k) = inv(Xk'*Xk + 1e-4*eye(P))*Xk'*yk;%regress(yk,Xk); % for a use in octave, where regress doesnt exist
        muk = Xk*mhmmr_reg_param.betak(:,:,k);
        sk = (yk-muk)'*(yk-muk);
        if homoskedastic
           s= (s+sk);
           mhmmr_reg_param.sigmak = s/m;
        else
            mhmmr_reg_param.sigmak(:,:,k) = sk/length(yk);
        end
    end
    
else % random segmentation into contiguous segments, and then a regression
    Lmin= P+1;%minimum length of a segment %10
    tk_init = zeros(K,1);
    tk_init(1) = 0;
    K_1=K;
    for k = 2:K
        K_1 = K_1-1;
        temp = tk_init(k-1)+Lmin:m-K_1*Lmin;
        ind = randperm(length(temp));
        tk_init(k)= temp(ind(1));
    end
    tk_init(K+1) = m;
    
    s=0;%
    for k=1:K
        i = tk_init(k)+1;
        j = tk_init(k+1);
        yk = y(i:j, :); 
        Xk = X(i:j,:);
        mhmmr_reg_param.betak(:,:,k) = inv(Xk'*Xk + 1e-4*eye(P))*Xk'*yk;%regress(yk,Xk); % for a use in octave, where regress doesnt exist
        muk = Xk* mhmmr_reg_param.betak(:,:,k);
        sk = (yk-muk)'*(yk-muk);
        
        if homoskedastic
            s = s+sk;
             mhmmr_reg_param.sigmak = s/m;
        else
            mhmmr_reg_param.sigmak(:,:,k) = sk/length(yk);%
        end
    end
end
%

