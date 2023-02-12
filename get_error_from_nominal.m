function [yc_error, r_error] = get_error_from_nominal(sim_out)
% Returns the stealthiness and effectiveness error vectors between the
% simulated output and nominal values
% 
% Inputs:
%   - sim_out [N-by-1]: Array of Simulink.SimulationOutput objects
%   - yc_nominal: A timeseries object of nominal critical values
%   - r_nominal : A timeseries object of nominal observer residual values
%
% Outputs:
%   - yc_error [N-by-1]: Error between simulated and nominal critical values
%   - r_error  N-by-1] : Error between simulated and nominal residual values

% Olugbenga Moses Anubi 7/8/2022

nominal_index = load("nominal_index.mat");
yc_nominal = nominal_index.yc_nominal;
% r_nominal = nominal_index.r_nominal;

miniBatchSize = length(sim_out);

yc_error = zeros(miniBatchSize,1);
r_error  = zeros(miniBatchSize,1);

for iter = 1:miniBatchSize
    yc = sim_out(iter).critical_measurement.Data;
    yc = reshape(yc,size(yc,1),size(yc,3)).';
    yc_error_signal = yc - yc_nominal;
    
    residual = sim_out(iter).residual.Data;
   
    yc_error(iter) = mean(vecnorm(yc_error_signal,2,2));
    r_error(iter) = (max(residual)>0.5);   % tolerance bound for the residual
end