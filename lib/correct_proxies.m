function proxy = correct_proxies(proxy, T, lowG, CorrV)

if nargin<3
    lowG=0;
end

if nargin<4
    CorrV=[];
end

if ~isempty(CorrV)
    b0=0.05;
    AOI = CorrV(:,1);
    Ib = CorrV(:,2);
    Id = CorrV(:,3);
    Ig = CorrV(:,4);
    IAM = max(1  - b0*(1./cos(min(AOI(:,1)*pi/180,pi/2)) - 1),0);
    proxy = IAM.*Ib +0.95*(Id+Ig); 
end

% Correct the Ppv proxy considering the effect of T
if ~isempty(T)
    gamma = -0.43/100;
    T_nom = 25;
    T_bom = T+proxy*(0.0358+2e-3);
    
    % correct the proxy
    proxy = proxy.*(1+gamma*(T_bom-T_nom));
end

if lowG
    Pratio=max(0.01,proxy/1000);
    InvEff = max(0.2,0.942 * (1 -0.02552*log(Pratio) -0.01447*(log(Pratio)).^2)); % typical SMA SB efficiency
    ModEff = max(0.2,1 -0.02964*log(Pratio) -0.02667*(log(Pratio)).^2);
    proxy = proxy.*InvEff.*ModEff;
end