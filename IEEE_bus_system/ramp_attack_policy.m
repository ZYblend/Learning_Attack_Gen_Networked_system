function attack_data = ramp_attack_policy(policy_param,Z_attack_data)
%% function attack_data = ramp_attack_policy(policy_param,Z_attack_data)
% ramp attack policy
% inputs:
%        policy_param: {attack_start_time_interval, attack_time_span_max_rate, attack_max}
%                     - attack_start_time_interval: [1-by-2] start time interval
%                     - attack_time_span_max_rate: [scalar] attack_time_span_max = attack_time_span_max_rate*t_time_stop
%                     - attack_max: [scalar] final ramp deviation
%                     - t_time_stop: [scalar] total simualtion time of system
%        Z_attack: [3*n_attacked_nodes,n_sim_samples] attack parameters (percenatages) for each attack node
%              Z_attack(1:n_attacked_nodes,:)                     : attack start time for each attack node
%              Z_attack(n_attacked_nodes+1:2*n_attacked_nodes,:)  : attack time spans for each attack node
%              Z_attack(2*n_attacked_nodes+1:3*n_attacked_nodes,:): attack final deviations for each attack node
% output:
%        attack_start_times
%
% Author: Olugbenga Moses Anubi, Florida state university
%         Yu Zheng, Florida state university
% 08/17/2022

%% attack policy parameters
attack_start_time_interval = policy_param{1,1};
% attack_start_time_interval       = round([0.1 0.2]*t_sim_stop);
delta_attack_start_time_interval = attack_start_time_interval(2) - attack_start_time_interval(1);
% attack_time_span_max = round(0.3*t_sim_stop);
attack_time_span_max_rate = policy_param{1,2};
t_sim_stop = policy_param{1,4};
attack_time_span_max = attack_time_span_max_rate*t_sim_stop;
% attack_max = 50;
attack_max = policy_param{1,3};
n_attacked_nodes = round(size(Z_attack_data,1)/3);

%% generate attacks
% attack start times
attack_start_times = attack_start_time_interval(1) + ...
    delta_attack_start_time_interval*Z_attack_data(1:n_attacked_nodes,:);

% attack time spans
attack_time_span_min = 2e-5;
attack_time_span   = attack_time_span_min + attack_time_span_max*Z_attack_data(n_attacked_nodes+1:2*n_attacked_nodes,:);

% attack final deviations
attack_final_deviations = attack_max*Z_attack_data(2*n_attacked_nodes+1:3*n_attacked_nodes,:);

attack_data = [attack_start_times;
               attack_time_span;
               attack_final_deviations];
