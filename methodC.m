function [alpha, estimated_demand] = methodC(M, Pagg, piecewiseconstant_segmentlength)
% Implements Method C from the paper [1].
%
% Inputs:
% - M: irradiance proxies (W/m2)
% - Pagg: Composite power flow (demand + PV generation) (kW)
% - piecewiseconstant_segmentlength: duration of the piecewise constant
% segment
% - index: contiguos index of the completed time series (before
% measurements were fitlered out, for instance).
% Outputs:
% - alpha: estimated panel configurations at the various locations (kWp)
% - estimated_demand: estimated demand (kW)


% [1] F. Sossan, L. Nespoli, V. Medici and M. Paolone, "Unsupervised
% Disaggregation of PhotoVoltaic Production from Composite Power Flow
% Measurements of Heterogeneous Prosumers," in IEEE Transactions on
% Industrial Informatics, 2018.
% URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8253874&isnumber=4389054

USE_GUROBI = false;


% W/m2 -> kW/m2
M = M/1000;

n = size(M, 1);
J = size(M, 2);
make_S = @(M) [speye(size(M, 1)), -M];

% This is a (n+J)x(n+J) matrix
S = make_S(M);
H = S' * S + 1e-5*speye(max(size(S)));
f = - S' * Pagg;

% Check whether H is SDP (nec. & suff. condition for the problem to be
% convex)
[~, a] = chol(H);
if a ~= 0
    sprintf('H is not semidefinite positive');
    xopt = nan;
    S = nan;
    M = nan;
    nop
end


% --
% Equality constraints
% --
% L is piecewise constant
%n_old = n;
%n = max(index);
temp = [zeros(n,1), -speye(n)];
temp = temp(1:n, 1:n);
temp = speye(n) + temp;

% I remove the equality constraint at each "piecewiseconstant_segmentlength"
for nn=1:piecewiseconstant_segmentlength:n
    temp(nn, :) = zeros(size(temp(nn, :)));
end

% Remove all-zero lines
sel = any(temp > 0, 2);
temp = temp(sel, :);

% Select only colunms at index to exclude noncontiguos measurements
% note: this should be generally done, however it works well when
% measurements are nearly complete (no missing values). If they are not,
% results aren't great.
%temp = temp(:, index);
%n = n_old;

% padding columns with zeros for all the other decision variables
Aeq = [temp, zeros(size(temp,1), J)];
beq = zeros(size(Aeq, 1), 1);


% for gurobi doc see http://www.gurobi.com/documentation/7.5/refman/matlab_gurobi.html
% Solves:
% min  { x'Qx + c'x }
%  s.t.
% Ax < b

if USE_GUROBI
    % --
    % If yous wish to use Gurobi to solve the problem
    % --
    % addpath('/Library/gurobi701/mac64/matlab')
    %
    % model = {};
    % model.Q = sparse(H);
    %
    % % The original f is for the quadprog formulation, it needs to be
    % % twice as much here, see eq.~(12).
    % model.obj = (2*f);
    %
    % % Constraints
    % model.A = sparse(Aeq);
    % model.rhs = beq;
    % model.sense = '=';
    % params.NumericFocus = 3;
    %
    % gurobi_write(model, 'qp.lp');
    % results = gurobi(model, params);
    % xopt = results.x;
    
else
    % --
    % else the standard MATLAB interface
    % --
    xopt = quadprog(H, f, [], [], Aeq, beq, [zeros(n, 1); zeros(J, 1)]);
end


% Extract results;
estimated_demand = xopt(1:n);
alpha = xopt(n+1:n+J);

end

