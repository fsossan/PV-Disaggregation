function [proxies, TA] = POA_proxies(GHI, ts, location)

[A,T] = generate_proxies();

TA = [A, T];

n_proxies = numel(A);
proxies = nan(size(GHI,1), n_proxies);

% Compute proxy irradiance
for i=1:n_proxies    
    proxies(:, i) = POAirradiance(GHI, ts, location, T(i), A(i));
    
    %     if strcmp(correction,'T') && ~isempty(Ta)
    %         proxies(:,i) = correct_proxies(proxies(:,i),Ta);
    %     elseif strcmp(correction,'TL') && ~isempty(Ta)
    %         proxies(:,i) = correct_proxies(proxies(:,i),Ta,1);
    %     elseif strcmp(correction,'TLV') && ~isempty(Ta)
    %         proxies(:,i) = correct_proxies(proxies(:,i),Ta,1,[AOI,Ib,Id,Ig]);
    %     elseif strcmp(correction,'TV') && ~isempty(Ta)
    %         proxies(:,i) = correct_proxies(proxies(:,i),Ta,0,[AOI,Ib,Id,Ig]);
    %     else
    %         proxies(:,i) = correct_proxies(proxies(:,i),[]);
    %     end
end


